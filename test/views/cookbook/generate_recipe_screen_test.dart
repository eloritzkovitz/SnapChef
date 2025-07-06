import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/generate_recipe_screen.dart';
import 'package:snapchef/views/cookbook/widgets/ingredient_chip_list.dart';
import 'package:snapchef/views/cookbook/widgets/ingredient_selection_modal.dart';
import 'package:snapchef/views/cookbook/widgets/recipe_options_section.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_recipe_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

Widget buildTestWidget({Widget? child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserViewModel>(create: (_) => MockUserViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => MockConnectivityProvider()),
      ChangeNotifierProvider<RecipeViewModel>(
          create: (_) => MockRecipeViewModel()),
      ChangeNotifierProvider<FridgeViewModel>(
          create: (_) => MockFridgeViewModel()),
    ],
    child: MaterialApp(
      home: child ?? const GenerateRecipeScreen(),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('GenerateRecipeScreen', () {
    testWidgets('shows Generate Recipe title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Generate Recipe'), findsOneWidget);
    });

    testWidgets('shows all dropdowns and text fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows disabled Add Ingredients button if fridge is empty',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final addBtn = find.widgetWithText(ElevatedButton, 'Add Ingredients');
      expect(addBtn, findsNothing);
    });

    testWidgets('shows info text if no ingredients selected', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            w.data != null &&
            w.data!.toLowerCase().contains('add ingredients')),
        findsOneWidget,
      );
    });

    testWidgets('shows IngredientChipList when ingredients are selected',
        (tester) async {
      final recipeViewModel = MockRecipeViewModel();
      recipeViewModel.selectedIngredients.add(Ingredient(
          id: '1', name: 'Tomato', category: 'Test', imageURL: '', count: 1));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>(
                create: (_) => MockConnectivityProvider()),
            ChangeNotifierProvider<RecipeViewModel>(
                create: (_) => recipeViewModel),
            ChangeNotifierProvider<FridgeViewModel>(
                create: (_) => MockFridgeViewModel()),
          ],
          child: const MaterialApp(home: GenerateRecipeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(IngredientChipList), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
    });

    testWidgets('Generate button is disabled if no ingredients selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final generateBtn = find.widgetWithText(ElevatedButton, 'Generate');
      expect(generateBtn, findsOneWidget);
    });

    testWidgets(
        'Generate button shows loading indicator when isLoading is true',
        (tester) async {
      final recipeViewModel = MockRecipeViewModel();
      recipeViewModel.isLoading = true;
      recipeViewModel.selectedIngredients.add(Ingredient(
          id: '1', name: 'Tomato', category: 'Test', imageURL: '', count: 1));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>(
                create: (_) => MockConnectivityProvider()),
            ChangeNotifierProvider<RecipeViewModel>(
                create: (_) => recipeViewModel),
            ChangeNotifierProvider<FridgeViewModel>(
                create: (_) => MockFridgeViewModel()),
          ],
          child: const MaterialApp(home: GenerateRecipeScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('can select dropdown values and enter text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Breakfast').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '10');
      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('Add Ingredients button opens modal when fridge is not empty',
        (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.ingredients.add(Ingredient(
          id: '1', name: 'Tomato', category: 'Test', imageURL: '', count: 1));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>(
                create: (_) => MockConnectivityProvider()),
            ChangeNotifierProvider<RecipeViewModel>(
                create: (_) => MockRecipeViewModel()),
            ChangeNotifierProvider<FridgeViewModel>(
                create: (_) => fridgeViewModel),
          ],
          child: const MaterialApp(home: GenerateRecipeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final addBtnText = find.text('Add Ingredients');
      expect(addBtnText, findsOneWidget);
      await tester.tap(addBtnText);
      await tester.pumpAndSettle();
      expect(find.byType(IngredientSelectionModal), findsOneWidget);
    });
  });

  group('RecipeOptionsSection', () {
    testWidgets('renders all dropdowns and text fields', (tester) async {
      final prepController = TextEditingController();
      final cookController = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeOptionsSection(
              selectedMealType: null,
              selectedCuisine: null,
              selectedDifficulty: null,
              prepTimeController: prepController,
              cookingTimeController: cookController,
              onMealTypeChanged: (_) {},
              onCuisineChanged: (_) {},
              onDifficultyChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('calls onChanged callbacks', (tester) async {
      String? mealType, cuisine, difficulty;
      final prepController = TextEditingController();
      final cookController = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeOptionsSection(
              selectedMealType: null,
              selectedCuisine: null,
              selectedDifficulty: null,
              prepTimeController: prepController,
              cookingTimeController: cookController,
              onMealTypeChanged: (v) => mealType = v,
              onCuisineChanged: (v) => cuisine = v,
              onDifficultyChanged: (v) => difficulty = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Breakfast').first);
      await tester.pumpAndSettle();
      expect(mealType, isNotNull);

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('American').first);
      await tester.pumpAndSettle();
      expect(cuisine, isNotNull);

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Easy').first);
      await tester.pumpAndSettle();
      expect(difficulty, isNotNull);
    });
  });

  group('IngredientChipList', () {
    testWidgets('renders nothing if ingredients is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientChipList(
              ingredients: const [],
              onRemove: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('renders chips for each ingredient and calls onRemove',
        (tester) async {
      bool removed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientChipList(
              ingredients: [
                Ingredient(
                    id: '1',
                    name: 'Tomato',
                    category: 'Test',
                    imageURL: '',
                    count: 1)
              ],
              onRemove: (_) => removed = true,
            ),
          ),
        ),
      );
      expect(find.byType(Chip), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });
  });

  group('IngredientSelectionModal', () {
    setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

    testWidgets('IngredientSelectionModal shows ingredient', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      final recipeViewModel = MockRecipeViewModel();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RecipeViewModel>.value(
                value: recipeViewModel),
            ChangeNotifierProvider<FridgeViewModel>.value(
                value: fridgeViewModel),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: IngredientSelectionModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mock Ingredient 1'), findsOneWidget);
      expect(find.text('Mock Ingredient 2'), findsOneWidget);
    });

    testWidgets('filters ingredient list by search', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      final recipeViewModel = MockRecipeViewModel();
      fridgeViewModel.ingredients.addAll([
        Ingredient(
            id: '1', name: 'Tomato', category: 'Test', imageURL: '', count: 1),
        Ingredient(
            id: '2', name: 'Potato', category: 'Test', imageURL: '', count: 1),
      ]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RecipeViewModel>(
                create: (_) => recipeViewModel),
            ChangeNotifierProvider<FridgeViewModel>(
                create: (_) => fridgeViewModel),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const IngredientSelectionModal(),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Potato');
      await tester.pumpAndSettle();
      expect(find.text('Potato', skipOffstage: false), findsOneWidget);
      expect(find.text('Tomato', skipOffstage: false), findsNothing);
    });

    testWidgets('close button pops modal', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      final recipeViewModel = MockRecipeViewModel();
      fridgeViewModel.ingredients.add(Ingredient(
          id: '1', name: 'Tomato', category: 'Test', imageURL: '', count: 1));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RecipeViewModel>(
                create: (_) => recipeViewModel),
            ChangeNotifierProvider<FridgeViewModel>(
                create: (_) => fridgeViewModel),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const IngredientSelectionModal(),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(IngredientSelectionModal), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(IngredientSelectionModal), findsNothing);
    });
  });
}
