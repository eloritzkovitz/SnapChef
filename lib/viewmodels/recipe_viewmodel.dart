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

  // Generate a recipe based on the selected ingredients
  Future<void> generateRecipe() async {
    isLoading = true;
    recipe = '';
    imageUrl = '';
    notifyListeners();

    try {
      // Convert the list of selected ingredients to a format suitable for the backend
      final ingredientsString = selectedIngredients.map((e) => e.name).join(',');
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