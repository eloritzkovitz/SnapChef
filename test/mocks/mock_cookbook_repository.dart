import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/repositories/cookbook_repository.dart';
import 'package:snapchef/database/app_database.dart' hide Recipe;
import 'package:snapchef/services/cookbook_service.dart';

class MockCookbookRepository implements CookbookRepository {
  @override
  AppDatabase get database => throw UnimplementedError();

  @override
  CookbookService get cookbookService => throw UnimplementedError();

  @override
  Future<List<Recipe>> fetchCookbookRecipesRemote(String cookbookId) async => [];

  @override
  Future<List<Recipe>> fetchCookbookRecipesLocal(String userId) async => [];

  @override
  Future<void> storeCookbookRecipesLocal(String userId, List<Recipe> recipes) async {}

  @override
  Future<bool> addRecipeToCookbookRemote(String cookbookId, Recipe recipe, {String? raw}) async => true;

  @override
  Future<void> addRecipeToCookbookLocal(String userId, Recipe recipe) async {}

  @override
  Future<bool> updateRecipeRemote(String cookbookId, String recipeId, Recipe updatedRecipe) async => true;

  @override
  Future<void> updateRecipeLocal(String userId, Recipe updatedRecipe) async {}

  @override
  Future<bool> deleteRecipeRemote(String cookbookId, String recipeId) async => true;

  @override
  Future<void> deleteRecipeLocal(String recipeId) async {}

  @override
  Future<bool> toggleRecipeFavoriteStatusRemote(String cookbookId, String recipeId) async => true;

  @override
  Future<void> toggleRecipeFavoriteStatusLocal(String recipeId, bool isFavorite) async {}

  @override
  Future<void> saveRecipeOrderRemote(String cookbookId, List<String> orderedIds) async {}

  @override
  Future<void> saveRecipeOrderLocal(List<String> orderedIds) async {}

  @override
  Future<void> shareRecipeWithFriend({
    required String cookbookId,
    required String recipeId,
    required String friendId,
  }) async {}

  @override
  Future<String> regenerateRecipeImage(
    String cookbookId,
    String recipeId,
    Map<String, dynamic> payload,
  ) async => '';
}