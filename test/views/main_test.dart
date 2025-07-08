import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/database/app_database.dart';
import 'package:snapchef/main.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/repositories/cookbook_repository.dart';
import 'package:snapchef/repositories/fridge_repository.dart';
import 'package:snapchef/repositories/shared_recipe_repository.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/cookbook_service.dart';
import 'package:snapchef/services/fridge_service.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/services/notification_service.dart';
import 'package:snapchef/services/shared_recipe_service.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/services/user_service.dart';
import 'package:snapchef/theme/app_theme.dart';
import 'package:snapchef/utils/firebase_messaging_util.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/auth/confirm_reset_screen.dart';
import 'package:snapchef/views/auth/login_screen.dart';
import 'package:snapchef/views/auth/otp_verification_screen.dart';
import 'package:snapchef/views/auth/reset_password_screen.dart';
import 'package:snapchef/views/auth/signup_screen.dart';
import 'package:snapchef/views/main/main_screen.dart';
import 'package:snapchef/views/splash/animated_splash_screen.dart';

// Import all your mock files here
import '../mocks/mock_app_database.dart';
import '../mocks/mock_auth_viewmodel.dart';
import '../mocks/mock_cookbook_viewmodel.dart';
import '../mocks/mock_fridge_viewmodel.dart';
import '../mocks/mock_friend_viewmodel.dart';
import '../mocks/mock_ingredient_service.dart';
import '../mocks/mock_main_viewmodel.dart';
import '../mocks/mock_notification_service.dart';
import '../mocks/mock_notifications_viewmodel.dart';
import '../mocks/mock_recipe_viewmodel.dart';
import '../mocks/mock_shared_recipe_viewmodel.dart';
import '../mocks/mock_socket_service.dart';
import '../mocks/mock_fridge_service.dart';
import '../mocks/mock_services.dart'
    hide MockFridgeService, MockSocketService, MockIngredientService;
import '../mocks/mock_connectivity_provider.dart';
import '../mocks/mock_fridge_repository.dart';
import '../mocks/mock_cookbook_repository.dart';
import '../mocks/mock_shared_recipe_repository.dart';
import '../mocks/mock_user_repository.dart';
import '../mocks/mock_user_viewmodel.dart';
import '../viewmodels/cookbook_viewmodel_test.mocks.dart'
    hide
        MockAppDatabase,
        MockConnectivityProvider,
        MockCookbookRepository,
        MockSyncManager;
