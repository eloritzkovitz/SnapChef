import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recipe_table.dart';

part 'recipe_dao.g.dart';

@DriftAccessor(tables: [Recipes])
class RecipeDao extends DatabaseAccessor<AppDatabase> with _$RecipeDaoMixin {
  RecipeDao(super.db);

  // Get all recipes for a user (the user's cookbook)
  Future<List<Recipe>> getCookbookRecipes(String userId) =>
      (select(recipes)..where((r) => r.userId.equals(userId))).get();

  // Watch all recipes for a user (reactive)
  Stream<List<Recipe>> watchCookbookRecipes(String userId) =>
      (select(recipes)..where((r) => r.userId.equals(userId))).watch();

  // Get a single recipe by id
  Future<Recipe?> getRecipeById(String id) =>
      (select(recipes)..where((r) => r.id.equals(id))).getSingleOrNull();

  // Insert or update a recipe
  Future<int> insertOrUpdateRecipe(Insertable<Recipe> recipe) =>
      into(recipes).insertOnConflictUpdate(recipe);

  // Update a recipe
  Future<bool> updateRecipe(Insertable<Recipe> recipe) =>
      update(recipes).replace(recipe);

  // Delete a recipe
  Future<int> deleteRecipe(String id) =>
      (delete(recipes)..where((r) => r.id.equals(id))).go();

  // Search recipes by title for a user
  Future<List<Recipe>> searchRecipes(String userId, String query) =>
      (select(recipes)
            ..where((r) => r.userId.equals(userId) & r.title.like('%$query%')))
          .get();

  // Filter by meal type (category) for a user
  Future<List<Recipe>> filterByCategory(String userId, String category) =>
      (select(recipes)
            ..where(
                (r) => r.userId.equals(userId) & r.mealType.equals(category)))
          .get();

  // Filter by cuisine for a user
  Future<List<Recipe>> filterByCuisine(String userId, String cuisine) =>
      (select(recipes)
            ..where(
                (r) => r.userId.equals(userId) & r.cuisineType.equals(cuisine)))
          .get();

  // Filter by difficulty for a user
  Future<List<Recipe>> filterByDifficulty(String userId, String difficulty) =>
      (select(recipes)
            ..where((r) =>
                r.userId.equals(userId) & r.difficulty.equals(difficulty)))
          .get();

  // Filter by prep time for a user
  Future<List<Recipe>> filterByPrepTime(String userId, int min, int max) =>
      (select(recipes)
            ..where((r) =>
                r.userId.equals(userId) & r.prepTime.isBetweenValues(min, max)))
          .get();

  // Filter by cooking time for a user
  Future<List<Recipe>> filterByCookingTime(String userId, int min, int max) =>
      (select(recipes)
            ..where((r) =>
                r.userId.equals(userId) &
                r.cookingTime.isBetweenValues(min, max)))
          .get();

  // Filter by rating for a user
  Future<List<Recipe>> filterByRating(String userId, double min, double max) =>
      (select(recipes)
            ..where((r) =>
                r.userId.equals(userId) &
                r.rating.isBiggerOrEqualValue(min) &
                r.rating.isSmallerOrEqualValue(max)))
          .get();

  // Filter by source for a user
  Future<List<Recipe>> filterBySource(String userId, String source) =>
      (select(recipes)
            ..where((r) => r.userId.equals(userId) & r.source.equals(source)))
          .get();

  // Mark as favorite
  Future<int> toggleFavorite(String id, bool isFavorite) =>
      (update(recipes)..where((r) => r.id.equals(id)))
          .write(RecipesCompanion(isFavorite: Value(isFavorite)));

  // Get all recipes ordered by their 'order' field for a user
  Future<List<Recipe>> getCookbookRecipesOrdered(String userId) =>
    (select(recipes)
          ..where((r) => r.userId.equals(userId))
          ..orderBy([(r) => OrderingTerm(expression: r.order)]))
        .get();

  // Save the order of recipes by updating their 'order' field
  Future<void> saveRecipeOrder(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      await (update(recipes)..where((r) => r.id.equals(orderedIds[i])))
          .write(RecipesCompanion(order: Value(i)));
    }
  }
}
