import 'package:get_it/get_it.dart';
import 'database/app_database.dart';
import 'providers/connectivity_provider.dart';
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
  getIt.registerSingleton<SyncManager>(SyncManager(getIt<ConnectivityProvider>()));
  
  // Ingredient Service
  getIt.registerLazySingleton<IngredientService>(() => IngredientService());
  
  // User
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  
  // Fridge
  getIt.registerLazySingleton<FridgeService>(() => FridgeService());
  getIt.registerLazySingleton<FridgeRepository>(() => FridgeRepository());
  
  // Cookbook
  getIt.registerLazySingleton<CookbookService>(() => CookbookService());
  getIt.registerLazySingleton<CookbookRepository>(() => CookbookRepository());
}