import '../viewmodels/fridge_viewmodel_test.mocks.dart'
    hide
        MockConnectivityProvider,
        MockSyncManager,
        MockSyncProvider,
        MockFridgeService,
        MockFridgeRepository;

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'IMAGE_BASE_URL=https://example.com/');
    final getIt = GetIt.instance;

    // Core/Providers/Managers
    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerSingleton<AppDatabase>(MockAppDatabase());
    }
    if (!getIt.isRegistered<ConnectivityProvider>()) {
      getIt.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
    }
    if (!getIt.isRegistered<SyncProvider>()) {
      getIt.registerSingleton<SyncProvider>(MockSyncProvider());
    }
    if (!getIt.isRegistered<SyncManager>()) {
      getIt.registerSingleton<SyncManager>(MockSyncManager());
    }
    if (!getIt.isRegistered<SocketService>()) {
      getIt.registerSingleton<SocketService>(MockSocketService());
    }
    if (!getIt.isRegistered<MainViewModel>()) {
      getIt.registerSingleton<MainViewModel>(MockMainViewModel());
    }

    // User
    if (!getIt.isRegistered<AuthViewModel>()) {
      getIt.registerSingleton<AuthViewModel>(MockAuthViewModel());
    }
    if (!getIt.isRegistered<UserViewModel>()) {
      getIt.registerSingleton<UserViewModel>(MockUserViewModel());
    }
    if (!getIt.isRegistered<UserService>()) {
      getIt.registerSingleton<UserService>(MockUserService());
    }
    if (!getIt.isRegistered<UserRepository>()) {
      getIt.registerSingleton<UserRepository>(MockUserRepository());
    }
    if (!getIt.isRegistered<FriendViewModel>()) {
      getIt.registerSingleton<FriendViewModel>(MockFriendViewModel());
    }
    if (!getIt.isRegistered<FriendService>()) {
      getIt.registerSingleton<FriendService>(MockFriendService());
    }

    // Ingredient
    if (!getIt.isRegistered<IngredientViewModel>()) {
      getIt.registerSingleton<IngredientViewModel>(MockIngredientViewModel());
    }
    if (!getIt.isRegistered<IngredientService>()) {
      getIt.registerSingleton<IngredientService>(MockIngredientService());
    }

    // Fridge
    if (!getIt.isRegistered<FridgeViewModel>()) {
      getIt.registerSingleton<FridgeViewModel>(MockFridgeViewModel());
    }
    if (!getIt.isRegistered<FridgeService>()) {
      getIt.registerSingleton<FridgeService>(MockFridgeService());
    }
    if (!getIt.isRegistered<FridgeRepository>()) {
      getIt.registerSingleton<FridgeRepository>(MockFridgeRepository());
    }

    // Recipe
    if (!getIt.isRegistered<RecipeViewModel>()) {
      getIt.registerSingleton<RecipeViewModel>(MockRecipeViewModel());
    }

    // Cookbook
    if (!getIt.isRegistered<CookbookViewModel>()) {
      getIt.registerSingleton<CookbookViewModel>(MockCookbookViewModel());
    }
    if (!getIt.isRegistered<CookbookService>()) {
      getIt.registerSingleton<CookbookService>(MockCookbookService());
    }
    if (!getIt.isRegistered<CookbookRepository>()) {
      getIt.registerSingleton<CookbookRepository>(MockCookbookRepository());
    }

    // Shared Recipe
    if (!getIt.isRegistered<SharedRecipeViewModel>()) {
      getIt.registerSingleton<SharedRecipeViewModel>(
          MockSharedRecipeViewModel());
    }
    if (!getIt.isRegistered<SharedRecipeService>()) {
      getIt.registerSingleton<SharedRecipeService>(MockSharedRecipeService());
    }
    if (!getIt.isRegistered<SharedRecipeRepository>()) {
      getIt.registerSingleton<SharedRecipeRepository>(
          MockSharedRecipeRepository());
    }

    // Notifications
    if (!getIt.isRegistered<NotificationService>()) {
      getIt.registerSingleton<NotificationService>(MockNotificationService());
    }
    if (!getIt.isRegistered<NotificationsViewModel>()) {
      getIt.registerSingleton<NotificationsViewModel>(
          MockNotificationsViewModel());
    }

    // Patch FirebaseMessagingUtil to prevent real Firebase calls in widget tests
    requestNotificationPermissions = () async {};
    getDeviceToken = () async => 'test_token';
    listenForForegroundMessages = () {};
    firebaseMessagingBackgroundHandler = (msg) async {};
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('App starts and shows splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedSplashScreen), findsOneWidget);
  });

  testWidgets('Navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)),
        child: MaterialApp(
          home: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: MyApp(
                  initialRoute: '/login',
                  loginScreenGoogleButton: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Sign in with Google (Test)'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Navigates to SignupScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/signup'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);
  });

  testWidgets('Navigates to ResetPasswordScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/reset-password'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
  });

  testWidgets('Navigates to ConfirmResetScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/confirm-reset'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmResetScreen), findsOneWidget);
  });

  testWidgets('Navigates to MainScreen', (WidgetTester tester) async {
    final mockNotificationsViewModel = GetIt.I<NotificationsViewModel>();
    final mockConnectivityProvider =
        GetIt.I<ConnectivityProvider>() as MockConnectivityProvider;
    final mockUserViewModel =
        MockUserViewModel(connectivityProvider: mockConnectivityProvider);
    final mockMainViewModel = GetIt.I<MainViewModel>();
    final mockIngredientViewModel = GetIt.I<IngredientViewModel>();
    final mockFridgeViewModel = GetIt.I<FridgeViewModel>();
    final mockRecipeViewModel = GetIt.I<RecipeViewModel>();
    final mockCookbookViewModel = GetIt.I<CookbookViewModel>();

    // Set the connectivity state for your handwritten mock    
    mockConnectivityProvider.isOffline = false;

    // Register the same mockUserViewModel instance in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<UserViewModel>()) {
      getIt.unregister<UserViewModel>();
    }
    getIt.registerSingleton<UserViewModel>(mockUserViewModel);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationsViewModel>.value(
            value: mockNotificationsViewModel,
          ),
          ChangeNotifierProvider<UserViewModel>.value(
            value: mockUserViewModel,
          ),
          ChangeNotifierProvider<MainViewModel>.value(
            value: mockMainViewModel,
          ),
          ChangeNotifierProvider<ConnectivityProvider>.value(
            value: mockConnectivityProvider,
          ),
          ChangeNotifierProvider<IngredientViewModel>.value(
            value: mockIngredientViewModel,
          ),
          ChangeNotifierProvider<FridgeViewModel>.value(
            value: mockFridgeViewModel,
          ),
          ChangeNotifierProvider<RecipeViewModel>.value(
            value: mockRecipeViewModel,
          ),
          ChangeNotifierProvider<CookbookViewModel>.value(
            value: mockCookbookViewModel,
          ),
        ],
        child: const MyApp(initialRoute: '/main'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('Navigates to OtpVerificationScreen',
      (WidgetTester tester) async {
    final mockNotificationsViewModel = GetIt.I<NotificationsViewModel>();
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationsViewModel>.value(
        value: mockNotificationsViewModel,
        child: const MyApp(
          initialRoute: '/verify',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
  });

  testWidgets('App uses appTheme', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme, appTheme);
  });
}
