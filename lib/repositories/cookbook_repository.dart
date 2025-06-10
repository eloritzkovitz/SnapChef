import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/shared_recipe.dart';
import '../database/app_database.dart' as db;
import '../services/cookbook_service.dart';

class CookbookRepository {
  final db.AppDatabase database = GetIt.I<db.AppDatabase>();
  final CookbookService cookbookService = GetIt.I<CookbookService>();

  // --- Cookbook Recipes ---

  Future<List<Recipe>> fetchCookbookRecipesRemote(String cookbookId) async {
    final items = await cookbookService.fetchCookbookRecipes(cookbookId);
    return items
        .map<Recipe>((item) => Recipe(
              id: item['_id'] ?? '',
              title: item['title'],
              description: item['description'],
              mealType: item['mealType'],
              cuisineType: item['cuisineType'],
              difficulty: item['difficulty'],
              prepTime: item['prepTime'],
              cookingTime: item['cookingTime'],
              ingredients: (item['ingredients'] as List<dynamic>)
                  .map((ingredient) => Ingredient.fromJson(ingredient))
                  .toList(),
              instructions: List<String>.from(item['instructions']),
              imageURL:
                  item['imageURL'] ?? 'assets/images/placeholder_image.png',
              rating: item['rating'] != null
                  ? (item['rating'] as num).toDouble()
                  : null,
              isFavorite: item['isFavorite'] ?? false,
              source: item['source'] == 'ai'
                  ? RecipeSource.ai
                  : item['source'] == 'shared'
                      ? RecipeSource.shared
                      : RecipeSource.user,
            ))
        .toList();
  }

  Future<List<Recipe>> fetchCookbookRecipesLocal(String userId) async {
    final localRecipes = await database.recipeDao.getCookbookRecipes(userId);
    return localRecipes
        .map((dbRecipe) => Recipe.fromDb(dbRecipe.toJson()))
        .toList();
  }

  Future<void> storeCookbookRecipesLocal(
      String userId, List<Recipe> recipes) async {
    for (final recipe in recipes) {
      await database.recipeDao
          .insertOrUpdateRecipe(recipe.toDbRecipe(userId: userId));
    }
  }

  // --- Shared Recipes ---

  Future<Map<String, List<SharedRecipe>>> fetchSharedRecipesRemote(
      String cookbookId) async {
    final result = await cookbookService.fetchSharedRecipes(cookbookId);
    return {
      'sharedWithMe': result['sharedWithMe'] ?? [],
      'sharedByMe': result['sharedByMe'] ?? [],
    };
  }

  Future<List<SharedRecipe>> fetchSharedRecipesLocal(String userId) async {
    final dbShared =
        await database.sharedRecipeDao.getSharedRecipesForUser(userId);
    // You may need to fetch the recipe for each shared recipe
    List<SharedRecipe> result = [];
    for (final dbSharedRecipe in dbShared) {
      final dbRecipe =
          await database.recipeDao.getRecipeById(dbSharedRecipe.recipeId);
      if (dbRecipe != null) {
        result.add(
          SharedRecipe(
            id: dbSharedRecipe.id,
            recipe: Recipe.fromDb(dbRecipe.toJson()),
            fromUser: dbSharedRecipe.fromUser,
            toUser: dbSharedRecipe.toUser,
            sharedAt: DateTime.parse(dbSharedRecipe.sharedAt),
            status: dbSharedRecipe.status,
          ),
        );
      }
    }
    return result;
  }

  Future<void> storeSharedRecipesLocal(List<SharedRecipe> sharedRecipes) async {
    for (final shared in sharedRecipes) {
      // Convert SharedRecipe to Drift's SharedRecipe table entry
      await database.sharedRecipeDao.insertSharedRecipe(
        db.SharedRecipesCompanion.insert(
          id: shared.id,
          recipeId: shared.recipe.id,
          fromUser: shared.fromUser,
          toUser: shared.toUser,
          sharedAt: shared.sharedAt.toIso8601String(),
          status: Value(shared.status),
          // Add other fields as needed
        ),
      );
      // Also persist the recipe itself if needed
      await database.recipeDao.insertOrUpdateRecipe(
        shared.recipe.toDbRecipe(userId: shared.toUser),
      );
    }
  }

