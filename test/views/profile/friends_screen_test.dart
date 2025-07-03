import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/views/profile/friends_screen.dart';
import 'package:snapchef/views/profile/widgets/friend_card.dart';
import 'package:snapchef/views/profile/widgets/friend_search_modal.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_friend_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  group('FriendsScreen', () {
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
          friends: [
            User(
              id: 'u2',
              firstName: 'Friend',
              lastName: 'User',
              email: 'friend@example.com',
              fridgeId: 'fridge2',
              cookbookId: 'cb2',
            ),
          ],
        ),
      );
      friendViewModel.setPendingRequests([]);
      friendViewModel.setSentRequests([]);
    });

    Widget buildTestWidget({Widget? child}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
          ChangeNotifierProvider<FriendViewModel>.value(value: friendViewModel),
          ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider(),
          ),
        ],
        child: MaterialApp(
          home: child ?? const FriendsScreen(),
        ),
      );
    }

    testWidgets('renders FriendsScreen and FriendCard', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(FriendsScreen), findsOneWidget);
      expect(find.byType(FriendCard), findsOneWidget);
    });

    testWidgets('opens add friend modal', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pumpAndSettle();
      expect(find.byType(FriendSearchModal), findsOneWidget);
    });
  });
}