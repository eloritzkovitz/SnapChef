import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import '../models/recipe.dart';
import '../models/shared_recipe.dart';
import '../database/app_database.dart' as db;
import '../services/shared_recipe_service.dart';

class SharedRecipeRepository {
  final db.AppDatabase database = GetIt.I<db.AppDatabase>();
  final SharedRecipeService sharedRecipeService = GetIt.I<SharedRecipeService>(); 

  /// Fetches shared recipes for a specific cookbook from the remote service.
  Future<Map<String, List<SharedRecipe>>> fetchSharedRecipesRemote(
      String cookbookId) async {
    final result = await sharedRecipeService.fetchSharedRecipes(cookbookId);
    return {
      'sharedWithMe': result['sharedWithMe'] ?? [],
      'sharedByMe': result['sharedByMe'] ?? [],
    };
  }

  /// Fetches shared recipes for a specific user from the local database.
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

  /// Adds a shared recipe to the local database only.
  Future<void> addSharedRecipeLocal(SharedRecipe sharedRecipe) async {
    await database.sharedRecipeDao.insertSharedRecipe(
      db.SharedRecipesCompanion.insert(
        id: sharedRecipe.id,
        recipeId: sharedRecipe.recipe.id,
        fromUser: sharedRecipe.fromUser,
        toUser: sharedRecipe.toUser,
        sharedAt: sharedRecipe.sharedAt.toIso8601String(),
        status: Value(sharedRecipe.status),
      ),
    );
    await database.recipeDao.insertOrUpdateRecipe(
      sharedRecipe.recipe.toDbRecipe(userId: sharedRecipe.toUser),
    );
  }

  /// Stores a list of shared recipes in the local database.
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
        ),
      );
      // Also persist the recipe itself if needed
      await database.recipeDao.insertOrUpdateRecipe(
        shared.recipe.toDbRecipe(userId: shared.toUser),
      );
    }
  }

  /// Removes a shared recipe from the remote cookbook.
  Future<void> removeSharedRecipeRemote(
      String cookbookId, String sharedRecipeId) async {
    await sharedRecipeService.deleteSharedRecipe(cookbookId, sharedRecipeId);
  }  

  /// Removes a shared recipe from the local database.
  Future<void> removeSharedRecipeLocal(String sharedRecipeId) async {
    await database.sharedRecipeDao.deleteSharedRecipe(sharedRecipeId);
  }
}
