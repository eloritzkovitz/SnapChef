import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/core/service_locator.dart';
import 'package:snapchef/database/app_database.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/friend_viewmodel.dart';
import 'package:snapchef/services/user_service.dart';
import 'package:snapchef/services/cookbook_service.dart';
import 'package:snapchef/services/fridge_service.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/services/shared_recipe_service.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/backend_notification_service.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart' hide getIt;
import 'package:snapchef/providers/sync_actions/cookbook_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/fridge_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/grocery_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/notification_sync_actions.dart';
import 'package:snapchef/providers/sync_actions/shared_recipe_sync_actions.dart';
import 'package:snapchef/repositories/cookbook_repository.dart';
import 'package:snapchef/repositories/fridge_repository.dart';
import 'package:snapchef/repositories/shared_recipe_repository.dart';
import 'package:snapchef/repositories/user_repository.dart';

class DummyDatabase extends AppDatabase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load();

  test('setupLocator registers all dependencies', () {
    setupLocator(DummyDatabase());

    getIt.registerLazySingleton<BackendNotificationService>(() => BackendNotificationService(baseUrl: 'https://example.com'));

    // Check a few key registrations
    expect(getIt<UserViewModel>(), isA<UserViewModel>());
    expect(getIt<MainViewModel>(), isA<MainViewModel>());
    expect(getIt<NotificationsViewModel>(), isA<NotificationsViewModel>());
    expect(getIt<AuthViewModel>(), isA<AuthViewModel>());
    expect(getIt<CookbookViewModel>(), isA<CookbookViewModel>());
    expect(getIt<FridgeViewModel>(), isA<FridgeViewModel>());
    expect(getIt<IngredientViewModel>(), isA<IngredientViewModel>());
    expect(getIt<RecipeViewModel>(), isA<RecipeViewModel>());
    expect(getIt<SharedRecipeViewModel>(), isA<SharedRecipeViewModel>());
    expect(getIt<FriendViewModel>(), isA<FriendViewModel>());
    expect(getIt<UserService>(), isA<UserService>());
    expect(getIt<CookbookService>(), isA<CookbookService>());
    expect(getIt<FridgeService>(), isA<FridgeService>());
    expect(getIt<IngredientService>(), isA<IngredientService>());
    expect(getIt<SharedRecipeService>(), isA<SharedRecipeService>());
    expect(getIt<FriendService>(), isA<FriendService>());
    expect(getIt<BackendNotificationService>(), isA<BackendNotificationService>());
    expect(getIt<SocketService>(), isA<SocketService>());
    expect(getIt<SyncManager>(), isA<SyncManager>());
    expect(getIt<ConnectivityProvider>(), isA<ConnectivityProvider>());
    expect(getIt<SyncProvider>(), isA<SyncProvider>());
    expect(getIt<CookbookSyncActions>(), isA<CookbookSyncActions>());
    expect(getIt<FridgeSyncActions>(), isA<FridgeSyncActions>());
    expect(getIt<GrocerySyncActions>(), isA<GrocerySyncActions>());
    expect(getIt<NotificationSyncActions>(), isA<NotificationSyncActions>());
    expect(getIt<SharedRecipeSyncActions>(), isA<SharedRecipeSyncActions>());
    expect(getIt<CookbookRepository>(), isA<CookbookRepository>());
    expect(getIt<FridgeRepository>(), isA<FridgeRepository>());
    expect(getIt<SharedRecipeRepository>(), isA<SharedRecipeRepository>());
    expect(getIt<UserRepository>(), isA<UserRepository>());
    expect(getIt<AppDatabase>(), isA<DummyDatabase>());
  });
}
