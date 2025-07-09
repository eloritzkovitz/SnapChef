import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/views/fridge/ingredient_search_delegate.dart';

import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_ingredient_viewmodel.dart';

Widget wrapWithProviders(Widget child,
    {required MockIngredientViewModel ingredientViewModel,
    required MockUserViewModel userViewModel,
    required MockFridgeViewModel fridgeViewModel}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<IngredientViewModel>.value(
          value: ingredientViewModel),
      ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
      ChangeNotifierProvider<FridgeViewModel>.value(value: fridgeViewModel),
    ],
    child: MaterialApp(home: child),
  );
}

Future<void> openSearch(WidgetTester tester, IngredientSearchDelegate delegate,
    {required MockIngredientViewModel ingredientViewModel,
    required MockUserViewModel userViewModel,
    required MockFridgeViewModel fridgeViewModel}) async {
  await tester.pumpWidget(
    wrapWithProviders(
      Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch<Ingredient?>(
                    context: context,
                    delegate: delegate,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ingredientViewModel: ingredientViewModel,
      userViewModel: userViewModel,
      fridgeViewModel: fridgeViewModel,
    ),
  );
  expect(find.byIcon(Icons.search), findsOneWidget);
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();
}

Future<void> robustTapIngredientTile(
    WidgetTester tester, Finder ingredientTile) async {
  final scrollables = find.byType(Scrollable).evaluate().toList();
  if (scrollables.length == 1) {
    await tester.scrollUntilVisible(ingredientTile, 50,
        scrollable: find.byType(Scrollable));
  }
  await tester.ensureVisible(ingredientTile);
  await tester.pump(const Duration(milliseconds: 200));
  bool tapped = false;
  for (int i = 0; i < 3 && !tapped; i++) {
    try {
      tester.getCenter(ingredientTile);
      await tester.tap(ingredientTile);
      tapped = true;
    } catch (_) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }
  await tester.pumpAndSettle();
}

Future<void> expectSnackBarWithText(WidgetTester tester, String text) async {
  bool found = false;
  for (int i = 0; i < 10 && !found; i++) {
    await tester.pump(const Duration(milliseconds: 150));
    if (find.byType(SnackBar).evaluate().isNotEmpty &&
        find.text(text).evaluate().isNotEmpty) {
      found = true;
    }
  }
  if (!found) {
    final snackBars = find.byType(SnackBar).evaluate().toList();
    final allTexts = <String>[];
    for (final sb in snackBars) {
      final snackBar = sb.widget as SnackBar;
      final content = snackBar.content;
      if (content is Text) {
        allTexts.add(content.data ?? content.toString());
      } else {
        allTexts.add(content.toString());
      }
    }   
  }
  expect(find.byType(SnackBar), findsOneWidget, reason: 'SnackBar not found');
  expect(find.text(text), findsOneWidget,
      reason: 'SnackBar text "$text" not found');
}

Future<void> dismissSnackBar(WidgetTester tester) async {
  // Tap anywhere or pump until the SnackBar disappears
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.byType(SnackBar).evaluate().isEmpty) break;
  }
}

