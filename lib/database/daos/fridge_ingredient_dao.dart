import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/fridge_ingredient_table.dart';

part 'fridge_ingredient_dao.g.dart';

@DriftAccessor(tables: [FridgeIngredients])
class FridgeIngredientDao extends DatabaseAccessor<AppDatabase>
    with _$FridgeIngredientDaoMixin {
  FridgeIngredientDao(super.db);

  // All fridge ingredients
  Future<List<FridgeIngredient>> getAllFridgeIngredients() =>
      select(fridgeIngredients).get();

  // --- Fridge Item Operations ---

  // Fridge items
  Future<List<FridgeIngredient>> getFridgeItems({String? fridgeId}) =>
      (select(fridgeIngredients)
            ..where((i) =>
                i.isInFridge.equals(true) &
                (fridgeId != null
                    ? i.fridgeId.equals(fridgeId)
                    : Constant(true))))
          .get();  

  // Insert a fridge ingredient
  Future<int> insertFridgeIngredient(Insertable<FridgeIngredient> ingredient) =>
      into(fridgeIngredients).insertOnConflictUpdate(ingredient);
  
  // Update a fridge ingredient
  Future<bool> updateFridgeIngredient(
          Insertable<FridgeIngredient> ingredient) =>
      update(fridgeIngredients).replace(ingredient);
  
  // Insert or update a fridge ingredient
  Future<int> insertOrUpdateFridgeIngredient(
          Insertable<FridgeIngredient> ingredient) =>
      into(fridgeIngredients).insertOnConflictUpdate(ingredient);
  
  // Delete a fridge ingredient by id
  Future<int> deleteFridgeIngredient(String id) =>
      (delete(fridgeIngredients)..where((i) => i.id.equals(id))).go();

  // --- Grocery Item Operations ---

  // Grocery items
  Future<List<FridgeIngredient>> getGroceries({String? fridgeId}) =>
      (select(fridgeIngredients)
            ..where((i) =>
                i.isInFridge.equals(false) &
                (fridgeId != null
                    ? i.fridgeId.equals(fridgeId)
                    : Constant(true))))
          .get();

  // Insert a grocery item (isInFridge = false)
  Future<int> insertGroceryItem(Insertable<FridgeIngredient> ingredient) =>
      into(fridgeIngredients).insertOnConflictUpdate(ingredient);

  // Update a grocery item (isInFridge = false)
  Future<bool> updateGroceryItem(Insertable<FridgeIngredient> ingredient) =>
      update(fridgeIngredients).replace(ingredient);

  // Delete a grocery item by id (isInFridge = false)
  Future<int> deleteGroceryItem(String id) => (delete(fridgeIngredients)
        ..where((i) => i.id.equals(id) & i.isInFridge.equals(false)))
      .go();

  // Move fridge item to grocery (set isInFridge = false)
  Future<void> moveToGrocery(String id) async {
    await (update(fridgeIngredients)..where((i) => i.id.equals(id)))
        .write(FridgeIngredientsCompanion(isInFridge: Value(false)));
  }

  // Move grocery to fridge
  Future<void> moveToFridge(String id) async {
    await (update(fridgeIngredients)..where((i) => i.id.equals(id)))
        .write(FridgeIngredientsCompanion(isInFridge: Value(true)));
  }
}
