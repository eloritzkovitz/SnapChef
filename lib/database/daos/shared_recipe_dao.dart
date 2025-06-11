import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_recipe_table.dart';

part 'shared_recipe_dao.g.dart';

@DriftAccessor(tables: [SharedRecipes])
class SharedRecipeDao extends DatabaseAccessor<AppDatabase> with _$SharedRecipeDaoMixin {
  SharedRecipeDao(super.db);

  // CRUD
  Future<List<SharedRecipe>> getAllSharedRecipes() => select(sharedRecipes).get();
  Stream<List<SharedRecipe>> watchAllSharedRecipes() => select(sharedRecipes).watch();
  Future<SharedRecipe?> getSharedRecipeById(String id) => (select(sharedRecipes)..where((s) => s.id.equals(id))).getSingleOrNull();
  Future<int> insertSharedRecipe(Insertable<SharedRecipe> sharedRecipe) => into(sharedRecipes).insertOnConflictUpdate(sharedRecipe);
  Future<bool> updateSharedRecipe(Insertable<SharedRecipe> sharedRecipe) => update(sharedRecipes).replace(sharedRecipe);
  Future<int> deleteSharedRecipe(String id) => (delete(sharedRecipes)..where((s) => s.id.equals(id))).go();

  // Filter by user
  Future<List<SharedRecipe>> getSharedRecipesForUser(String userId) =>
      (select(sharedRecipes)..where((s) => s.toUser.equals(userId) | s.fromUser.equals(userId))).get();

  // Filter by status
  Future<List<SharedRecipe>> getSharedRecipesByStatus(String status) =>
      (select(sharedRecipes)..where((s) => s.status.equals(status))).get();
}