import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapchef/database/app_database.dart' hide Ingredient;
import 'package:snapchef/repositories/fridge_repository.dart';
import 'package:snapchef/services/fridge_service.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/views/fridge/fridge_screen.dart';
import 'package:snapchef/views/fridge/widgets/fridge_grid_view.dart';
import 'package:snapchef/views/fridge/widgets/fridge_list_view.dart';
import 'package:snapchef/views/fridge/groceries_screen.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/models/ingredient.dart';

import '../../mocks/mock_app_database.dart';
import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_ingredient_service.dart';

// ---- Minimal mocks for GetIt dependencies ----
class MockFridgeRepository extends FridgeRepository {}

class MockFridgeService extends FridgeService {}

class MockIngredientViewModel extends IngredientViewModel {
  MockIngredientViewModel() : super();
}

Widget buildTestWidget({
  FridgeViewModel? fridgeViewModel,
  UserViewModel? userViewModel,
  ConnectivityProvider? connectivityProvider,
  IngredientViewModel? ingredientViewModel,
  Widget? child,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<FridgeViewModel>(
          create: (_) => fridgeViewModel ?? MockFridgeViewModel()),
      ChangeNotifierProvider<UserViewModel>(
          create: (_) => userViewModel ?? MockUserViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => connectivityProvider ?? MockConnectivityProvider()),
      ChangeNotifierProvider<IngredientViewModel>(
          create: (_) => ingredientViewModel ?? MockIngredientViewModel()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: child ?? const FridgeScreen(),
      ),
    ),
  );
}

void main() {
  setUp(() async {
    await dotenv.load();
    GetIt.I.reset();
    GetIt.I.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
    final db = MockAppDatabase();
    GetIt.I.registerSingleton<AppDatabase>(db);
    addTearDown(() async => await db.close());
    GetIt.I.registerSingleton<FridgeService>(MockFridgeService());
    GetIt.I.registerSingleton<FridgeRepository>(MockFridgeRepository());
    GetIt.I.registerSingleton<IngredientService>(MockIngredientService());
  });

  group('FridgeScreen', () {
    testWidgets('renders empty state', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.fridgeController.filteredItems = [];
      await tester.pumpWidget(buildTestWidget(fridgeViewModel: fridgeViewModel));
      await tester.pumpAndSettle();
      expect(find.text('No available ingredients'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows failed user state', (tester) async {
      final userViewModel = MockUserViewModel();
      userViewModel.setUser(null);
      await tester.pumpWidget(buildTestWidget(userViewModel: userViewModel));
      await tester.pumpAndSettle();
      expect(find.text('Failed to load user data'), findsOneWidget);
    });

    testWidgets('toggles between grid and list view', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.fridgeController.filteredItems = [
        Ingredient(
            id: '1',
            name: 'Egg',
            category: 'Dairy',
            count: 1,
            imageURL: 'https://example.com/egg.png'),
        Ingredient(
            id: '2',
            name: 'Milk',
            category: 'Dairy',
            count: 1,
            imageURL: 'https://example.com/milk.png'),
      ];
      await tester.pumpWidget(buildTestWidget(fridgeViewModel: fridgeViewModel));
      await tester.pumpAndSettle();
      expect(find.byType(FridgeGridView), findsOneWidget);
      await tester.tap(find.byTooltip('Switch to List View'));
      await tester.pumpAndSettle();
      expect(find.byType(FridgeListView), findsOneWidget);
    });

    testWidgets('opens groceries list', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      await tester.pumpWidget(buildTestWidget(fridgeViewModel: fridgeViewModel));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      expect(find.byType(GroceriesScreen), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });
  });

  group('GroceriesList', () {
    testWidgets('shows empty groceries state', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.groceriesController.filteredItems = [];
      await tester.pumpWidget(buildTestWidget(
          fridgeViewModel: fridgeViewModel, child: const GroceriesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('No groceries in your list.'), findsOneWidget);
    });

    testWidgets('shows groceries and allows reorder', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.groceriesController.filteredItems = [
        Ingredient(
            id: '3', name: 'Bread', category: 'Bakery', count: 1, imageURL: ''),
        Ingredient(
            id: '4', name: 'Apple', category: 'Fruit', count: 1, imageURL: ''),
      ];
      await tester.pumpWidget(buildTestWidget(
          fridgeViewModel: fridgeViewModel, child: const GroceriesScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Bread'), findsOneWidget);
      expect(find.textContaining('Apple'), findsOneWidget);
      expect(find.byType(ReorderableListView), findsOneWidget);
    });
  });

  group('FridgeGridView', () {
    testWidgets('renders ingredient cards', (tester) async {
      final ingredients = [
        Ingredient(
            id: '1', name: 'Egg', category: 'Dairy', count: 1, imageURL: ''),
        Ingredient(
            id: '2', name: 'Milk', category: 'Dairy', count: 1, imageURL: ''),
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeGridView(
            ingredients: ingredients,
            fridgeId: 'fridge123',
            viewModel: MockFridgeViewModel(),
            onDelete: (_) {},
            onSetExpiryAlert: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Egg'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });
  });

  group('FridgeListView', () {
    testWidgets('renders ingredient list tiles', (tester) async {
      final ingredients = [
        Ingredient(
            id: '1', name: 'Egg', category: 'Dairy', count: 1, imageURL: ''),
        Ingredient(
            id: '2', name: 'Milk', category: 'Dairy', count: 1, imageURL: ''),
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeListView(
            ingredients: ingredients,
            fridgeId: 'fridge123',
            viewModel: MockFridgeViewModel(),
            onDelete: (_) {},
            onSetExpiryAlert: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Egg'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });
  });
}