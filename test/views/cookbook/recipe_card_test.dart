import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/views/cookbook/widgets/recipe_card.dart';
import 'package:snapchef/models/recipe.dart';

void main() {
  testWidgets('RecipeCard displays recipe title', (tester) async {
    final recipe = Recipe(
        id: '1',
        title: 'Test Recipe',
        description: '',
        mealType: '',
        cuisineType: '',
        difficulty: '',
        prepTime: 10,
        cookingTime: 10,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecipeCard(recipe: recipe),
        ),
      ),
    );
    expect(find.text('Test Recipe'), findsOneWidget);
  });
}
