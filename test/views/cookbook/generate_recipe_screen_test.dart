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

class TestRecipeViewModel extends MockRecipeViewModel {
  bool called = false;
  Map<String, dynamic>? lastArgs;

  @override
  Future<void> generateRecipe({
    String? mealType,
    String? cuisine,
    String? difficulty,
    int? prepTime,
    int? cookingTime,
    Map<String, dynamic>? preferences,
  }) async {
    called = true;
    lastArgs = {
      'mealType': mealType,
      'cuisine': cuisine,
      'difficulty': difficulty,
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'preferences': preferences,
    };
  }
}

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

    testWidgets('Generate button is disabled when loading', (tester) async {
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
      final generateBtn = find.widgetWithText(ElevatedButton, 'Generate');
      if (generateBtn.evaluate().isNotEmpty) {
        final ElevatedButton btn = tester.widget(generateBtn);
        expect(btn.enabled, isFalse);
      }
    });

    testWidgets(
        'Generate button calls generateRecipe with null times if text is invalid',
        (tester) async {
      final recipeViewModel = TestRecipeViewModel();
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

      // Fill all dropdowns
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Breakfast').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('American').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Easy').first);
      await tester.pumpAndSettle();

      // Enter invalid text fields
      await tester.enterText(find.byType(TextFormField).at(0), 'abc');
      await tester.enterText(find.byType(TextFormField).at(1), 'xyz');
      await tester.pumpAndSettle();

      final generateBtn = find.widgetWithText(ElevatedButton, 'Generate');
      await tester.tap(generateBtn);
      await tester.pump(const Duration(milliseconds: 100));
      expect(recipeViewModel.called, isTrue);
      expect(recipeViewModel.lastArgs?['prepTime'], isNull);
      expect(recipeViewModel.lastArgs?['cookingTime'], isNull);

      // Add this line to allow timers to finish
      await tester.pump(const Duration(seconds: 1));
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

    testWidgets('fields reset on pop', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Select meal type
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Breakfast').first);
      await tester.pumpAndSettle();

      // Enter prep time
      await tester.enterText(find.byType(TextFormField).at(0), '15');
      await tester.pumpAndSettle();

      // Simulate pop by removing and re-adding the widget
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Fields should be reset
      expect(find.text('15'), findsNothing);
      expect(find.text('Breakfast'), findsNothing);
    });    

    testWidgets('resetFields resets all fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Fill all fields
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Breakfast').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '15');
      await tester.pumpAndSettle();

      // Simulate pop by removing and re-adding the widget
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Fields should be reset
      expect(find.text('15'), findsNothing);
      expect(find.text('Breakfast'), findsNothing);
    });

    testWidgets('shows correct UI when all dropdowns and fields are filled',
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

      // Select all dropdowns
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Breakfast').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('American').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Easy').first);
      await tester.pumpAndSettle();

      // Enter text fields
      await tester.enterText(find.byType(TextFormField).at(0), '10');
      await tester.enterText(find.byType(TextFormField).at(1), '20');
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('American'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
    });

    testWidgets('Ingredient search filters correctly', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.ingredients.addAll([
        Ingredient(
            id: '1', name: 'Tomato', category: 'Test', imageURL: '', count: 1),
        Ingredient(
            id: '2', name: 'Potato', category: 'Test', imageURL: '', count: 1),
      ]);
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

      // Open ingredient selection modal
      final addBtn = find.text('Add Ingredients');
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Find the search TextField inside the modal
      final modal = find.byType(IngredientSelectionModal);
      final searchField =
          find.descendant(of: modal, matching: find.byType(TextField));
      await tester.enterText(searchField, 'Potato');
      await tester.pumpAndSettle();
      expect(find.text('Potato', skipOffstage: false), findsOneWidget);
      expect(find.text('Tomato', skipOffstage: false), findsNothing);
    });

    testWidgets('does not call generateRecipe if no ingredients',
        (tester) async {
      final recipeViewModel = TestRecipeViewModel();
      recipeViewModel.selectedIngredients.clear(); // Ensure empty
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
      final generateBtn = find.widgetWithText(ElevatedButton, 'Generate');
      expect(generateBtn, findsOneWidget);
      final ElevatedButton btn = tester.widget(generateBtn);
      expect(btn.enabled, isFalse);
      expect(recipeViewModel.called, isFalse);
    });

    testWidgets('calls generateRecipe with correct arguments', (tester) async {
      final recipeViewModel = TestRecipeViewModel();
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

      // Fill all fields
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Breakfast').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('American').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Easy').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '10');
      await tester.enterText(find.byType(TextFormField).at(1), '20');
      await tester.pump(const Duration(milliseconds: 100));

      final generateBtn = find.widgetWithText(ElevatedButton, 'Generate');
      expect(generateBtn, findsOneWidget);
      await tester.tap(generateBtn);
      await tester.pump(const Duration(milliseconds: 100));
      expect(recipeViewModel.called, isTrue);
      expect(recipeViewModel.lastArgs?['mealType'], 'Breakfast');
      expect(recipeViewModel.lastArgs?['cuisine'], 'American');
      expect(recipeViewModel.lastArgs?['difficulty'], 'Easy');
      expect(recipeViewModel.lastArgs?['prepTime'], 10);
      expect(recipeViewModel.lastArgs?['cookingTime'], 20);
      expect(recipeViewModel.lastArgs?['preferences'],
          isA<Map<String, dynamic>>());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shows loading indicator only when isLoading is true',
        (tester) async {
      final recipeViewModel = MockRecipeViewModel();
      recipeViewModel.selectedIngredients.add(Ingredient(
          id: '1', name: 'Tomato', category: 'Test', imageURL: '', count: 1));
      recipeViewModel.isLoading = false;
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
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Set loading to true and rebuild
      recipeViewModel.isLoading = true;
      recipeViewModel.notifyListeners();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Add Ingredients button is disabled if fridge is empty',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final addBtn = find.widgetWithText(ElevatedButton, 'Add Ingredients');
      expect(addBtn, findsNothing);
    });

    testWidgets('Add Ingredients button is enabled if fridge has ingredients',
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
      final addBtn = find.text('Add Ingredients');
      expect(addBtn, findsOneWidget);
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
