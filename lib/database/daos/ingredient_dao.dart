import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ingredient_table.dart';

part 'ingredient_dao.g.dart';

@DriftAccessor(tables: [Ingredients])
class IngredientDao extends DatabaseAccessor<AppDatabase> with _$IngredientDaoMixin {
  IngredientDao(super.db);

  Future<List<Ingredient>> getAllIngredients() => select(ingredients).get();
  Stream<List<Ingredient>> watchAllIngredients() => select(ingredients).watch();
  Future<Ingredient?> getIngredientById(String id) =>
      (select(ingredients)..where((m) => m.id.equals(id))).getSingleOrNull();
  Future<int> insertIngredient(Insertable<Ingredient> ingredient) =>
      into(ingredients).insertOnConflictUpdate(ingredient);
  Future<int> deleteIngredient(String id) =>
      (delete(ingredients)..where((m) => m.id.equals(id))).go();
}