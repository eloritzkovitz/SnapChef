import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:snapchef/database/app_database.dart';
import 'package:snapchef/main.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/repositories/cookbook_repository.dart';
import 'package:snapchef/repositories/fridge_repository.dart';
import 'package:snapchef/repositories/shared_recipe_repository.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/views/splash/animated_splash_screen.dart';
import '../mocks/mock_app_database.dart';
import '../viewmodels/cookbook_viewmodel_test.mocks.dart' hide MockAppDatabase;
import '../viewmodels/fridge_viewmodel_test.mocks.dart' hide MockConnectivityProvider, MockSyncManager;
import '../viewmodels/ingredient_viewmodel_test.mocks.dart';
import '../viewmodels/shared_recipe_viewmodel_test.mocks.dart' hide MockConnectivityProvider, MockSyncManager;
import '../viewmodels/user_viewmodel_test.mocks.dart' hide MockConnectivityProvider, MockAppDatabase;

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'IMAGE_BASE_URL=https://example.com/');
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerSingleton<AppDatabase>(MockAppDatabase());
    }
    if (!getIt.isRegistered<SyncManager>()) {
      getIt.registerSingleton<SyncManager>(MockSyncManager());
    }
    if (!getIt.isRegistered<ConnectivityProvider>()) {
      getIt.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
    }
    if (!getIt.isRegistered<IngredientService>()) {
      getIt.registerSingleton<IngredientService>(MockIngredientService());
    }
    if (!getIt.isRegistered<UserRepository>()) {
      getIt.registerSingleton<UserRepository>(MockUserRepository());
    }
    if (!getIt.isRegistered<FridgeRepository>()) {
      getIt.registerSingleton<FridgeRepository>(MockFridgeRepository());
    }
    if (!getIt.isRegistered<CookbookRepository>()) {
      getIt.registerSingleton<CookbookRepository>(MockCookbookRepository());
    }
    if (!getIt.isRegistered<SharedRecipeRepository>()) {
      getIt.registerSingleton<SharedRecipeRepository>(MockSharedRecipeRepository());
    }
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('App starts and shows splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Check for the splash screen or any widget you expect at startup
    expect(find.byType(AnimatedSplashScreen), findsOneWidget);
  });
}