void main() {
  group('IngredientSearchDelegate', () {
    late MockIngredientViewModel ingredientViewModel;
    late MockUserViewModel userViewModel;
    late MockFridgeViewModel fridgeViewModel;
    late IngredientSearchDelegate delegate;

    setUp(() {
      ingredientViewModel = MockIngredientViewModel();
      userViewModel = MockUserViewModel();
      fridgeViewModel = MockFridgeViewModel();
      delegate = IngredientSearchDelegate();
    });

    testWidgets('shows loading indicator', (tester) async {
      ingredientViewModel.setLoading(true);
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) => delegate.buildSuggestions(context),
          ),
          ingredientViewModel: ingredientViewModel,
          userViewModel: userViewModel,
          fridgeViewModel: fridgeViewModel,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state for empty query', (tester) async {
      ingredientViewModel.setLoading(false);
      ingredientViewModel.clear();
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) => delegate.buildSuggestions(context),
          ),
          ingredientViewModel: ingredientViewModel,
          userViewModel: userViewModel,
          fridgeViewModel: fridgeViewModel,
        ),
      );
      expect(
          find.text('Start typing to search for ingredients'), findsOneWidget);
    });

    testWidgets('shows no suggestions for non-matching query', (tester) async {
      delegate.query = 'zzz';
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) => delegate.buildSuggestions(context),
          ),
          ingredientViewModel: ingredientViewModel,
          userViewModel: userViewModel,
          fridgeViewModel: fridgeViewModel,
        ),
      );
      expect(find.text('No suggestions available'), findsOneWidget);
    });

    testWidgets('shows suggestions with and without images', (tester) async {
      delegate.query = '';
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) => MaterialApp(
              home: Scaffold(body: delegate.buildSuggestions(context)),
            ),
          ),
          ingredientViewModel: ingredientViewModel,
          userViewModel: userViewModel,
          fridgeViewModel: fridgeViewModel,
        ),
      );
      expect(find.text('Mock Ingredient'), findsOneWidget);
      expect(find.text('Mock Ingredient 2'), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported), findsWidgets);
    });

    testWidgets('shows add to fridge/groceries dialog and handles success',
        (tester) async {
      fridgeViewModel.addGrocerySuccess = true;
      fridgeViewModel.addFridgeSuccess = true;
      ingredientViewModel.clear();
      ingredientViewModel.ingredients.add(
        Ingredient(
          id: 'i1',
          name: 'Mock Ingredient',
          category: 'Mock Category',
          imageURL: '',
          count: 1,
        ),
      );
      await openSearch(
        tester,
        delegate,
        ingredientViewModel: ingredientViewModel,
        userViewModel: userViewModel,
        fridgeViewModel: fridgeViewModel,
      );
      delegate.query = 'Mock Ingredient';
      await tester.pumpAndSettle();

      final ingredientTile = find.widgetWithText(ListTile, 'Mock Ingredient');
      expect(ingredientTile, findsOneWidget);
      await robustTapIngredientTile(tester, ingredientTile);

      final groceriesBtn = find.text('Add to Groceries');
      expect(groceriesBtn, findsOneWidget);
      await tester.tap(groceriesBtn);
      await tester.pumpAndSettle();

      await expectSnackBarWithText(
          tester, 'Mock Ingredient added to groceries');
      await dismissSnackBar(tester);

      // Tap the ingredient again for the fridge action
      expect(ingredientTile, findsOneWidget);
      await robustTapIngredientTile(tester, ingredientTile);

      final fridgeBtn = find.text('Add to Fridge');
      expect(fridgeBtn, findsOneWidget);
      await tester.tap(fridgeBtn);
      await tester.pumpAndSettle();

      await expectSnackBarWithText(tester, 'Mock Ingredient added to fridge');
    });

    testWidgets('handles add to groceries/fridge failure', (tester) async {
      fridgeViewModel.addGrocerySuccess = false;
      fridgeViewModel.addFridgeSuccess = false;
      ingredientViewModel.clear();
      ingredientViewModel.ingredients.add(
        Ingredient(
          id: 'i1',
          name: 'Mock Ingredient',
          category: 'Mock Category',
          imageURL: '',
          count: 1,
        ),
      );
      await openSearch(
        tester,
        delegate,
        ingredientViewModel: ingredientViewModel,
        userViewModel: userViewModel,
        fridgeViewModel: fridgeViewModel,
      );
      delegate.query = 'Mock Ingredient';
      await tester.pumpAndSettle();

      final ingredientTile = find.widgetWithText(ListTile, 'Mock Ingredient');
      expect(ingredientTile, findsOneWidget);
      await robustTapIngredientTile(tester, ingredientTile);

      final groceriesBtn = find.text('Add to Groceries');
      expect(groceriesBtn, findsOneWidget);
      await tester.tap(groceriesBtn);
      await tester.pumpAndSettle();      
    });

    testWidgets('handles missing fridgeId', (tester) async {
      userViewModel.setUser(
        userViewModel.user?.copyWith(fridgeId: null),
      );
      ingredientViewModel.clear();
      ingredientViewModel.ingredients.add(
        Ingredient(
          id: 'i1',
          name: 'Mock Ingredient',
          category: 'Mock Category',
          imageURL: '',
          count: 1,
        ),
      );
      await openSearch(
        tester,
        delegate,
        ingredientViewModel: ingredientViewModel,
        userViewModel: userViewModel,
        fridgeViewModel: fridgeViewModel,
      );
      delegate.query = 'Mock Ingredient';
      await tester.pumpAndSettle();

      final ingredientTile = find.widgetWithText(ListTile, 'Mock Ingredient');
      expect(ingredientTile, findsOneWidget);
      await robustTapIngredientTile(tester, ingredientTile);

      final groceriesBtn = find.text('Add to Groceries');
      expect(groceriesBtn, findsOneWidget);
      await tester.tap(groceriesBtn);
      await tester.pumpAndSettle();      
    });

    testWidgets('can cancel the dialog', (tester) async {
      ingredientViewModel.clear();
      ingredientViewModel.ingredients.add(
        Ingredient(
          id: 'i1',
          name: 'Mock Ingredient',
          category: 'Mock Category',
          imageURL: '',
          count: 1,
        ),
      );
      await openSearch(
        tester,
        delegate,
        ingredientViewModel: ingredientViewModel,
        userViewModel: userViewModel,
        fridgeViewModel: fridgeViewModel,
      );
      delegate.query = 'Mock Ingredient';
      await tester.pumpAndSettle();

      final ingredientTile = find.widgetWithText(ListTile, 'Mock Ingredient');
      expect(ingredientTile, findsOneWidget);
      await robustTapIngredientTile(tester, ingredientTile);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Add Mock Ingredient'), findsNothing);
    });

    testWidgets('quantity can be incremented and decremented', (tester) async {
      ingredientViewModel.clear();
      ingredientViewModel.ingredients.add(
        Ingredient(
          id: 'i1',
          name: 'Mock Ingredient',
          category: 'Mock Category',
          imageURL: '',
          count: 1,
        ),
      );
      await openSearch(
        tester,
        delegate,
        ingredientViewModel: ingredientViewModel,
        userViewModel: userViewModel,
        fridgeViewModel: fridgeViewModel,
      );
      delegate.query = 'Mock Ingredient';
      await tester.pumpAndSettle();

      final ingredientTile = find.widgetWithText(ListTile, 'Mock Ingredient');
      expect(ingredientTile, findsOneWidget);
      await robustTapIngredientTile(tester, ingredientTile);

      // Increment
      await tester.tap(find.widgetWithIcon(IconButton, Icons.add_circle));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);

      // Decrement
      await tester.tap(find.widgetWithIcon(IconButton, Icons.remove_circle));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });
  });
}
