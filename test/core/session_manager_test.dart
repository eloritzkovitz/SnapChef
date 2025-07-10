import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/core/session_manager.dart';
import 'package:snapchef/database/app_database.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_actions/cookbook_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/fridge_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/grocery_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/shared_recipe_sync_actions.dart';
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
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

// Import your mocks
import '../mocks/mock_app_database.dart';
import '../mocks/mock_connectivity_provider.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_sync_provider.dart';
import '../mocks/mock_main_viewmodel.dart';
import '../mocks/mock_auth_viewmodel.dart';
import '../mocks/mock_user_viewmodel.dart';
import '../mocks/mock_user_repository.dart';
import '../mocks/mock_friend_viewmodel.dart';
import '../mocks/mock_ingredient_viewmodel.dart';
import '../mocks/mock_fridge_viewmodel.dart';
import '../mocks/mock_fridge_repository.dart';
import '../mocks/mock_cookbook_viewmodel.dart';
import '../mocks/mock_cookbook_repository.dart';
import '../mocks/mock_recipe_viewmodel.dart';
import '../mocks/mock_shared_recipe_viewmodel.dart';
import '../mocks/mock_shared_recipe_repository.dart';
import '../mocks/mock_notifications_viewmodel.dart';

class MockSyncManager extends Mock implements SyncManager {
  MockSyncManager(ConnectivityProvider connectivityProvider);
}

void registerAllServiceLocatorTypes() {
  final getIt = GetIt.I;

  // Core and plugin-dependent
  getIt.registerSingleton<AppDatabase>(MockAppDatabase());
  getIt.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
  getIt.registerSingleton<SyncProvider>(MockSyncProvider());
  getIt.registerSingleton<SyncManager>(MockSyncManager(getIt<ConnectivityProvider>()));
  getIt.registerLazySingleton<SocketService>(() => MockSocketService());
  getIt.registerLazySingleton<MainViewModel>(() => MockMainViewModel());

  // User
  getIt.registerLazySingleton<AuthViewModel>(() => MockAuthViewModel());
  getIt.registerLazySingleton<UserViewModel>(() => MockUserViewModel());
  getIt.registerLazySingleton<UserService>(() => MockUserService());
  getIt.registerLazySingleton<UserRepository>(() => MockUserRepository());
  getIt.registerLazySingleton<FriendViewModel>(() => MockFriendViewModel());
  getIt.registerLazySingleton<FriendService>(() => MockFriendService());

  // Ingredient
  getIt.registerLazySingleton<IngredientViewModel>(() => MockIngredientViewModel());
  getIt.registerLazySingleton<IngredientService>(() => MockIngredientService());

  // Fridge/Grocery
  getIt.registerLazySingleton<FridgeViewModel>(() => MockFridgeViewModel());
  getIt.registerLazySingleton<FridgeService>(() => MockFridgeService());
  getIt.registerLazySingleton<FridgeSyncActions>(() => FridgeSyncActions(getIt<FridgeService>()));
  getIt.registerLazySingleton<GrocerySyncActions>(() => GrocerySyncActions(getIt<FridgeService>()));
  getIt.registerLazySingleton<FridgeRepository>(() => MockFridgeRepository());

  // Cookbook/Shared Recipes
  getIt.registerLazySingleton<CookbookViewModel>(() => MockCookbookViewModel());
  getIt.registerLazySingleton<CookbookService>(() => MockCookbookService());
  getIt.registerLazySingleton<CookbookRepository>(() => MockCookbookRepository());
  getIt.registerLazySingleton<CookbookSyncActions>(() => CookbookSyncActions(getIt<CookbookRepository>()));
  getIt.registerLazySingleton<RecipeViewModel>(() => MockRecipeViewModel());
  getIt.registerLazySingleton<SharedRecipeViewModel>(() => MockSharedRecipeViewModel());
  getIt.registerLazySingleton<SharedRecipeService>(() => MockSharedRecipeService());
  getIt.registerLazySingleton<SharedRecipeRepository>(() => MockSharedRecipeRepository());
  getIt.registerLazySingleton<SharedRecipeSyncActions>(() => SharedRecipeSyncActions(getIt<SharedRecipeRepository>()));

  // Notifications
  getIt.registerLazySingleton<NotificationsViewModel>(() => MockNotificationsViewModel());
  // Add NotificationSyncActions and BackendNotificationService mocks if you have them
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load();

  setUp(() {
    GetIt.I.reset();
    registerAllServiceLocatorTypes();
  });

  test('clearSession clears database, preferences, tokens, and viewmodels', () async { 
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('accessToken', 'abc');
    await prefs.setString('refreshToken', 'xyz');

    await SessionManager.clearSession();

    expect(prefs.getString('accessToken'), isNull);
    expect(prefs.getString('refreshToken'), isNull);    
    expect(prefs.getKeys(), isEmpty);
  });
}