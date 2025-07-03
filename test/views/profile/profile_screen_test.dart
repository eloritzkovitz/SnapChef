import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/database/app_database.dart' hide User;
import 'package:snapchef/models/user.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/socket_service.dart';
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
}
