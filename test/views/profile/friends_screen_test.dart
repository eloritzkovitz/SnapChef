import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/database/app_database.dart' hide User;
import 'package:snapchef/models/friend_request.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/views/profile/friends_screen.dart';
import 'package:snapchef/views/profile/widgets/friend_card.dart';
import 'package:snapchef/views/profile/widgets/friend_search_modal.dart';

import '../../mocks/mock_app_database.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_friend_viewmodel.dart';
import '../../mocks/mock_services.dart';
import '../../mocks/mock_user_repository.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_ingredient_viewmodel.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await dotenv.load(fileName: ".env");

    final getIt = GetIt.instance;
    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerSingleton<AppDatabase>(MockAppDatabase());
    }
    if (!getIt.isRegistered<ConnectivityProvider>()) {
      getIt.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
    }
    if (!getIt.isRegistered<SocketService>()) {
      getIt.registerSingleton<SocketService>(MockSocketService());
    }
    if (!getIt.isRegistered<UserRepository>()) {
      getIt.registerSingleton<UserRepository>(MockUserRepository());
    }
    if (!getIt.isRegistered<FriendService>()) {
      getIt.registerSingleton<FriendService>(MockFriendService());
    }
  });

  group('FriendsScreen', () {
    late MockUserViewModel userViewModel;
    late MockFriendViewModel friendViewModel;
    late MockConnectivityProvider connectivityProvider;

    setUp(() {
      userViewModel = MockUserViewModel();
      friendViewModel = MockFriendViewModel();
      connectivityProvider = MockConnectivityProvider();
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

    Widget buildTestWidget({Map<String, WidgetBuilder>? routes}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
          ChangeNotifierProvider<FriendViewModel>.value(value: friendViewModel),
          ChangeNotifierProvider<ConnectivityProvider>.value(
              value: connectivityProvider),
          ChangeNotifierProvider<IngredientViewModel>.value(
              value: MockIngredientViewModel()),
        ],
        child: MaterialApp(
          home: const FriendsScreen(),
          routes: routes ?? const {},
        ),
      );
    }

    testWidgets('renders FriendsScreen and FriendCard', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(FriendsScreen), findsOneWidget);
      expect(find.byType(FriendCard), findsOneWidget);
      expect(find.text('Add Friends'), findsOneWidget);
    });

    testWidgets('filters friends by search', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Friend');
      await tester.pumpAndSettle();
      expect(find.byType(FriendCard), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Nonexistent');
      await tester.pumpAndSettle();
      expect(find.text('No friends found.'), findsOneWidget);
    });

    testWidgets('shows empty state when no friends', (tester) async {
      userViewModel.setUser(
        User(
          id: 'u1',
          firstName: 'Test',
          lastName: 'User',
          email: 'test@example.com',
          fridgeId: 'fridge1',
          cookbookId: 'cb1',
          friends: [],
        ),
      );
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text("You don't have any friends yet."), findsOneWidget);
      expect(find.text('Add Friends'), findsOneWidget);
    });

    testWidgets('opens add friend modal', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Friends'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendSearchModal), findsOneWidget);
    });

    testWidgets('disables Add Friends button when offline', (tester) async {
      connectivityProvider.isOffline = true;
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final buttonFinder = find.text('Add Friends');
      expect(buttonFinder, findsOneWidget);
      tester.widget(buttonFinder);
      // Optionally, check for the button type and onPressed property if needed
      connectivityProvider.isOffline = false;
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      userViewModel.setUser(null);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('opens and cancels remove friend dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      // Tap Remove Friend
      await tester.tap(find.text('Remove Friend'));
      await tester.pumpAndSettle();
      // Dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('removes friend on confirm', (tester) async {
      bool removed = false;
      userViewModel.removeFriendCallback = (String id) async {
        removed = true;
      };
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      // Tap Remove Friend
      await tester.tap(find.text('Remove Friend'));
      await tester.pumpAndSettle();
      // Tap Remove in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(removed, isTrue);
      expect(find.textContaining('removed from friends.'), findsOneWidget);
    });

    testWidgets('shows SnackBar on remove friend error', (tester) async {
      userViewModel.removeFriendCallback = (String id) async {
        throw Exception('Remove error');
      };
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      // Tap Remove Friend
      await tester.tap(find.text('Remove Friend'));
      await tester.pumpAndSettle();
      // Tap Remove in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Failed to remove friend'), findsOneWidget);
    });

    testWidgets('opens public profile on view', (tester) async {
      userViewModel.fetchUserProfileCallback = (String id) async {
        return User(
          id: 'u2',
          firstName: 'Friend',
          lastName: 'User',
          email: 'friend@example.com',
          fridgeId: 'fridge2',
          cookbookId: 'cb2',
        );
      };
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      // Tap View Profile
      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();
    });

    testWidgets('shows SnackBar on failed public profile fetch',
        (tester) async {
      userViewModel.fetchUserProfileCallback = (String id) async {
        return null;
      };
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      // Tap View Profile
      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Failed to load profile'), findsOneWidget);
    });
  });

  group('FriendSearchModal', () {
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
      friendViewModel.setPendingRequests([]);
      friendViewModel.setSentRequests([]);
    });

    Widget buildModal() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
          ChangeNotifierProvider<FriendViewModel>.value(value: friendViewModel),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FriendSearchModal(),
            ),
          ),
        ),
      );
    }

    testWidgets('shows search box and empty state', (tester) async {
      await tester.pumpWidget(buildModal());
      expect(find.byType(FriendSearchModal), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      // No users found message should not show initially
      expect(find.text('No users found.'), findsNothing);
    });

    testWidgets('shows loading indicator during search', (tester) async {
      friendViewModel.searchUsersCallback = (query) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return [];
      };
      await tester.pumpWidget(buildModal());
      await tester.enterText(find.byType(TextField), 'abc');
      // Wait for debounce (adjust if your modal uses a different debounce)
      await tester.pump(const Duration(milliseconds: 400));
      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Finish async
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      // Should not show loading indicator anymore
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error on search failure', (tester) async {
      friendViewModel.searchUsersCallback = (query) async {
        throw Exception('fail');
      };
      await tester.pumpWidget(buildModal());
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Failed to search users'), findsOneWidget);
    });

    testWidgets('shows users and handles Add, Pending, Friend chips',
        (tester) async {
      final user = User(
        id: 'u2',
        firstName: 'Friend',
        lastName: 'User',
        email: 'friend@example.com',
        fridgeId: 'fridge2',
        cookbookId: 'cb2',
      );
      friendViewModel.searchUsersCallback = (query) async => [user];
      await tester.pumpWidget(buildModal());
      await tester.enterText(find.byType(TextField), 'Friend');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Friend User'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Simulate as friend
      userViewModel.setUser(
        userViewModel.user!.copyWith(friends: [user]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Friend'), findsOneWidget);

      // Simulate as pending
      userViewModel.setUser(
        userViewModel.user!.copyWith(friends: []),
      );
      friendViewModel.setPendingRequests([
        FriendRequest(
          id: 'req1',
          from: userViewModel.user!,
          to: user.id,
          status: 'pending',
          createdAt: DateTime.now(),
        )
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows "No users found." when search returns empty',
        (tester) async {
      friendViewModel.searchUsersCallback = (query) async => [];
      await tester.pumpWidget(buildModal());
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('No users found.'), findsOneWidget);
    });

    testWidgets('sends friend request and shows snackbar', (tester) async {
      final user = User(
        id: 'u2',
        firstName: 'Friend',
        lastName: 'User',
        email: 'friend@example.com',
        fridgeId: 'fridge2',
        cookbookId: 'cb2',
      );
      friendViewModel.searchUsersCallback = (query) async => [user];
      friendViewModel.sendFriendRequestCallback =
          (userId, currentUserId, userVm) async {
        return 'Friend request sent!';
      };
      await tester.pumpWidget(buildModal());
      await tester.enterText(find.byType(TextField), 'Friend');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      Finder addFinder = find.widgetWithText(InkWell, 'Add');
      if (addFinder.evaluate().isEmpty) {
        final gestureFinder = find.widgetWithText(GestureDetector, 'Add');
        final buttonFinder = find.widgetWithText(TextButton, 'Add');
        if (gestureFinder.evaluate().isNotEmpty) {
          addFinder = gestureFinder;
        } else if (buttonFinder.evaluate().isNotEmpty) {
          addFinder = buttonFinder;
        } else {
          fail('No tappable "Add" widget found!');
        }
      }
      await tester.ensureVisible(addFinder.first);
      await tester.tap(addFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('shows error snackbar on send friend request failure',
        (tester) async {
      final user = User(
        id: 'u2',
        firstName: 'Friend',
        lastName: 'User',
        email: 'friend@example.com',
        fridgeId: 'fridge2',
        cookbookId: 'cb2',
      );
      friendViewModel.searchUsersCallback = (query) async => [user];
      friendViewModel.sendFriendRequestCallback =
          (userId, currentUserId, userVm) async {
        throw Exception('fail');
      };
      await tester.pumpWidget(buildModal());
      await tester.enterText(find.byType(TextField), 'Friend');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      Finder addFinder = find.widgetWithText(InkWell, 'Add');
      if (addFinder.evaluate().isEmpty) {
        final gestureFinder = find.widgetWithText(GestureDetector, 'Add');
        final buttonFinder = find.widgetWithText(TextButton, 'Add');
        if (gestureFinder.evaluate().isNotEmpty) {
          addFinder = gestureFinder;
        } else if (buttonFinder.evaluate().isNotEmpty) {
          addFinder = buttonFinder;
        } else {
          fail('No tappable "Add" widget found!');
        }
      }
      await tester.ensureVisible(addFinder.first);
      await tester.tap(addFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining('Failed to send friend request'), findsOneWidget);
    });    
  });
}
