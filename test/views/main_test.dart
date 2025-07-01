import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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
import 'package:snapchef/services/shared_recipe_service.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/services/user_service.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/splash/animated_splash_screen.dart';

// Import all your mock files here
import '../mocks/mock_app_database.dart';
import '../mocks/mock_auth_viewmodel.dart';
import '../mocks/mock_cookbook_viewmodel.dart';
import '../mocks/mock_fridge_viewmodel.dart';
import '../mocks/mock_friend_viewmodel.dart';
import '../mocks/mock_ingredient_service.dart';
import '../mocks/mock_main_viewmodel.dart';
import '../mocks/mock_notifications_viewmodel.dart';
import '../mocks/mock_shared_recipe_viewmodel.dart';
import '../mocks/mock_socket_service.dart';
import '../mocks/mock_fridge_service.dart';
import '../mocks/mock_services.dart' hide MockFridgeService, MockSocketService, MockIngredientService;
import '../mocks/mock_connectivity_provider.dart';
import '../mocks/mock_fridge_repository.dart';
import '../mocks/mock_cookbook_repository.dart';
import '../mocks/mock_shared_recipe_repository.dart';
import '../mocks/mock_user_repository.dart';
import '../viewmodels/cookbook_viewmodel_test.mocks.dart' hide MockAppDatabase, MockConnectivityProvider, MockCookbookRepository, MockSyncManager;
import '../viewmodels/fridge_viewmodel_test.mocks.dart' hide MockConnectivityProvider, MockSyncManager, MockSyncProvider, MockFridgeService, MockFridgeRepository;
import '../viewmodels/friend_viewmodel_test.mocks.dart' hide MockFriendService;


void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'IMAGE_BASE_URL=https://example.com/');
    final getIt = GetIt.instance;

    // Core/Providers/Managers
    if (!getIt.isRegistered<AppDatabase>()) getIt.registerSingleton<AppDatabase>(MockAppDatabase());
    if (!getIt.isRegistered<ConnectivityProvider>()) getIt.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
    if (!getIt.isRegistered<SyncProvider>()) getIt.registerSingleton<SyncProvider>(MockSyncProvider());
    if (!getIt.isRegistered<SyncManager>()) getIt.registerSingleton<SyncManager>(MockSyncManager());
    if (!getIt.isRegistered<SocketService>()) getIt.registerSingleton<SocketService>(MockSocketService());
    if (!getIt.isRegistered<MainViewModel>()) getIt.registerSingleton<MainViewModel>(MockMainViewModel());

    // User
    if (!getIt.isRegistered<AuthViewModel>()) getIt.registerSingleton<AuthViewModel>(MockAuthViewModel());
    if (!getIt.isRegistered<UserViewModel>()) getIt.registerSingleton<UserViewModel>(MockUserViewModel());
    if (!getIt.isRegistered<UserService>()) getIt.registerSingleton<UserService>(MockUserService());
    if (!getIt.isRegistered<UserRepository>()) getIt.registerSingleton<UserRepository>(MockUserRepository());
    if (!getIt.isRegistered<FriendViewModel>()) getIt.registerSingleton<FriendViewModel>(MockFriendViewModel());
    if (!getIt.isRegistered<FriendService>()) getIt.registerSingleton<FriendService>(MockFriendService());

    // Ingredient
    if (!getIt.isRegistered<IngredientViewModel>()) getIt.registerSingleton<IngredientViewModel>(MockIngredientViewModel());
    if (!getIt.isRegistered<IngredientService>()) getIt.registerSingleton<IngredientService>(MockIngredientService());

    // Fridge
    if (!getIt.isRegistered<FridgeViewModel>()) getIt.registerSingleton<FridgeViewModel>(MockFridgeViewModel());
    if (!getIt.isRegistered<FridgeService>()) getIt.registerSingleton<FridgeService>(MockFridgeService());
    if (!getIt.isRegistered<FridgeRepository>()) getIt.registerSingleton<FridgeRepository>(MockFridgeRepository());

    // Cookbook
    if (!getIt.isRegistered<CookbookViewModel>()) getIt.registerSingleton<CookbookViewModel>(MockCookbookViewModel());
    if (!getIt.isRegistered<CookbookService>()) getIt.registerSingleton<CookbookService>(MockCookbookService());
    if (!getIt.isRegistered<CookbookRepository>()) getIt.registerSingleton<CookbookRepository>(MockCookbookRepository());

    // Shared Recipe
    if (!getIt.isRegistered<SharedRecipeViewModel>()) getIt.registerSingleton<SharedRecipeViewModel>(MockSharedRecipeViewModel());
    if (!getIt.isRegistered<SharedRecipeService>()) getIt.registerSingleton<SharedRecipeService>(MockSharedRecipeService());
    if (!getIt.isRegistered<SharedRecipeRepository>()) getIt.registerSingleton<SharedRecipeRepository>(MockSharedRecipeRepository());

    // Notifications
    if (!getIt.isRegistered<NotificationsViewModel>()) getIt.registerSingleton<NotificationsViewModel>(MockNotificationsViewModel());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Check for the splash screen or any widget you expect at startup
    expect(find.byType(AnimatedSplashScreen), findsOneWidget);
  });
}