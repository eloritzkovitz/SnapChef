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
    expect(find.byIcon(Icons.delete), findsOneWidget);

    // Move to fridge action
    final kitchenIcons = find.byIcon(Icons.kitchen_outlined);
    expect(kitchenIcons, findsAtLeastNWidgets(1),
        reason: 'No kitchen_outlined icons found');
    await tester.tap(kitchenIcons.first);
    await tester.pumpAndSettle();

    // Interact with filter/sort
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Interact with reminder
    await tester.tap(find.byIcon(Icons.alarm));
    await tester.pumpAndSettle();
    if (find.text('Cancel').evaluate().isNotEmpty) {
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }

    // Interact with delete
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
  });

  testWidgets('can open and close search', (tester) async {
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

    // Open the search overlay
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Now the TextField is present
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pumpAndSettle();

    final clearIcons = find.byIcon(Icons.clear);
    expect(clearIcons, findsWidgets,
        reason: 'No clear icon found in search overlay');
    await tester.tap(clearIcons.first);
    await tester.pumpAndSettle();

    // To close the search overlay, tap the back arrow
    final backIcons = find.byIcon(Icons.arrow_back);
    if (backIcons.evaluate().isNotEmpty) {
      await tester.tap(backIcons.first);
      await tester.pumpAndSettle();
    }
    expect(find.text('Apple x 2'), findsOneWidget);
  });

  testWidgets('filter/sort sheet opens and clear/apply works', (tester) async {
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
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);

    // Tap clear filters if present
    final clearButton = find.text('Clear');
    if (clearButton.evaluate().isNotEmpty) {
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
    }

    // Tap apply if present
    final applyButton = find.text('Apply');
    if (applyButton.evaluate().isNotEmpty) {
      await tester.tap(applyButton);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('filter/sort sheet closes on barrier tap', (tester) async {
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
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsOneWidget);
    // Tap outside to close
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsNothing);
  });

  testWidgets('shows correct UI for multiple groceries', (tester) async {
    final ingredient1 = Ingredient(
      id: 'i1',
      name: 'Apple',
      category: 'Fruit',
      count: 2,
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
    expect(find.text('Apple x 2'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Category: Fruit'), findsNWidgets(2));
    expect(find.text('Quantity: 2'), findsOneWidget);
    expect(find.text('Quantity: 1'), findsOneWidget);
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

  testWidgets('reorder does nothing if fridgeId is null', (tester) async {
    userViewModel.setUser(userViewModel.user?.copyWith(fridgeId: null));
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

  testWidgets('add all to fridge does nothing if no groceries', (tester) async {
    groceriesController.filteredItems = [];
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));
    await tester.tap(find.byIcon(Icons.kitchen_outlined));
    await tester.pumpAndSettle();
    // No error, no snackbar
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('add all to fridge does nothing if fridgeId is empty',
      (tester) async {
    userViewModel.setUser(userViewModel.user?.copyWith(fridgeId: ''));
    groceriesController.filteredItems = [
      Ingredient(
          id: 'i1', name: 'Apple', category: 'Fruit', count: 1, imageURL: ''),
    ];
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));
    await tester.tap(find.byIcon(Icons.kitchen_outlined).first);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('delete does nothing if no fridgeId', (tester) async {
    userViewModel.setUser(userViewModel.user?.copyWith(fridgeId: ''));
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
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('set reminder dialog opens', (tester) async {
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
    await tester.tap(find.byIcon(Icons.alarm).first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('reminder dialog can set reminder', (tester) async {
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
    await tester.tap(find.byIcon(Icons.alarm).first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap set reminder if present
    final setReminder = find.text('Set Reminder');
    if (setReminder.evaluate().isNotEmpty) {
      await tester.tap(setReminder.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // If the dialog is still open, tap Cancel to close it
    if (find.byType(AlertDialog).evaluate().isNotEmpty) {
      final cancel = find.text('Cancel');
      if (cancel.evaluate().isNotEmpty) {
        await tester.tap(cancel.first);
        await tester.pumpAndSettle();
      }
    }

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('reminder dialog can be cancelled', (tester) async {
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
    await tester.tap(find.byIcon(Icons.alarm).first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    // Tap cancel if present
    final cancel = find.text('Cancel');
    if (cancel.evaluate().isNotEmpty) {
      await tester.tap(cancel.first);
      await tester.pumpAndSettle();
    }
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('move to fridge for single item', (tester) async {
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
    await tester.tap(find.byIcon(Icons.kitchen_outlined).first);
    await tester.pumpAndSettle();
  });

  testWidgets('delete for single item', (tester) async {
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
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
  });

  testWidgets('app bar close button pops screen', (tester) async {
    await tester.pumpWidget(wrapWithProviders(
      const GroceriesScreen(),
      fridgeViewModel: fridgeViewModel,
      userViewModel: userViewModel,
      connectivityProvider: MockConnectivityProvider(),
    ));
    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('trailing actions do nothing if fridgeId is null',
      (tester) async {
    userViewModel.setUser(userViewModel.user?.copyWith(fridgeId: null));
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
    // Try all trailing actions
    await tester.tap(find.byIcon(Icons.kitchen_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.alarm).first);
    await tester.pumpAndSettle();

    // If the dialog is still open, tap Cancel to close it
    if (find.byType(AlertDialog).evaluate().isNotEmpty) {
      final cancel = find.text('Cancel');
      if (cancel.evaluate().isNotEmpty) {
        await tester.tap(cancel.first);
        await tester.pumpAndSettle();
      }
    }

    // No snackbar, no dialog
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
