import 'package:get_it/get_it.dart';
import '../models/ingredient.dart';
import '../database/app_database.dart' as db;
import '../services/fridge_service.dart';

class FridgeRepository {
  final db.AppDatabase database = GetIt.I<db.AppDatabase>();
  final FridgeService fridgeService = GetIt.I<FridgeService>();

  // --- Fridge Items ---

  Future<List<Ingredient>> fetchFridgeItemsRemote(String fridgeId) async {
    final items = await fridgeService.fetchFridgeItems(fridgeId);
    return items.map((item) => Ingredient(
      id: item['id'],
      name: item['name'],
      category: item['category'],
      imageURL: item['imageURL'] ?? '',
      count: item['quantity'],
    )).toList();
  }

  Future<List<Ingredient>> fetchFridgeItemsLocal(String fridgeId) async {
    final localItems = await database.fridgeIngredientDao.getFridgeItems(fridgeId: fridgeId);
    return localItems.map((dbIng) => Ingredient.fromDb(dbIng)).toList();
  }

  Future<void> storeFridgeItemsLocal(String fridgeId, List<Ingredient> items) async {
    for (final ingredient in items) {
      await database.fridgeIngredientDao.insertOrUpdateFridgeIngredient(
        ingredient.toDbFridgeIngredient(fridgeId: fridgeId),
      );
    }
  }

  Future<void> addOrUpdateFridgeItem(String fridgeId, Ingredient ingredient) async {
    await database.fridgeIngredientDao.insertOrUpdateFridgeIngredient(
      ingredient.toDbFridgeIngredient(fridgeId: fridgeId),
    );
  }

  Future<bool> addFridgeItemRemote(String fridgeId, Ingredient ingredient) async {
    final itemData = {
      'id': ingredient.id,
      'name': ingredient.name,
      'category': ingredient.category,
      'imageURL': ingredient.imageURL,
      'quantity': ingredient.count,
    };
    return await fridgeService.addFridgeItem(fridgeId, itemData);
  }

  Future<bool> updateFridgeItemRemote(String fridgeId, String itemId, int newCount) async {
    return await fridgeService.updateFridgeItem(fridgeId, itemId, newCount);
  }

  Future<void> deleteFridgeItemLocal(String itemId) async {
    await database.fridgeIngredientDao.deleteFridgeIngredient(itemId);
  }

  Future<bool> deleteFridgeItemRemote(String fridgeId, String itemId) async {
    return await fridgeService.deleteFridgeItem(fridgeId, itemId);
  }

  // --- Groceries ---

  Future<List<Ingredient>> fetchGroceriesRemote(String fridgeId) async {
    final items = await fridgeService.fetchGroceries(fridgeId);
    return items.map((item) => Ingredient(
      id: item['id'],
      name: item['name'],
      category: item['category'],
      imageURL: item['imageURL'] ?? '',
      count: item['quantity'] ?? 1,
    )).toList();
  }

  Future<List<Ingredient>> fetchGroceriesLocal(String fridgeId) async {
    final localItems = await database.fridgeIngredientDao.getGroceries(fridgeId: fridgeId);
    return localItems.map((dbIng) => Ingredient.fromDb(dbIng)).toList();
  }

  Future<void> storeGroceriesLocal(String fridgeId, List<Ingredient> groceries) async {
    for (final grocery in groceries) {
      await database.fridgeIngredientDao.insertGroceryItem(
        grocery.toDbFridgeIngredient(fridgeId: fridgeId, isInFridge: false),
      );
    }
  }

  Future<void> addOrUpdateGroceryItem(String fridgeId, Ingredient ingredient) async {
    await database.fridgeIngredientDao.insertGroceryItem(
      ingredient.toDbFridgeIngredient(fridgeId: fridgeId, isInFridge: false),
    );
  }

  Future<bool> addGroceryItemRemote(String fridgeId, Ingredient ingredient) async {
    final itemData = {
      'id': ingredient.id,
      'name': ingredient.name,
      'category': ingredient.category,
      'imageURL': ingredient.imageURL,
      'quantity': ingredient.count,
    };
    return await fridgeService.addGroceryItem(fridgeId, itemData);
  }

  Future<bool> updateGroceryItemRemote(String fridgeId, String itemId, int newCount) async {
    return await fridgeService.updateGroceryItem(fridgeId, itemId, newCount);
  }

  Future<void> deleteGroceryItemLocal(String itemId) async {
    await database.fridgeIngredientDao.deleteGroceryItem(itemId);
  }

  Future<bool> deleteGroceryItemRemote(String fridgeId, String itemId) async {
    return await fridgeService.deleteGroceryItem(fridgeId, itemId);
  }

  // --- Order Saving ---

  Future<void> saveFridgeOrder(String fridgeId, List<String> orderedIds) async {
    await fridgeService.saveFridgeOrder(fridgeId, orderedIds);
  }

  Future<void> saveGroceriesOrder(String fridgeId, List<String> orderedIds) async {
    await fridgeService.saveGroceriesOrder(fridgeId, orderedIds);
  }

  // --- Image URL Updates ---

  Future<void> updateFridgeItemImageURL(String fridgeId, String itemId, String imageUrl) async {
    await fridgeService.updateFridgeItemImageURL(fridgeId, itemId, imageUrl);
  }

  Future<void> updateGroceryItemImageURL(String fridgeId, String itemId, String imageUrl) async {
    await fridgeService.updateGroceryItemImageURL(fridgeId, itemId, imageUrl);
  }
}