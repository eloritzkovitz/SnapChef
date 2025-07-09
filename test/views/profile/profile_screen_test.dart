import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/database/app_database.dart' hide User, Ingredient;
import 'package:snapchef/models/user.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/views/profile/profile_screen.dart';
import 'package:snapchef/views/profile/widgets/profile_details.dart';
import 'package:snapchef/views/profile/widgets/settings_menu.dart';
import 'package:snapchef/views/profile/friends_screen.dart';
import 'package:snapchef/views/profile/widgets/stat_card.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

import '../../mocks/mock_app_database.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_ingredient_viewmodel.dart';
import '../../mocks/mock_services.dart';
import '../../mocks/mock_user_repository.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_auth_viewmodel.dart'; // <-- Add this import

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  group('ProfileScreen', () {
    late MockUserViewModel userViewModel;
    late MockIngredientViewModel ingredientViewModel;

    setUp(() {
      userViewModel = MockUserViewModel();
      ingredientViewModel = MockIngredientViewModel();
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
      userViewModel.setUserStats({
        'ingredientCount': 5,
        'recipeCount': 3,
        'favoriteRecipeCount': 2,
        'friendCount': 0,
        'mostPopularIngredients': [],
      });
      ingredientViewModel.setLoading(false);
    });

    Widget buildTestWidget({Widget? child}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
          ChangeNotifierProvider<IngredientViewModel>.value(
              value: ingredientViewModel),
          ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider(),
          ),
        ],
        child: MaterialApp(
          home: child ?? const ProfileScreen(),
        ),
      );
    }

    testWidgets('renders ProfileScreen and ProfileDetails', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ProfileDetails), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('opens settings menu', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsMenu), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsAtLeastNWidgets(1));
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('opens friends list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      // Tap the friends icon in ProfileDetails (simulate onFriendsTap)
      final profileDetails =
          tester.widget<ProfileDetails>(find.byType(ProfileDetails));
      profileDetails.onFriendsTap?.call();
      await tester.pumpAndSettle();
      expect(find.byType(FriendsScreen), findsOneWidget);
    });
  });

  group('StatCard', () {
    testWidgets('renders StatCard with correct data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.star,
              color: Colors.blue,
              label: 'Stars',
              value: 42,
            ),
          ),
        ),
      );
      expect(find.byType(StatCard), findsOneWidget);
      expect(find.text('Stars'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });

  group('ProfileDetails', () {
    late MockUserViewModel userViewModel;
    late MockIngredientViewModel ingredientViewModel;

    setUp(() {
      userViewModel = MockUserViewModel();
      ingredientViewModel = MockIngredientViewModel();
      userViewModel.setUser(
        User(
          id: 'id',
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          fridgeId: 'f',
          cookbookId: 'c',
        ),
      );
      ingredientViewModel.setLoading(false);
    });

    testWidgets('shows error when userStats is null', (tester) async {
      userViewModel.setUserStats(null);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(user: userViewModel.user!),
          ),
        ),
      );
      expect(find.text('Failed to load user stats'), findsOneWidget);
    });

    testWidgets('shows loading when ingredientViewModel isLoading',
        (tester) async {
      userViewModel.setUserStats({});
      ingredientViewModel.setLoading(true);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(user: userViewModel.user!),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onFriendsTap when friends is tapped', (tester) async {
      userViewModel.setUserStats({
        'ingredientCount': 1,
        'recipeCount': 2,
        'favoriteRecipeCount': 3,
        'friendCount': 4,
        'mostPopularIngredients': [],
      });
      bool tapped = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(
              user: userViewModel.user!,
              friendsClickable: true,
              onFriendsTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Friends'));
      expect(tapped, isTrue);
    });

    testWidgets('shows default profile image when profilePicture is null',
        (tester) async {
      userViewModel.setUser(
        User(
          id: 'id',
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          fridgeId: 'f',
          cookbookId: 'c',
          profilePicture: null,
        ),
      );
      userViewModel.setUserStats({
        'ingredientCount': 1,
        'recipeCount': 2,
        'favoriteRecipeCount': 3,
        'friendCount': 4,
        'mostPopularIngredients': [],
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(user: userViewModel.user!),
          ),
        ),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('shows "No popular ingredients yet." when list is empty',
        (tester) async {
      userViewModel.setUserStats({
        'ingredientCount': 1,
        'recipeCount': 2,
        'favoriteRecipeCount': 3,
        'friendCount': 4,
        'mostPopularIngredients': [],
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(user: userViewModel.user!),
          ),
        ),
      );
      expect(find.text('No popular ingredients yet.'), findsOneWidget);
    });

    testWidgets('renders with a profile picture', (tester) async {
      userViewModel.setUser(
        User(
          id: 'id',
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          fridgeId: 'f',
          cookbookId: 'c',
          profilePicture: 'profile_pic.png',
        ),
      );
      userViewModel.setUserStats({
        'ingredientCount': 1,
        'recipeCount': 2,
        'favoriteRecipeCount': 3,
        'friendCount': 4,
        'mostPopularIngredients': [],
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(user: userViewModel.user!),
          ),
        ),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders join date', (tester) async {
      userViewModel.setUser(
        User(
          id: 'id',
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          fridgeId: 'f',
          cookbookId: 'c',
          joinDate: DateTime(2022, 1, 1),
        ),
      );
      userViewModel.setUserStats({
        'ingredientCount': 1,
        'recipeCount': 2,
        'favoriteRecipeCount': 3,
        'friendCount': 4,
        'mostPopularIngredients': [],
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(user: userViewModel.user!),
          ),
        ),
      );
      expect(find.textContaining('Joined'), findsOneWidget);
    });

    testWidgets('shows most popular ingredients with images', (tester) async {
      userViewModel.setUserStats({
        'ingredientCount': 1,
        'recipeCount': 2,
        'favoriteRecipeCount': 3,
        'friendCount': 4,
        'mostPopularIngredients': [
          {'name': 'tomato', 'count': 5},
          {'name': 'cheese', 'count': 3},
        ],
      });
      ingredientViewModel.ingredientMap = {
        'tomato': Ingredient(
            id: '1',
            name: 'tomato',
            category: 'Vegetable',
            imageURL: 'tomato.png',
            count: 0),
        'cheese': Ingredient(
          id: '2',
          name: 'cheese',
          category: 'Dairy',
          imageURL: 'cheese.png',
          count: 0,
        ),
      };
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProfileDetails(user: userViewModel.user!),
              ),
            ),
          ),
        ),
      );
      expect(find.textContaining('Tomato'), findsOneWidget);
      expect(find.textContaining('Cheese'), findsOneWidget);
      expect(find.text('(5)'), findsOneWidget);
      expect(find.text('(3)'), findsOneWidget);
    });

    testWidgets('does not call onFriendsTap when friendsClickable is false',
        (tester) async {
      userViewModel.setUserStats({
        'ingredientCount': 1,
        'recipeCount': 2,
        'favoriteRecipeCount': 3,
        'friendCount': 4,
        'mostPopularIngredients': [],
      });
      bool tapped = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: ingredientViewModel),
          ],
          child: MaterialApp(
            home: ProfileDetails(
              user: userViewModel.user!,
              friendsClickable: false,
              onFriendsTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Friends'));
      expect(tapped, isFalse);
    });

    testWidgets(
      'shows fallback image for popular ingredient with missing image',
      (tester) async {
        userViewModel.setUserStats({
          'ingredientCount': 1,
          'recipeCount': 2,
          'favoriteRecipeCount': 3,
          'friendCount': 4,
          'mostPopularIngredients': [
            {'name': 'unknown', 'count': 1},
          ],
        });
        ingredientViewModel.ingredientMap = {};
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
              ChangeNotifierProvider<IngredientViewModel>.value(
                  value: ingredientViewModel),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ProfileDetails(user: userViewModel.user!),
                ),
              ),
            ),
          ),
        );
        expect(find.byIcon(Icons.image_not_supported), findsWidgets);
      },
    );
  });

  group('SettingsMenu', () {
    testWidgets('renders all menu items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsMenu(),
          ),
        ),
      );
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('taps Profile', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(
                value: MockUserViewModel()),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: MockIngredientViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>.value(
                value: MockConnectivityProvider()),
            ChangeNotifierProvider<AuthViewModel>.value(
                value: MockAuthViewModel()),
          ],
          child: MaterialApp(
            home: Scaffold(body: SettingsMenu()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Profile'));
      await tester.pumpAndSettle();
      // Optionally, check for navigation or dialog
    });

    testWidgets('taps Preferences', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(
                value: MockUserViewModel()),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: MockIngredientViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>.value(
                value: MockConnectivityProvider()),
            ChangeNotifierProvider<AuthViewModel>.value(
                value: MockAuthViewModel()),
          ],
          child: MaterialApp(
            home: Scaffold(body: SettingsMenu()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Preferences'));
      await tester.pumpAndSettle();
    });

    testWidgets('taps Notifications', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(
                value: MockUserViewModel()),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: MockIngredientViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>.value(
                value: MockConnectivityProvider()),
            ChangeNotifierProvider<AuthViewModel>.value(
                value: MockAuthViewModel()),
          ],
          child: MaterialApp(
            home: Scaffold(body: SettingsMenu()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Notifications'));
      await tester.pumpAndSettle();
    });

    testWidgets('taps Logout', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(
                value: MockUserViewModel()),
            ChangeNotifierProvider<IngredientViewModel>.value(
                value: MockIngredientViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>.value(
                value: MockConnectivityProvider()),
            ChangeNotifierProvider<AuthViewModel>.value(
                value: MockAuthViewModel()),
          ],
          child: MaterialApp(
            home: Scaffold(body: SettingsMenu()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await tester.pumpAndSettle();
    });

    testWidgets('closes menu with close button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsMenu(),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      // The menu should be closed (Settings text not found)
      expect(find.text('Settings'), findsNothing);
    });
  });
}
