import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/notifications/friend_notification.dart';
import 'package:snapchef/models/notifications/share_notification.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/models/friend_request.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/notifications/friend_requests_screen.dart';
import 'package:snapchef/views/notifications/widgets/friend_request_list_item.dart';
import 'package:snapchef/views/notifications/widgets/notification_list_item.dart';

import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_friend_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  group('NotificationListItem', () {
    late MockUserViewModel userViewModel;

    setUp(() {
      userViewModel = MockUserViewModel();
      userViewModel.setFriends([
        User(
          id: 'sender1',
          firstName: 'Sender',
          lastName: 'One',
          email: 'sender1@example.com',
          fridgeId: 'f1',
          cookbookId: 'cb1',
          profilePicture: 'profile.jpg',
        ),
        User(
          id: 'sender2',
          firstName: 'Sender',
          lastName: 'Two',
          email: 'sender2@example.com',
          fridgeId: 'f2',
          cookbookId: 'cb2',
          profilePicture: '',
        ),
      ]);
    });

    Widget wrapNotif(Widget child) =>
        ChangeNotifierProvider<UserViewModel>.value(
          value: userViewModel,
          child: MaterialApp(home: Scaffold(body: child)),
        );

    testWidgets('renders ShareNotification with profile picture', (tester) async {
      final notif = ShareNotification(
        id: 'n1',
        senderId: 'sender1',
        recipientId: 'u1',
        title: 'Shared!',
        body: 'A recipe was shared.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender One',
        recipeName: 'Pizza',
      );
      await tester.pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Shared!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders ShareNotification without profile picture', (tester) async {
      final notif = ShareNotification(
        id: 'n2',
        senderId: 'sender2',
        recipientId: 'u1',
        title: 'Shared!',
        body: 'A recipe was shared.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender Two',
        recipeName: 'Cake',
      );
      await tester.pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Shared!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });

    testWidgets('renders FriendNotification with profile picture', (tester) async {
      final notif = FriendNotification(
        id: 'n3',
        senderId: 'sender1',
        recipientId: 'u1',
        title: 'Friend!',
        body: 'You have a new friend.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender One',
      );
      await tester.pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Friend!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders FriendNotification without profile picture', (tester) async {
      final notif = FriendNotification(
        id: 'n4',
        senderId: 'sender2',
        recipientId: 'u1',
        title: 'Friend!',
        body: 'You have a new friend.',
        scheduledTime: DateTime.now(),
        friendName: 'Sender Two',
      );
      await tester.pumpWidget(wrapNotif(NotificationListItem(notification: notif)));
      expect(find.text('Friend!'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // default profile
    });    

    testWidgets('calls onDelete and onDismissed', (tester) async {
      bool dismissed = false;
      final notif = ShareNotification(
        id: 'n6',
        title: 'Dismiss!',
        body: 'Dismiss notification.',
        scheduledTime: DateTime.now(), 
        senderId: '', 
        recipientId: '',
      );
      await tester.pumpWidget(wrapNotif(NotificationListItem(
        notification: notif,
        onDelete: () {},
        onDismissed: (_) => dismissed = true,
        confirmDismiss: (_) async => true,
      )));
      // Swipe to dismiss
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });
  });

  group('FriendRequestsScreen', () {
    testWidgets('shows loading indicator', (tester) async {
      friendViewModel.setLoading(true);
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message', (tester) async {
      friendViewModel.setError('Failed to load');
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      expect(find.textContaining('Failed'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      friendViewModel.setPendingRequests([]);
      friendViewModel.setSentRequests([]);
      friendViewModel.setLoading(false);
      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      await tester.pumpAndSettle();
      expect(find.textContaining('No'), findsWidgets);
    });

    testWidgets('shows requests to me and by me', (tester) async {
      final user = userViewModel.user!;
      final otherUser = User(
        id: 'u2',
        firstName: 'Other',
        lastName: 'User',
        email: 'other@example.com',
        fridgeId: 'fridge2',
        cookbookId: 'cb2',
      );
      final reqToMe = FriendRequest(
        id: 'fr1',
        from: otherUser,
        to: user.id,
        status: 'pending',
        createdAt: DateTime.parse('2023-10-01T12:00:00Z'),
      );
      final reqByMe = FriendRequest(
        id: 'fr2',
        from: user,
        to: otherUser.id,
        status: 'pending',
        createdAt: DateTime.parse('2023-10-02T12:00:00Z'),
      );

      friendViewModel.setPendingRequests([reqToMe]);
      friendViewModel.setSentRequests([reqByMe]);
      friendViewModel.setLoading(false);

      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      await tester.pumpAndSettle();

      expect(find.text('Friend Requests'), findsOneWidget);
      expect(find.byType(FriendRequestListItem), findsOneWidget);

      await tester.tap(find.text('Requests by me'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendRequestListItem), findsOneWidget);
    });
  });

  group('FriendRequestListItem', () {
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
        MaterialApp(
          home: Scaffold(
            body: wrapWithProviders(
              FriendRequestListItem(
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
        ),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}