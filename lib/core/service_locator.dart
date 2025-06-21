import 'package:get_it/get_it.dart';
import 'package:snapchef/services/friend_service.dart';
import '../database/app_database.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_actions/cookbook_sync_actions.dart';
import '../providers/sync_actions/fridge_sync_actions.dart';
import '../providers/sync_actions/grocery_sync_actions.dart';
import '../providers/sync_actions/notification_sync_actions.dart';
import '../providers/sync_actions/shared_recipe_sync_actions.dart';
import '../providers/sync_provider.dart';
import '../repositories/cookbook_repository.dart';
import '../repositories/fridge_repository.dart';
import '../repositories/shared_recipe_repository.dart';
import '../repositories/user_repository.dart';
import '../services/backend_notification_service.dart';
import '../services/cookbook_service.dart';
import '../services/fridge_service.dart';
import '../services/ingredient_service.dart';
import '../services/shared_recipe_service.dart';
import '../services/sync_service.dart';
import '../services/user_service.dart';
import '../viewmodels/auth_viewmodel.dart';

final GetIt getIt = GetIt.instance;

void setupLocator(AppDatabase db) { 
  // Singletons 
  getIt.registerSingleton<AppDatabase>(db);
  getIt.registerSingleton<ConnectivityProvider>(ConnectivityProvider());
  getIt.registerSingleton<SyncProvider>(SyncProvider());
  getIt.registerSingleton<SyncManager>(SyncManager(getIt<ConnectivityProvider>()));
  
  // Ingredient Service
  getIt.registerLazySingleton<IngredientService>(() => IngredientService());
  
  // User  
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  getIt.registerLazySingleton<FriendService>(() => FriendService());
  
  // Fridge/Grocery
  getIt.registerLazySingleton<FridgeService>(() => FridgeService());
  getIt.registerLazySingleton<FridgeSyncActions>(() => FridgeSyncActions(getIt<FridgeService>()));
  getIt.registerLazySingleton<GrocerySyncActions>(() => GrocerySyncActions(getIt<FridgeService>()));
  getIt.registerLazySingleton<FridgeRepository>(() => FridgeRepository());
  
  // Cookbook/Shared Recipes
  getIt.registerLazySingleton<CookbookService>(() => CookbookService());  
  getIt.registerLazySingleton<CookbookRepository>(() => CookbookRepository()); 
  getIt.registerLazySingleton<CookbookSyncActions>(() => CookbookSyncActions(getIt<CookbookRepository>()));
  getIt.registerLazySingleton<SharedRecipeService>(() => SharedRecipeService());
  getIt.registerLazySingleton<SharedRecipeRepository>(() => SharedRecipeRepository());
  getIt.registerLazySingleton<SharedRecipeSyncActions>(() => SharedRecipeSyncActions(getIt<SharedRecipeRepository>()));

  // Notifications
  getIt.registerLazySingleton<NotificationSyncActions>(() => NotificationSyncActions(getIt<BackendNotificationService>()));
}