import 'package:snapchef/models/recipe.dart';

class MockCookbookRepository {  
  final database = null;
  final cookbookService = null;

  Future<List<Recipe>> fetchCookbookRecipesRemote(String cookbookId) async => [];

  Future<List<Recipe>> fetchCookbookRecipesLocal(String userId) async => [];

  Future<void> storeCookbookRecipesLocal(String userId, List<Recipe> recipes) async {}

  Future<bool> addRecipeToCookbookRemote(String cookbookId, Recipe recipe, {String? raw}) async => true;

  Future<void> addRecipeToCookbookLocal(String userId, Recipe recipe) async {}

  Future<bool> updateRecipeRemote(String cookbookId, String recipeId, Recipe updatedRecipe) async => true;

  Future<void> updateRecipeLocal(String userId, Recipe updatedRecipe) async {}

  Future<bool> deleteRecipeRemote(String cookbookId, String recipeId) async => true;

  Future<void> deleteRecipeLocal(String recipeId) async {}

  Future<bool> toggleRecipeFavoriteStatusRemote(String cookbookId, String recipeId) async => true;

  Future<void> toggleRecipeFavoriteStatusLocal(String recipeId, bool isFavorite) async {}

  Future<void> saveRecipeOrderRemote(String cookbookId, List<String> orderedIds) async {}

  Future<void> saveRecipeOrderLocal(List<String> orderedIds) async {}

  Future<void> shareRecipeWithFriend({
    required String cookbookId,
    required String recipeId,
    required String friendId,
  }) async {}

  Future<String> regenerateRecipeImage(
    String cookbookId,
    String recipeId,
    Map<String, dynamic> payload,
  ) async => '';
}