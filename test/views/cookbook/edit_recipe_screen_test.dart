import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/edit_recipe_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

Widget wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CookbookViewModel>(
          create: (_) => MockCookbookViewModel()),
      ChangeNotifierProvider<UserViewModel>(create: (_) => MockUserViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => MockConnectivityProvider()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  final userRecipe = Recipe(
    id: '1',
    title: 'User Recipe',
    description: 'A user recipe',
    mealType: 'Lunch',
    cuisineType: 'Italian',
    difficulty: 'Easy',
    prepTime: 10,
    cookingTime: 20,
    instructions: ['Step 1', 'Step 2'],
    ingredients: [
      Ingredient(name: 'Egg', id: '', category: '', imageURL: '', count: 1)
    ],
    imageURL: '',
    rating: 4.5,
    source: RecipeSource.user,
  );

  final aiRecipe = Recipe(
    id: '2',
    title: 'AI Recipe',
    description: 'An AI recipe',
    mealType: 'Dinner',
    cuisineType: 'French',
    difficulty: 'Medium',
    prepTime: 15,
    cookingTime: 30,
    instructions: ['AI Step 1', 'AI Step 2'],
    ingredients: [
      Ingredient(name: 'Milk', id: '', category: '', imageURL: '', count: 1)
    ],
    imageURL: '',
    rating: 4.0,
    source: RecipeSource.ai,
  );

  testWidgets('renders all fields and pre-fills values for user recipe',
      (tester) async {
    bool saved = false;
    await tester.pumpWidget(
      wrapWithProviders(
        EditRecipeScreen(
          recipeObj: userRecipe,
          onSave: ({
            required String title,
            required String description,
            required String mealType,
            required String cuisineType,
            required String difficulty,
            required int prepTime,
            required int cookingTime,
            required List<String> instructions,
            required List<Ingredient> ingredients,
            required String imageURL,
            required double? rating,
            required String raw,
          }) {
            saved = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Recipe'), findsOneWidget);
    expect(find.text('User Recipe'), findsOneWidget);
    expect(find.text('A user recipe'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Italian'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Step 1\nStep 2'), findsOneWidget);

    final instructionsField = find.byType(TextFormField).last;

    // Try to enter text
    await tester.enterText(instructionsField, 'New instructions');
    await tester.pumpAndSettle();

    // Read the text after input
    final afterText =
        (tester.widget<TextFormField>(instructionsField)).controller?.text ??
            '';

    // For user recipe, text should change
    expect(afterText, 'New instructions');

    // Hide keyboard before finding Save button
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    // Save button should be enabled
    final saveButton = find.text('Save Changes');
    expect(saveButton, findsOneWidget);

    // Tap Save
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(saved, isTrue);
  });

  testWidgets('instructions field is read-only for non-user recipe',
      (tester) async {
    bool saved = false;
    await tester.pumpWidget(
      wrapWithProviders(
        EditRecipeScreen(
          recipeObj: aiRecipe,
          onSave: ({
            required String title,
            required String description,
            required String mealType,
            required String cuisineType,
            required String difficulty,
            required int prepTime,
            required int cookingTime,
            required List<String> instructions,
            required List<Ingredient> ingredients,
            required String imageURL,
            required double? rating,
            required String raw,
          }) {
            saved = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Try to enter text in the instructions field
    final instructionsField = find.byType(TextFormField).last;
    final controller =
        (tester.widget(instructionsField) as TextFormField).controller!;
    final initialText = controller.text;

    await tester.enterText(instructionsField, 'New instructions');
    await tester.pumpAndSettle();

    // For non-user recipe, text should NOT change
    expect(controller.text, initialText);

    // Hide keyboard before finding Save button
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    // Save button should be enabled
    final saveButton = find.text('Save Changes');
    expect(saveButton, findsOneWidget);

    // Tap Save
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(saved, isTrue);
  });

  testWidgets('shows validation error if title is empty', (tester) async {
    bool saved = false;
    await tester.pumpWidget(
      wrapWithProviders(
        EditRecipeScreen(
          recipeObj: userRecipe.copyWith(title: ''),
          onSave: ({
            required String title,
            required String description,
            required String mealType,
            required String cuisineType,
            required String difficulty,
            required int prepTime,
            required int cookingTime,
            required List<String> instructions,
            required List<Ingredient> ingredients,
            required String imageURL,
            required double? rating,
            required String raw,
          }) {
            saved = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Clear the title field if not already empty
    final titleField = find.byType(TextFormField).first;
    await tester.enterText(titleField, '');
    await tester.pumpAndSettle();

    // Hide keyboard before finding Save button
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    // Tap Save
    final saveButton = find.text('Save Changes');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Should show validation error and not call onSave
    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(saved, isFalse);
  });
}
