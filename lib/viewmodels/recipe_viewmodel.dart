import 'package:flutter/material.dart';
import '../services/recipe_service.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  bool isLoading = false;
  String recipe = '';
  String imageUrl = '';

  // Generate a recipe based on a list of ingredients
  Future<void> generateRecipe(List<String> ingredients) async {
    isLoading = true;
    recipe = '';
    imageUrl = '';
    notifyListeners();

    try {
      // Convert the list of ingredients to a format suitable for the backend
      final ingredientsString = ingredients.join(',');
      final result = await _recipeService.generateRecipe(ingredientsString);
      recipe = result['recipe']!;
      imageUrl = result['imageUrl']!;
    } catch (error) {
      recipe = 'Failed to generate recipe: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}