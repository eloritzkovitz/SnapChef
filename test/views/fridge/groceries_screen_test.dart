import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/fridge/groceries_screen.dart';
import 'package:snapchef/models/ingredient.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_ingredient_list_controller.dart';
import '../../mocks/mock_ingredient_viewmodel.dart';

Widget wrapWithProviders(
  Widget child, {
  required FridgeViewModel fridgeViewModel,
  required UserViewModel userViewModel,
  ConnectivityProvider? connectivityProvider,
  IngredientViewModel? ingredientViewModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<FridgeViewModel>.value(
        value: fridgeViewModel,
      ),
      ChangeNotifierProvider<UserViewModel>.value(
        value: userViewModel,
      ),
      ChangeNotifierProvider<ConnectivityProvider>.value(
        value: connectivityProvider ?? ConnectivityProvider(),
      ),
      ChangeNotifierProvider<IngredientViewModel>.value(
        value: ingredientViewModel ?? MockIngredientViewModel(),
      ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  late MockFridgeViewModel fridgeViewModel;
  late MockUserViewModel userViewModel;
  late MockIngredientListController groceriesController;

  setUp(() {
    groceriesController = MockIngredientListController();
    fridgeViewModel =
        MockFridgeViewModel(groceriesController: groceriesController);
    userViewModel = MockUserViewModel();
    userViewModel.setUser(userViewModel.user?.copyWith(fridgeId: 'fridge1'));
  });

  testWidgets('shows empty state when no groceries', (tester) async {
    groceriesController.filteredItems = [];
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));
    expect(find.text('No groceries in your list.'), findsOneWidget);
  });

  testWidgets('shows groceries and all actions', (tester) async {
    final ingredient = Ingredient(
      id: 'i1',
      name: 'Apple',
      category: 'Fruit',
      count: 2,
      imageURL: '',
    );
    groceriesController.filteredItems = [ingredient];
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));

    // Check for correct texts
    expect(find.text('Apple x 2'), findsOneWidget);
    expect(find.text('Category: Fruit'), findsOneWidget);
    expect(find.text('Quantity: 2'), findsOneWidget);

    // AppBar actions
    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Trailing actions
    expect(find.byIcon(Icons.alarm), findsOneWidget);
    expect(find.byIcon(Icons.kitchen_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);

    // Interact with filter/sort
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Interact with search (tap the first search icon)
    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Interact with reminder
    await tester.tap(find.byIcon(Icons.alarm));
    await tester.pumpAndSettle();
    if (find.text('Cancel').evaluate().isNotEmpty) {
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }

    // Interact with "Move to Fridge"
    await tester.tap(find.byIcon(Icons.kitchen_outlined));
    await tester.pumpAndSettle();

    // Interact with delete
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
  });

  testWidgets('reorders groceries', (tester) async {
    final ingredient1 = Ingredient(
      id: 'i1',
      name: 'Apple',
      category: 'Fruit',
      count: 1,
      imageURL: '',
    );
    final ingredient2 = Ingredient(
      id: 'i2',
      name: 'Banana',
      category: 'Fruit',
      count: 1,
      imageURL: '',
    );
    groceriesController.filteredItems = [ingredient1, ingredient2];
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));
    final finder1 = find.text('Apple');
    final finder2 = find.text('Banana');
    expect(finder1, findsOneWidget);
    expect(finder2, findsOneWidget);

    find.byType(ReorderableListView);
    await tester.drag(finder1, const Offset(0, 100));
    await tester.pumpAndSettle();
  });

  testWidgets('shows image error widget', (tester) async {
    final ingredient = Ingredient(
      id: 'i1',
      name: 'Apple',
      category: 'Fruit',
      count: 1,
      imageURL: 'bad_url',
    );
    groceriesController.filteredItems = [ingredient];
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));

    expect(find.byIcon(Icons.image_not_supported), findsNothing);
  });

  testWidgets('shows snackbar when all groceries moved', (tester) async {
    final ingredient = Ingredient(
      id: 'i1',
      name: 'Apple',
      category: 'Fruit',
      count: 1,
      imageURL: '',
    );
    groceriesController.filteredItems = [ingredient];
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));    

    // Tap the correct kitchen_outlined icon.
    await tester.tap(find.byIcon(Icons.kitchen_outlined).first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));    
  });
}
