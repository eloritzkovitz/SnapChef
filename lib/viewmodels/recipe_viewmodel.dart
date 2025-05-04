import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../models/ingredient.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  bool isLoading = false;
  String recipe = '';
  String imageUrl = '';
  final List<Ingredient> selectedIngredients = [];

  // Add an ingredient to the selected list
  void addIngredient(Ingredient ingredient) {
    if (!selectedIngredients.contains(ingredient)) {
      selectedIngredients.add(ingredient);
      notifyListeners();
    }
  }

  // Remove an ingredient from the selected list
  void removeIngredient(Ingredient ingredient) {
    selectedIngredients.remove(ingredient);
    notifyListeners();
  }

  // Check if an ingredient is selected
  bool isIngredientSelected(Ingredient ingredient) {
    return selectedIngredients.contains(ingredient);
  }

  // Generate a recipe based on the selected ingredients and additional options
  Future<void> generateRecipe({
    String? mealType,
    String? cuisine,
    String? difficulty,
    int? cookingTime,
    int? prepTime,
  }) async {
    isLoading = true;
    recipe = '';
    imageUrl = '';
    notifyListeners();

    try {
      // Convert the list of selected ingredients to a format suitable for the backend
      final ingredientsString =
          selectedIngredients.map((e) => e.name).join(',');

      // Prepare the request payload
      final requestPayload = {
        'ingredients': ingredientsString,
        'mealType': mealType,
        'cuisine': cuisine,
        'difficulty': difficulty,
        'cookingTime': cookingTime,
        'prepTime': prepTime,
      };

      // Call the backend service to generate the recipe
      final result = await _recipeService.generateRecipe(requestPayload);

      // Update the recipe and image URL with the response from the backend
      recipe = result['recipe'] ?? 'No recipe generated.';
      imageUrl = result['imageUrl'] ?? '';
    } catch (error) {
      recipe = 'Failed to generate recipe: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
