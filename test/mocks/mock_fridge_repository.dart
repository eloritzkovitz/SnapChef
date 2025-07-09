import 'package:mockito/mockito.dart';
import 'package:snapchef/database/app_database.dart' hide Ingredient;
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/repositories/fridge_repository.dart';
import 'package:snapchef/services/fridge_service.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {
  // Provide getters for required fields
  @override
  AppDatabase get database => throw UnimplementedError();

  @override
  FridgeService get fridgeService => throw UnimplementedError();

  // --- Fridge Items ---

  @override
  Future<List<Ingredient>> fetchFridgeItemsRemote(String fridgeId) async => [];

  @override
  Future<List<Ingredient>> fetchFridgeItemsLocal(String fridgeId) async => [];

  @override
  Future<void> storeFridgeItemsLocal(String fridgeId, List<Ingredient> items) async {}

  @override
  Future<void> addOrUpdateFridgeItem(String fridgeId, Ingredient ingredient) async {}

  @override
  Future<bool> addFridgeItemRemote(String fridgeId, Ingredient ingredient) async => true;

  @override
  Future<bool> updateFridgeItemRemote(String fridgeId, String itemId, int newCount) async => true;

  @override
  Future<void> deleteFridgeItemLocal(String itemId) async {}

  @override
  Future<bool> deleteFridgeItemRemote(String fridgeId, String itemId) async => true;

  // --- Groceries ---

  @override
  Future<List<Ingredient>> fetchGroceriesRemote(String fridgeId) async => [];

  @override
  Future<List<Ingredient>> fetchGroceriesLocal(String fridgeId) async => [];

  @override
  Future<void> storeGroceriesLocal(String fridgeId, List<Ingredient> groceries) async {}

  @override
  Future<void> addOrUpdateGroceryItem(String fridgeId, Ingredient ingredient) async {}

  @override
  Future<bool> addGroceryItemRemote(String fridgeId, Ingredient ingredient) async => true;

  @override
  Future<bool> updateGroceryItemRemote(String fridgeId, String itemId, int newCount) async => true;

  @override
  Future<void> deleteGroceryItemLocal(String itemId) async {}

  @override
  Future<bool> deleteGroceryItemRemote(String fridgeId, String itemId) async => true;

  // --- Order Saving ---

  @override
  Future<void> saveFridgeOrder(String fridgeId, List<String> orderedIds) async {}

  @override
  Future<void> saveGroceriesOrder(String fridgeId, List<String> orderedIds) async {}

  // --- Image URL Updates ---

  @override
  Future<void> updateFridgeItemImageURL(String fridgeId, String itemId, String imageUrl) async {}

  @override
  Future<void> updateGroceryItemImageURL(String fridgeId, String itemId, String imageUrl) async {}
}
