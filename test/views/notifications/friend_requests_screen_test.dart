import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/app_notification.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/notifications/friend_requests_screen.dart';
import 'package:snapchef/views/notifications/widgets/friend_request_list_item.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/models/friend_request.dart';

import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_friend_viewmodel.dart';

class _NoNetworkImageHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _NoNetworkImageHttpOverrides();
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  late MockUserViewModel userViewModel;
  late MockFriendViewModel friendViewModel;

  setUp(() {
    userViewModel = MockUserViewModel();
    friendViewModel = MockFriendViewModel();

    userViewModel.setUser(
      User(
        id: 'u1',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        fridgeId: 'fridge1',
        cookbookId: 'cb1',
      ),
    );
  });

  Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
        ChangeNotifierProvider<FriendViewModel>.value(value: friendViewModel),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('FriendRequestsScreen', () {
    setUp(() {
      userViewModel = MockUserViewModel();
      friendViewModel = MockFriendViewModel();
      userViewModel.setUser(
        User(
          id: 'u1',
          firstName: 'Test',
          lastName: 'User',
          email: 'test@example.com',
          fridgeId: 'fridge1',
          cookbookId: 'cb1',
        ),
      );
    });

    testWidgets('shows loading indicator when user is null', (tester) async {
      userViewModel.setUser(null);
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator when friendViewModel is loading',
        (tester) async {
      friendViewModel.setLoading(true);
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when friendViewModel has error',
        (tester) async {
      friendViewModel.setLoading(false);
      friendViewModel.setError('Something went wrong');
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows empty state for requests to me', (tester) async {
      friendViewModel.setLoading(false);
      friendViewModel.setPendingRequests([]);
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.text('No friend requests.'), findsOneWidget);
    });

    testWidgets('shows empty state for requests by me', (tester) async {
      friendViewModel.setLoading(false);
      friendViewModel.setSentRequests([]);
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      // Tap "Requests by me" chip
      await tester.tap(find.text('Requests by me'));
      await tester.pumpAndSettle();
      expect(
          find.text('You have not sent any friend requests.'), findsOneWidget);
    });

    testWidgets('shows requests to me', (tester) async {
      friendViewModel.setLoading(false);
      friendViewModel.setPendingRequests([
        FriendRequest(
          id: 'fr1',
          from: User(
              id: 'u2',
              firstName: 'Other',
              lastName: 'User',
              email: '',
              fridgeId: '',
              cookbookId: ''),
          to: 'u1',
          status: 'pending',
          createdAt: DateTime.now(),
        )
      ]);
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.byType(FriendRequestListItem), findsOneWidget);
      expect(find.text('Friend Requests'), findsOneWidget);
    });

    testWidgets('shows requests by me with user in cache', (tester) async {
      friendViewModel.setLoading(false);
      friendViewModel.setSentRequests([
        FriendRequest(
          id: 'fr2',
          from: User(
              id: 'u1',
              firstName: 'Test',
              lastName: 'User',
              email: '',
              fridgeId: '',
              cookbookId: ''),
          to: 'u2',
          status: 'pending',
          createdAt: DateTime.now(),
        )
      ]);
      userViewModel.fetchUserProfileCallback = (String id) async => User(
            id: id,
            firstName: 'Fetched',
            lastName: 'User',
            email: 'fetched@example.com',
            fridgeId: 'fridgeX',
            cookbookId: 'cbX',
          );
      await tester.pumpWidget(
        wrapWithProviders(const FriendRequestsScreen(skipFetch: true)),
      );
      await tester.tap(find.text('Requests by me'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendRequestListItem), findsOneWidget);
    });

    testWidgets('shows skeleton when user not in cache for requests by me',
        (tester) async {
      friendViewModel.setLoading(false);
      friendViewModel.setSentRequests([
        FriendRequest(
          id: 'fr2',
          from: User(
              id: 'u1',
              firstName: 'Test',
              lastName: 'User',
              email: '',
              fridgeId: '',
              cookbookId: ''),
          to: 'u3',
          status: 'pending',
          createdAt: DateTime.now(),
        )
      ]);
      userViewModel.fetchUserProfileCallback = (String id) async => null;
      await tester.pumpWidget(
        wrapWithProviders(const FriendRequestsScreen(skipFetch: true)),
      );
      await tester.tap(find.text('Requests by me'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('toggles between requests to me and by me', (tester) async {
      friendViewModel.setLoading(false);
      friendViewModel.setPendingRequests([
        FriendRequest(
          id: 'fr1',
          from: User(
              id: 'u2',
              firstName: 'Other',
              lastName: 'User',
              email: '',
              fridgeId: '',
              cookbookId: ''),
          to: 'u1',
          status: 'pending',
          createdAt: DateTime.now(),
        )
      ]);
      friendViewModel.setSentRequests([
        FriendRequest(
          id: 'fr2',
          from: User(
              id: 'u1',
              firstName: 'Test',
              lastName: 'User',
              email: '',
              fridgeId: '',
              cookbookId: ''),
          to: 'u2',
          status: 'pending',
          createdAt: DateTime.now(),
        )
      ]);
      userViewModel.fetchUserProfileCallback = (String id) async => User(
            id: 'u2',
            firstName: 'Other',
            lastName: 'User',
            email: '',
            fridgeId: '',
            cookbookId: '',
          );
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.byType(FriendRequestListItem), findsOneWidget);
      // Switch to "by me"
      await tester.tap(find.text('Requests by me'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendRequestListItem), findsOneWidget);
      // Switch back to "to me"
      await tester.tap(find.text('Requests to me'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendRequestListItem), findsOneWidget);
    });
  });

  group('FriendRequestListItem', () {
    late MockUserViewModel userViewModel;
    late MockFriendViewModel friendViewModel;
    late MockNotificationsViewModel notificationsViewModel;
    late User currentUser;
    late User otherUser;
    late FriendRequest req;

    setUp(() {
      userViewModel = MockUserViewModel();
      friendViewModel = MockFriendViewModel();
      notificationsViewModel = MockNotificationsViewModel();
      currentUser = User(
        id: 'u1',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        fridgeId: 'fridge1',
        cookbookId: 'cb1',
      );
      otherUser = User(
        id: 'u2',
        firstName: 'Other',
        lastName: 'User',
        email: 'other@example.com',
        fridgeId: 'fridge2',
        cookbookId: 'cb2',
        profilePicture: 'profile.jpg',
      );
      req = FriendRequest(
        id: 'fr1',
        from: otherUser,
        to: 'u1',
        status: 'pending',
        createdAt: DateTime.now(),
      );
    });

    Widget wrapWithAllProviders(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
          ChangeNotifierProvider<FriendViewModel>.value(value: friendViewModel),
          ChangeNotifierProvider<NotificationsViewModel>.value(
              value: notificationsViewModel),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('renders and triggers callbacks', (tester) async {
      final user = User(
        id: 'u2',
        firstName: 'Other',
        lastName: 'User',
        email: 'other@example.com',
        fridgeId: 'fridge2',
        cookbookId: 'cb2',
      );
      final req = FriendRequest(
        id: 'fr1',
        from: user,
        to: 'u1',
        status: 'pending',
        createdAt: DateTime.parse('2023-10-01T12:00:00Z'),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          Scaffold(
            body: FriendRequestListItem(
              user: user,
              req: req,
              showSentByMe: true,
              currentUser: user,
              friendViewModel: friendViewModel,
              userViewModel: userViewModel,
              onRefresh: () {},
              preloadSentUsers: () async {},
            ),
          ),
        ),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders with profile picture and cancel button (showSentByMe)',
        (tester) async {
      bool refreshCalled = false;
      bool preloadCalled = false;
      await tester.pumpWidget(
        wrapWithAllProviders(
          FriendRequestListItem(
            user: otherUser,
            req: req,
            showSentByMe: true,
            currentUser: currentUser,
            friendViewModel: friendViewModel,
            userViewModel: userViewModel,
            onRefresh: () {
              refreshCalled = true;
            },
            preloadSentUsers: () async {
              preloadCalled = true;
            },
          ),
        ),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(refreshCalled, isTrue);
      expect(preloadCalled, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('renders with default profile picture', (tester) async {
      final userNoPic = User(
        id: 'u3',
        firstName: 'NoPic',
        lastName: 'User',
        email: 'nop@example.com',
        fridgeId: 'fridge3',
        cookbookId: 'cb3',
        profilePicture: null,
      );
      await tester.pumpWidget(
        wrapWithAllProviders(
          FriendRequestListItem(
            user: userNoPic,
            req: req,
            showSentByMe: true,
            currentUser: currentUser,
            friendViewModel: friendViewModel,
            userViewModel: userViewModel,
            onRefresh: () {},
            preloadSentUsers: () async {},
          ),
        ),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders accept/decline buttons and triggers accept',
        (tester) async {
      bool refreshCalled = false;
      bool preloadCalled = false;
      bool notificationAdded = false;
      notificationsViewModel.addNotificationCallback =
          (AppNotification _, [String? __]) async {
        notificationAdded = true;
      };
      notificationsViewModel.generateUniqueNotificationIdCallback =
          () async => 'notif1';

      await tester.pumpWidget(
        wrapWithAllProviders(
          FriendRequestListItem(
            user: otherUser,
            req: req,
            showSentByMe: false,
            currentUser: currentUser,
            friendViewModel: friendViewModel,
            userViewModel: userViewModel,
            onRefresh: () {
              refreshCalled = true;
            },
            preloadSentUsers: () async {
              preloadCalled = true;
            },
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap accept
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      expect(refreshCalled, isTrue);
      expect(preloadCalled, isTrue);
      expect(notificationAdded, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('renders accept/decline buttons and triggers decline',
        (tester) async {
      bool refreshCalled = false;
      bool preloadCalled = false;
      await tester.pumpWidget(
        wrapWithAllProviders(
          FriendRequestListItem(
            user: otherUser,
            req: req,
            showSentByMe: false,
            currentUser: currentUser,
            friendViewModel: friendViewModel,
            userViewModel: userViewModel,
            onRefresh: () {
              refreshCalled = true;
            },
            preloadSentUsers: () async {
              preloadCalled = true;
            },
          ),
        ),
      );
      // Tap decline
      final declineButtons = find.byIcon(Icons.close);
      // The first close icon is for decline, the second is for cancel (if present)
      await tester.tap(declineButtons.first);
      await tester.pumpAndSettle();
      expect(refreshCalled, isTrue);
      expect(preloadCalled, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
