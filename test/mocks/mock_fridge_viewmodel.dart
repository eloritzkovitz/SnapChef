import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'mock_ingredient_list_controller.dart';
import 'package:snapchef/models/ingredient.dart';

class MockFridgeViewModel extends ChangeNotifier implements FridgeViewModel {
  @override
  final MockIngredientListController fridgeController;
  @override
  final MockIngredientListController groceriesController;

  MockFridgeViewModel({
    MockIngredientListController? fridgeController,
    MockIngredientListController? groceriesController,
  })  : fridgeController = fridgeController ?? MockIngredientListController(),
        groceriesController =
            groceriesController ?? MockIngredientListController();

  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool addGrocerySuccess = true;
  bool addFridgeSuccess = true;

  @override
  List<Ingredient> get ingredients => [
        Ingredient(
          id: '1',
          name: 'Mock Ingredient 1',
          category: 'Vegetable',
          imageURL: 'assets/images/placeholder_image.png',
          count: 1,
        ),
        Ingredient(
          id: '2',
          name: 'Mock Ingredient 2',
          category: 'Protein',
          imageURL: 'assets/images/placeholder_image.png',
          count: 2,
        ),
      ];

  @override
  Future<void> fetchData({
    required String fridgeId,
    required IngredientViewModel ingredientViewModel,
  }) async {}

  @override
  Future<void> fetchFridgeIngredients(
      String fridgeId, ingredientViewModel) async {}

  @override
  Future<void> fetchGroceries(String fridgeId, ingredientViewModel) async {}

  @override
  Future<bool> addFridgeItem(String fridgeId, String id, String name,
          String category, String? imageURL, int quantity) async =>
      addFridgeSuccess;

  @override
  Future<bool> updateFridgeItem(
          String fridgeId, String itemId, int newCount) async =>
      true;

  @override
  Future<bool> deleteFridgeItem(String fridgeId, String itemId) async => true;

  @override
  Future<bool> addGroceryItem(String fridgeId, String id, String name,
          String category, String? imageURL, int quantity) async =>
      addGrocerySuccess;

  @override
  Future<bool> updateGroceryItem(
          String fridgeId, String itemId, int newCount) async =>
      true;

  @override
  Future<bool> deleteGroceryItem(String fridgeId, String itemId) async => true;

  @override
  Future<void> addGroceryToFridge(
      String fridgeId, Ingredient ingredient) async {}

  @override
  Future<void> reorderIngredient(
      int oldIndex, int newIndex, String fridgeId) async {}

  @override
  Future<void> reorderGroceryItem(
      int oldIndex, int newIndex, String fridgeId) async {}

  @override
  Future<void> saveFridgeOrder(String fridgeId) async {}

  @override
  Future<void> saveGroceriesOrder(String fridgeId) async {}

  @override
  void changeCount(
      {required int filteredIndex,
      required String fridgeId,
      required int delta}) {}

  @override
  Future<void> recognizeIngredients(dynamic image, String endpoint) async {}

  @override
  Future<void> updateFridgeIngredientImageURLs(
      dynamic ingredientViewModel, String fridgeId) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  void clear() {
  }
}
