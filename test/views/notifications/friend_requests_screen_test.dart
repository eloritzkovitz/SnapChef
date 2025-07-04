import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/notifications/friend_requests_screen.dart';
import 'package:snapchef/views/notifications/widgets/friend_request_list_item.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/models/friend_request.dart';

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

  group('FriendRequestsScreen', () {
    testWidgets('shows requests to me and by me', (tester) async {
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
      friendViewModel.setLoading(false);

      await tester.pumpWidget(
          wrapWithProviders(const FriendRequestsScreen(skipFetch: true)));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Friend Requests'), findsOneWidget);
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
  });
}
