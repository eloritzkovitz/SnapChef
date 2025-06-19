import 'package:snapchef/models/ingredient.dart';

class MockFridgeRepository {
  // Dummy fields to match the real repository's API
  final database = null;
  final fridgeService = null;

  // --- Fridge Items ---

  Future<List<Ingredient>> fetchFridgeItemsRemote(String fridgeId) async => [];

  Future<List<Ingredient>> fetchFridgeItemsLocal(String fridgeId) async => [];

  Future<void> storeFridgeItemsLocal(String fridgeId, List<Ingredient> items) async {}

  Future<void> addOrUpdateFridgeItem(String fridgeId, Ingredient ingredient) async {}

  Future<bool> addFridgeItemRemote(String fridgeId, Ingredient ingredient) async => true;

  Future<bool> updateFridgeItemRemote(String fridgeId, String itemId, int newCount) async => true;

  Future<void> deleteFridgeItemLocal(String itemId) async {}

  Future<bool> deleteFridgeItemRemote(String fridgeId, String itemId) async => true;

  // --- Groceries ---

  Future<List<Ingredient>> fetchGroceriesRemote(String fridgeId) async => [];

  Future<List<Ingredient>> fetchGroceriesLocal(String fridgeId) async => [];

  Future<void> storeGroceriesLocal(String fridgeId, List<Ingredient> groceries) async {}

  Future<void> addOrUpdateGroceryItem(String fridgeId, Ingredient ingredient) async {}

  Future<bool> addGroceryItemRemote(String fridgeId, Ingredient ingredient) async => true;

  Future<bool> updateGroceryItemRemote(String fridgeId, String itemId, int newCount) async => true;

  Future<void> deleteGroceryItemLocal(String itemId) async {}

  Future<bool> deleteGroceryItemRemote(String fridgeId, String itemId) async => true;

  // --- Order Saving ---

  Future<void> saveFridgeOrder(String fridgeId, List<String> orderedIds) async {}

  Future<void> saveGroceriesOrder(String fridgeId, List<String> orderedIds) async {}

  // --- Image URL Updates ---

  Future<void> updateFridgeItemImageURL(String fridgeId, String itemId, String imageUrl) async {}

  Future<void> updateGroceryItemImageURL(String fridgeId, String itemId, String imageUrl) async {}
}