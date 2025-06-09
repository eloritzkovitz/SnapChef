import 'package:get_it/get_it.dart';
import 'database/app_database.dart';
import 'providers/connectivity_provider.dart';
import 'providers/sync_actions/fridge_sync_actions.dart';
import 'providers/sync_actions/grocery_sync_actions.dart';
import 'providers/sync_provider.dart';
import 'repositories/cookbook_repository.dart';
import 'repositories/fridge_repository.dart';
import 'repositories/user_repository.dart';
import 'services/cookbook_service.dart';
import 'services/fridge_service.dart';
import 'services/ingredient_service.dart';
import 'services/sync_service.dart';
import 'services/user_service.dart';

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
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  
  // Fridge/Grocery
  getIt.registerLazySingleton<FridgeService>(() => FridgeService());
  getIt.registerLazySingleton<FridgeSyncActions>(() => FridgeSyncActions(getIt<FridgeService>()));
  getIt.registerLazySingleton<GrocerySyncActions>(() => GrocerySyncActions(getIt<FridgeService>()));
  getIt.registerLazySingleton<FridgeRepository>(() => FridgeRepository());
  
  // Cookbook
  getIt.registerLazySingleton<CookbookService>(() => CookbookService());
  getIt.registerLazySingleton<CookbookRepository>(() => CookbookRepository());
}