  /// Returns a map of friendId to User for fast lookup.
  Future<Map<String, db.Friend>> getFriendsMap(String currentUserId) async {
    final friends = await database.friendDao.getFriendsForUser(currentUserId);
    final friendMap = {for (var f in friends) f.friendId: f};
    return friendMap;
  }

  // --- Add/Update/Delete Recipes ---

  Future<bool> addRecipeToCookbook(String cookbookId, Recipe recipe,
      {String? raw}) async {
    final recipeData = {
      'title': recipe.title,
      'description': recipe.description,
      'mealType': recipe.mealType,
      'cuisineType': recipe.cuisineType,
      'difficulty': recipe.difficulty,
      'prepTime': recipe.prepTime,
      'cookingTime': recipe.cookingTime,
      'ingredients':
          recipe.ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'instructions': recipe.instructions,
      'imageURL': recipe.imageURL,
      'rating': recipe.rating,
      'isFavorite': recipe.isFavorite,
      'source': recipe.source == RecipeSource.ai
          ? 'ai'
          : recipe.source == RecipeSource.shared
              ? 'shared'
              : 'user',
      'raw': raw,
    };
    return await cookbookService.addRecipeToCookbook(recipeData, cookbookId);
  }

  Future<bool> updateRecipe(
    String cookbookId,
    String recipeId,
    Recipe updatedRecipe,
  ) async {
    final updatedData = {
      'title': updatedRecipe.title,
      'description': updatedRecipe.description,
      'mealType': updatedRecipe.mealType,
      'cuisineType': updatedRecipe.cuisineType,
      'difficulty': updatedRecipe.difficulty,
      'prepTime': updatedRecipe.prepTime,
      'cookingTime': updatedRecipe.cookingTime,
      'ingredients': updatedRecipe.ingredients
          .map((ingredient) => ingredient.toJson())
          .toList(),
      'instructions': updatedRecipe.instructions,
      'imageURL': updatedRecipe.imageURL,
      'rating': updatedRecipe.rating,
    };
    return await cookbookService.updateCookbookRecipe(
        cookbookId, recipeId, updatedData);
  }

  Future<bool> deleteRecipe(String cookbookId, String recipeId) async {
    return await cookbookService.deleteCookbookRecipe(cookbookId, recipeId);
  }

  Future<void> deleteRecipeLocal(String recipeId) async {
    await database.recipeDao.deleteRecipe(recipeId);
  }

  // --- Favorite, Order, and Sharing ---

  Future<bool> toggleRecipeFavoriteStatus(
      String cookbookId, String recipeId) async {
    return await cookbookService.toggleRecipeFavoriteStatus(
        cookbookId, recipeId);
  }

  Future<void> saveRecipeOrder(
      String cookbookId, List<String> orderedIds) async {
    await cookbookService.saveRecipeOrder(cookbookId, orderedIds);
  }

  Future<void> shareRecipeWithFriend({
    required String cookbookId,
    required String recipeId,
    required String friendId,
  }) async {
    await cookbookService.shareRecipeWithFriend(
      cookbookId: cookbookId,
      recipeId: recipeId,
      friendId: friendId,
    );
  }

  Future<void> removeSharedRecipe(
      String cookbookId, String sharedRecipeId) async {
    await cookbookService.deleteSharedRecipe(cookbookId, sharedRecipeId);
  }

  // --- Regenerate Image ---

  Future<String> regenerateRecipeImage(
    String cookbookId,
    String recipeId,
    Map<String, dynamic> payload,
  ) async {
    return await cookbookService.regenerateRecipeImage(
        cookbookId, recipeId, payload);
  }
}
