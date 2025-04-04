import 'package:flutter/material.dart';
import '../services/recipe_service.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  bool isLoading = false;
  String recipe = '';
  String imageUrl = '';

  Future<void> generateRecipe(String ingredients) async {
    isLoading = true;
    recipe = '';
    imageUrl = '';
    notifyListeners();

    try {
      final result = await _recipeService.generateRecipe(ingredients);
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