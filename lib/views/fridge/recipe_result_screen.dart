import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../widgets/display_recipe_widget.dart';

class RecipeResultScreen extends StatelessWidget {
  final String recipe;
  final String imageUrl;
  final List<Ingredient> usedIngredients;
  final String? mealType;
  final String? cuisineType;
  final String? difficulty;
  final int? cookingTime;
  final int? prepTime;

  const RecipeResultScreen({
    super.key,
    required this.recipe,
    required this.imageUrl,
    required this.usedIngredients,
    this.mealType,
    this.cuisineType,
    this.difficulty,
    this.cookingTime,
    this.prepTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            tooltip: 'Save Recipe to Cookbook',
            onPressed: () => _saveRecipeToCookbook(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: DisplayRecipeWidget(
                recipeString: recipe,
                imageUrl: imageUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save the recipe to the cookbook
  void _saveRecipeToCookbook(BuildContext context) {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    // Get the cookbook ID dynamically from the user object
    final user = Provider.of<UserViewModel>(context, listen: false);
    final String cookbookId = user.cookbookId ?? '';

    // Create a Recipe object to save
    final newRecipe = Recipe(
      id: DateTime.now().toString(),
      title: 'Generated Recipe',
      description: 'A recipe generated based on your ingredients.',
      mealType: mealType ?? '',
      cuisineType: cuisineType ?? '',
      difficulty: difficulty ?? '',
      cookingTime: cookingTime ?? 0,
      prepTime: prepTime ?? 0,
      ingredients: usedIngredients,
      instructions: recipe.split('\n'),
      imageURL: imageUrl,
      rating: null,
    );

    // Save the recipe to the cookbook
    cookbookViewModel.addRecipeToCookbook(
      cookbookId: cookbookId,
      title: newRecipe.title,
      description: newRecipe.description,
      mealType: newRecipe.mealType,
      cuisineType: newRecipe.cuisineType,
      difficulty: newRecipe.difficulty,
      cookingTime: newRecipe.cookingTime,
      prepTime: newRecipe.prepTime,
      ingredients: newRecipe.ingredients,
      instructions: newRecipe.instructions,
      imageURL: newRecipe.imageURL,
      rating: newRecipe.rating,
      raw: newRecipe.instructions.join('\n'),
    );

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved to cookbook!')),
    );
  }
}