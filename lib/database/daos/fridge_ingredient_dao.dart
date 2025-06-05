import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/fridge_ingredient_table.dart';

part 'fridge_ingredient_dao.g.dart';

@DriftAccessor(tables: [FridgeIngredients])
class FridgeIngredientDao extends DatabaseAccessor<AppDatabase> with _$FridgeIngredientDaoMixin {
  FridgeIngredientDao(super.db);

  // All fridge ingredients
  Future<List<FridgeIngredient>> getAllFridgeIngredients() => select(fridgeIngredients).get();

  // Fridge items
  Future<List<FridgeIngredient>> getFridgeItems({String? fridgeId}) =>
      (select(fridgeIngredients)
        ..where((i) => i.isInFridge.equals(true) & (fridgeId != null ? i.fridgeId.equals(fridgeId) : Constant(true))))
      .get();

  // Grocery items
  Future<List<FridgeIngredient>> getGroceries({String? fridgeId}) =>
      (select(fridgeIngredients)
        ..where((i) => i.isInFridge.equals(false) & (fridgeId != null ? i.fridgeId.equals(fridgeId) : Constant(true))))
      .get();

  // Insert/update/delete
  Future<int> insertFridgeIngredient(Insertable<FridgeIngredient> ingredient) =>
      into(fridgeIngredients).insertOnConflictUpdate(ingredient);
  Future<bool> updateFridgeIngredient(Insertable<FridgeIngredient> ingredient) =>
      update(fridgeIngredients).replace(ingredient);
  Future<int> deleteFridgeIngredient(String id) =>
      (delete(fridgeIngredients)..where((i) => i.id.equals(id))).go();

  // Move grocery to fridge
  Future<void> moveToFridge(String id) async {
    await (update(fridgeIngredients)..where((i) => i.id.equals(id)))
        .write(FridgeIngredientsCompanion(isInFridge: Value(true)));
  }
}