import '../../repositories/cookbook_repository.dart';
import '../../models/recipe.dart';

class CookbookSyncActions {
  final CookbookRepository cookbookRepository;

  CookbookSyncActions(this.cookbookRepository);

  /// Handles cookbook-related sync actions based on the action type.
  Future<void> handleCookbookAction(Map<String, dynamic> action) async {
    switch (action['action']) {
      case 'add':
        await _addRecipe(action);
        break;
      case 'update':
        await _updateRecipe(action);
        break;
      case 'delete':
        await _deleteRecipe(action);
        break;
      case 'reorder':
        await _reorderRecipes(action);
        break;
      case 'toggleFavorite':
        await _toggleFavorite(action);
        break;
      default:
        break;
    }
  }

  /// Adds a recipe to the cookbook.
  Future<void> _addRecipe(Map<String, dynamic> action) async {
    final recipe = Recipe.fromJson(action['recipe']);
    await cookbookRepository.addRecipeToCookbookRemote(
      action['cookbookId'],
      recipe,
    );
  }

  /// Updates a recipe in the cookbook.
  Future<void> _updateRecipe(Map<String, dynamic> action) async {
    final updatedRecipe = Recipe.fromJson(action['updatedRecipe']);
    await cookbookRepository.updateRecipeRemote(
      action['cookbookId'],
      action['recipeId'],
      updatedRecipe,
    );
  }

  /// Deletes a recipe from the cookbook.
  Future<void> _deleteRecipe(Map<String, dynamic> action) async {
    await cookbookRepository.deleteRecipeRemote(
      action['cookbookId'],
      action['recipeId'],
    );
  }

  /// Reorders recipes in the cookbook based on the provided order.
  Future<void> _reorderRecipes(Map<String, dynamic> action) async {
    await cookbookRepository.saveRecipeOrderRemote(
      action['cookbookId'],
      List<String>.from(action['orderedIds']),
    );
  }

  /// Toggles the favorite status of a recipe in the cookbook.
  Future<void> _toggleFavorite(Map<String, dynamic> action) async {
    await cookbookRepository.toggleRecipeFavoriteStatusRemote(
      action['cookbookId'],
      action['recipeId'],
    );
  }
}