import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../database/app_database.dart' as db;
import '../models/ingredient.dart';
import '../providers/connectivity_provider.dart';
import '../services/image_service.dart';
import '../services/fridge_service.dart';
import '../viewmodels/ingredient_viewmodel.dart';
import '../services/sync_service.dart';

class FridgeViewModel extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];
  final List<Ingredient> _groceries = [];
  List<Ingredient> filteredIngredients = [];
  List<Ingredient> filteredGroceries = [];
  List<dynamic> recognizedIngredients = [];

  // Pending actions for offline sync
  final List<Map<String, dynamic>> _pendingFridgeActions = [];
  final List<Map<String, dynamic>> _pendingGroceryActions = [];
  final List<Map<String, dynamic>> _pendingFridgeOrderActions = [];
  final List<Map<String, dynamic>> _pendingGroceryOrderActions = [];

  // Service instances
  final FridgeService _fridgeService = FridgeService();
  final db.AppDatabase database;
  final ConnectivityProvider connectivityProvider;
  final SyncManager syncManager;

  FridgeViewModel({
    required this.database,
    required this.connectivityProvider,
    required this.syncManager,
  }) {
    syncManager.register(_syncPendingActions);
  }

  // Fridge filters/sorts
  String _filter = '';
  String? _selectedCategory;
  String? _selectedSortOption;

  // Grocery filters/sorts
  String _groceryFilter = '';
  String? _selectedGroceryCategory;
  String? _selectedGrocerySortOption;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);
  List<Ingredient> get groceries => List.unmodifiable(_groceries);
  String? get selectedCategory => _selectedCategory;
  String? get selectedSortOption => _selectedSortOption;

  // --- Fridge logic ---

  Future<void> fetchFridgeIngredients(
      String fridgeId, IngredientViewModel ingredientViewModel) async {
    _isLoading = true;
    notifyListeners();

    final isOffline = connectivityProvider.isOffline;
    if (isOffline) {
      await _loadFridgeIngredientsFromLocalDb(fridgeId);
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final items = await _fridgeService
          .fetchFridgeItems(fridgeId)
          .timeout(const Duration(seconds: 3), onTimeout: () {
        throw Exception('Network timeout');
      });

      _ingredients.clear();
      if (items.isNotEmpty) {
        _ingredients.addAll(
          items.map((item) => Ingredient(
                id: item['id'],
                name: item['name'],
                category: item['category'],
                imageURL:
                    item['imageURL'] ?? 'assets/images/placeholder_image.png',
                count: item['quantity'],
              )),
        );
        // Store locally for offline use
        await _storeFridgeIngredientsLocally(fridgeId, _ingredients);
      }

      // Update imageURLs using IngredientViewModel
      updateFridgeIngredientImageURLs(ingredientViewModel, fridgeId);
      _applyFiltersAndSorting();
    } catch (e) {
      log('Error fetching fridge ingredients: $e');
      await _loadFridgeIngredientsFromLocalDb(fridgeId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load from local DB
  Future<void> _loadFridgeIngredientsFromLocalDb(String fridgeId) async {
    final localIngredients =
        await database.fridgeIngredientDao.getFridgeItems(fridgeId: fridgeId);
    _ingredients.clear();
    _ingredients
        .addAll(localIngredients.map((dbIng) => Ingredient.fromDb(dbIng)));
    _applyFiltersAndSorting();
  }

  // Store to local DB
  Future<void> _storeFridgeIngredientsLocally(
      String fridgeId, List<Ingredient> ingredients) async {
    for (final ingredient in ingredients) {
      await database.fridgeIngredientDao.insertOrUpdateFridgeIngredient(
        ingredient.toDbFridgeIngredient(fridgeId: fridgeId),
      );
    }
  }

  // --- Grocery logic ---

  Future<void> fetchGroceries(
      String fridgeId, IngredientViewModel ingredientViewModel) async {
    final isOffline = connectivityProvider.isOffline;
    if (isOffline) {
      await _loadGroceriesFromLocalDb(fridgeId);
      notifyListeners();
      return;
    }

    try {
      final items = await _fridgeService.fetchGroceries(fridgeId);
      _groceries.clear();
      _groceries.addAll(items.map((item) => Ingredient(
            id: item['id'],
            name: item['name'],
            category: item['category'],
            imageURL: item['imageURL'] ?? '',
            count: item['quantity'] ?? 1,
          )));
      // Store locally for offline use
      await _storeGroceriesLocally(fridgeId, _groceries);

      // Update imageURLs using IngredientViewModel
      updateFridgeIngredientImageURLs(ingredientViewModel, fridgeId);

      _applyGroceryFiltersAndSorting();
    } catch (e) {
      log('Error fetching groceries: $e');
      await _loadGroceriesFromLocalDb(fridgeId);
    } finally {
      notifyListeners();
    }
  }

  // Load groceries from local database
  Future<void> _loadGroceriesFromLocalDb(String fridgeId) async {
    final localGroceries =
        await database.fridgeIngredientDao.getGroceries(fridgeId: fridgeId);
    _groceries.clear();
    _groceries.addAll(localGroceries.map((dbIng) => Ingredient.fromDb(dbIng)));
    _applyGroceryFiltersAndSorting();
  }

  // Store groceries locally using FridgeIngredientDao
  Future<void> _storeGroceriesLocally(
      String fridgeId, List<Ingredient> groceries) async {
    for (final grocery in groceries) {
      await database.fridgeIngredientDao.insertFridgeIngredient(
        grocery.toDbFridgeIngredient(fridgeId: fridgeId, isInFridge: false),
      );
    }
  }

  // Update ingredient image URLs based on IngredientViewModel
  Future<void> updateFridgeIngredientImageURLs(
      IngredientViewModel ingredientViewModel, String fridgeId) async {
    final allIngredients = ingredientViewModel.ingredients;

    // Build a map of id -> imageURL for fast lookup
    final imageUrlMap = {
      for (final ing in allIngredients) ing.id: ing.imageURL
    };

    // Update fridge ingredients
    for (final ingredient in _ingredients) {
      final newUrl = imageUrlMap[ingredient.id];
      if (newUrl != null && ingredient.imageURL != newUrl) {
        ingredient.imageURL = newUrl;
        // Persist change in backend
        try {
          await _fridgeService.updateFridgeItemImageURL(
            fridgeId,
            ingredient.id,
            newUrl,
          );
        } catch (e) {
          log('Error updating ingredient image URL: $e');
        }
      }
    }

    // Update groceries
    for (final grocery in _groceries) {
      final newUrl = imageUrlMap[grocery.id];
      if (newUrl != null && grocery.imageURL != newUrl) {
        grocery.imageURL = newUrl;
        // Persist change in backend
        try {
          await _fridgeService.updateGroceryItemImageURL(
            fridgeId,
            grocery.id,
            newUrl,
          );
        } catch (e) {
          log('Error updating grocery image URL: $e');
        }
      }
    }

    notifyListeners();
  }

  // --- Fridge add/update/delete ---

  @override
  void dispose() {
    syncManager.unregister(_syncPendingActions);
    super.dispose();
  }

  // Add an item to the fridge
  Future<bool> addFridgeItem(String fridgeId, String id, String name,
      String category, String? imageURL, int quantity) async {
    final ingredient = Ingredient(
      id: id,
      name: name,
      category: category,
      imageURL: imageURL ?? '',
      count: quantity,
    );
    try {
      // Always update local DB
      await database.fridgeIngredientDao.insertOrUpdateFridgeIngredient(
        ingredient.toDbFridgeIngredient(fridgeId: fridgeId),
      );
      final existingIngredientIndex =
          _ingredients.indexWhere((ingredient) => ingredient.id == id);

      if (existingIngredientIndex != -1) {
        final existingIngredient = _ingredients[existingIngredientIndex];
        final newQuantity = existingIngredient.count + quantity;

        if (connectivityProvider.isOffline) {
          _pendingFridgeActions.add({
            'action': 'update',
            'fridgeId': fridgeId,
            'itemId': existingIngredient.id,
            'newCount': newQuantity,
          });
          _ingredients[existingIngredientIndex].count = newQuantity;
          _applyFiltersAndSorting();
          notifyListeners();
          return true;
        }

        final success = await _fridgeService.updateFridgeItem(
            fridgeId, existingIngredient.id, newQuantity);
        if (success) {
          _ingredients[existingIngredientIndex].count = newQuantity;
          _applyFiltersAndSorting();
          return true;
        } else {
          log('Failed to update ingredient quantity');
          return false;
        }
      } else {
        if (connectivityProvider.isOffline) {
          _pendingFridgeActions.add({
            'action': 'add',
            'fridgeId': fridgeId,
            'ingredient': ingredient,
          });
          _ingredients.add(ingredient);
          _applyFiltersAndSorting();
          notifyListeners();
          return true;
        }

        final itemData = {
          'id': id,
          'name': name,
          'category': category,
          'imageURL': imageURL ?? '',
          'quantity': quantity,
        };

        final success = await _fridgeService.addFridgeItem(fridgeId, itemData);
        if (success) {
          _ingredients.add(ingredient);
          _applyFiltersAndSorting();
          return true;
        } else {
          log('Failed to add ingredient to fridge');
          return false;
        }
      }
    } catch (e) {
      log('Error adding ingredient to fridge: $e');
      _pendingFridgeActions.add({
        'action': 'add',
        'fridgeId': fridgeId,
        'ingredient': ingredient,
      });
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Update an item in the fridge
  Future<bool> updateFridgeItem(
      String fridgeId, String itemId, int newCount) async {
    try {
      // Always update local DB
      final index =
          _ingredients.indexWhere((ingredient) => ingredient.id == itemId);
      if (index != -1) {
        _ingredients[index].count = newCount;
        await database.fridgeIngredientDao.insertOrUpdateFridgeIngredient(
          _ingredients[index].toDbFridgeIngredient(fridgeId: fridgeId),
        );
        _applyFiltersAndSorting();
      }

      if (connectivityProvider.isOffline) {
        _pendingFridgeActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        notifyListeners();
        return true;
      }

      final success =
          await _fridgeService.updateFridgeItem(fridgeId, itemId, newCount);
      if (!success) {
        _pendingFridgeActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
      }
      return success;
    } catch (e) {
      log('Error updating item: $e');
      _pendingFridgeActions.add({
        'action': 'update',
        'fridgeId': fridgeId,
        'itemId': itemId,
        'newCount': newCount,
      });
      return false;
    } finally {
      notifyListeners();
    }
  }

  // --- Fridge reorder logic ---

  Future<void> reorderIngredient(
      int oldIndex, int newIndex, String fridgeId) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ingredient = filteredIngredients.removeAt(oldIndex);
    filteredIngredients.insert(newIndex, ingredient);

    // Also reorder in the main _ingredients list to keep everything in sync
    final oldId = ingredient.id;
    final oldMainIndex = _ingredients.indexWhere((i) => i.id == oldId);
    if (oldMainIndex != -1) {
      final mainIngredient = _ingredients.removeAt(oldMainIndex);

      // Find the new index in the main list based on the next ingredient in filteredIngredients
      int newMainIndex;
      if (newIndex + 1 < filteredIngredients.length) {
        final nextId = filteredIngredients[newIndex + 1].id;
        newMainIndex = _ingredients.indexWhere((i) => i.id == nextId);
        if (newMainIndex == -1) {
          newMainIndex = _ingredients.length;
        }
      } else {
        newMainIndex = _ingredients.length;
      }
      _ingredients.insert(newMainIndex, mainIngredient);
    }

    // Save the new order
    if (connectivityProvider.isOffline) {
      _pendingFridgeOrderActions.add({
        'action': 'reorder',
        'fridgeId': fridgeId,
        'orderedIds': _ingredients.map((i) => i.id).toList(),
      });
      // Optionally, persist order locally if needed
    } else {
      await saveFridgeOrder(fridgeId);
    }

    notifyListeners();
  }

  Future<void> saveFridgeOrder(String fridgeId) async {
    try {
      final orderedIds = _ingredients.map((i) => i.id).toList();
      await _fridgeService.saveFridgeOrder(fridgeId, orderedIds);
    } catch (e) {
      log('Error saving fridge order: $e');
    }
  }

  // Delete an item from the fridge
  Future<bool> deleteFridgeItem(String fridgeId, String itemId) async {
    try {
      // Always update local DB
      await database.fridgeIngredientDao.deleteFridgeIngredient(itemId);
      _ingredients.removeWhere((ingredient) => ingredient.id == itemId);
      _applyFiltersAndSorting();

      if (connectivityProvider.isOffline) {
        _pendingFridgeActions.add({
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
        notifyListeners();
        return true;
      }

      final success = await _fridgeService.deleteFridgeItem(fridgeId, itemId);
      if (!success) {
        _pendingFridgeActions.add({
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
      }
      return success;
    } catch (e) {
      log('Error deleting item: $e');
      _pendingFridgeActions.add({
        'action': 'delete',
        'fridgeId': fridgeId,
        'itemId': itemId,
      });
      return false;
    } finally {
      notifyListeners();
    }
  }

  // --- Grocery add/update/delete ---

  // Add an item to the grocery list
  Future<bool> addGroceryItem(String fridgeId, String id, String name,
      String category, String? imageURL, int quantity) async {
    final ingredient = Ingredient(
      id: id,
      name: name,
      category: category,
      imageURL: imageURL ?? '',
      count: quantity,
    );
    try {
      // Always update local DB
      await database.fridgeIngredientDao.insertGroceryItem(
        ingredient.toDbFridgeIngredient(fridgeId: fridgeId, isInFridge: false),
      );
      final existingGroceryIndex =
          _groceries.indexWhere((grocery) => grocery.id == id);

      if (existingGroceryIndex != -1) {
        final existingGrocery = _groceries[existingGroceryIndex];
        final newQuantity = existingGrocery.count + quantity;

        if (connectivityProvider.isOffline) {
          _pendingGroceryActions.add({
            'action': 'update',
            'fridgeId': fridgeId,
            'itemId': existingGrocery.id,
            'newCount': newQuantity,
          });
          _groceries[existingGroceryIndex].count = newQuantity;
          _applyGroceryFiltersAndSorting();
          notifyListeners();
          return true;
        }

        final success = await _fridgeService.updateGroceryItem(
            fridgeId, existingGrocery.id, newQuantity);
        if (success) {
          _groceries[existingGroceryIndex].count = newQuantity;
          _applyGroceryFiltersAndSorting();
          return true;
        } else {
          log('Failed to update grocery quantity');
          return false;
        }
      } else {
        if (connectivityProvider.isOffline) {
          _pendingGroceryActions.add({
            'action': 'add',
            'fridgeId': fridgeId,
            'ingredient': ingredient,
          });
          _groceries.add(ingredient);
          _applyGroceryFiltersAndSorting();
          notifyListeners();
          return true;
        }

        final itemData = {
          'id': id,
          'name': name,
          'category': category,
          'imageURL': imageURL,
          'quantity': quantity,
        };

        final success = await _fridgeService.addGroceryItem(fridgeId, itemData);
        if (success) {
          _groceries.add(ingredient);
          _applyGroceryFiltersAndSorting();
          return true;
        } else {
          log('Failed to add grocery item');
          return false;
        }
      }
    } catch (e) {
      log('Error adding grocery item: $e');
      _pendingGroceryActions.add({
        'action': 'add',
        'fridgeId': fridgeId,
        'ingredient': ingredient,
      });
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Update an item in the grocery list
  Future<bool> updateGroceryItem(
      String fridgeId, String itemId, int newCount) async {
    try {
      // Always update local DB
      final index =
          _groceries.indexWhere((ingredient) => ingredient.id == itemId);
      if (index != -1) {
        _groceries[index].count = newCount;
        await database.fridgeIngredientDao.insertFridgeIngredient(
          _groceries[index]
              .toDbFridgeIngredient(fridgeId: fridgeId, isInFridge: false),
        );
        _applyGroceryFiltersAndSorting();
      }

      if (connectivityProvider.isOffline) {
        _pendingGroceryActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        notifyListeners();
        return true;
      }

      final success =
          await _fridgeService.updateGroceryItem(fridgeId, itemId, newCount);
      if (!success) {
        _pendingGroceryActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
      }
      return success;
    } catch (e) {
      log('Error updating grocery item: $e');
      _pendingGroceryActions.add({
        'action': 'update',
        'fridgeId': fridgeId,
        'itemId': itemId,
        'newCount': newCount,
      });
      return false;
    } finally {
      notifyListeners();
    }
  }

  // --- Grocery reorder logic ---

  Future<void> reorderGroceryItem(
      int oldIndex, int newIndex, String fridgeId) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = filteredGroceries.removeAt(oldIndex);
    filteredGroceries.insert(newIndex, item);

    // Also reorder in the main groceries list
    final oldId = item.id;
    final oldMainIndex = _groceries.indexWhere((g) => g.id == oldId);
    if (oldMainIndex != -1) {
      final mainItem = _groceries.removeAt(oldMainIndex);
      int newMainIndex;
      if (newIndex + 1 < filteredGroceries.length) {
        final nextId = filteredGroceries[newIndex + 1].id;
        newMainIndex = _groceries.indexWhere((g) => g.id == nextId);
        if (newMainIndex == -1) newMainIndex = _groceries.length;
      } else {
        newMainIndex = _groceries.length;
      }
      _groceries.insert(newMainIndex, mainItem);
    }

    // Save the new order
    if (connectivityProvider.isOffline) {
      _pendingGroceryOrderActions.add({
        'action': 'reorder',
        'fridgeId': fridgeId,
        'orderedIds': _groceries.map((g) => g.id).toList(),
      });
      // Optionally, persist order locally if needed
    } else {
      await saveGroceriesOrder(fridgeId);
    }

    notifyListeners();
  }

  Future<void> saveGroceriesOrder(String fridgeId) async {
    try {
      final orderedIds = _groceries.map((g) => g.id).toList();
      await _fridgeService.saveGroceriesOrder(fridgeId, orderedIds);
    } catch (e) {
      log('Error saving groceries order: $e');
    }
  }

  // Delete an item from the grocery list
  Future<bool> deleteGroceryItem(String fridgeId, String itemId) async {
    try {
      // Always update local DB
      await database.fridgeIngredientDao.deleteGroceryItem(itemId);
      _groceries.removeWhere((ingredient) => ingredient.id == itemId);
      _applyGroceryFiltersAndSorting();

      if (connectivityProvider.isOffline) {
        _pendingGroceryActions.add({
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
        notifyListeners();
        return true;
      }

      final success = await _fridgeService.deleteGroceryItem(fridgeId, itemId);
      if (!success) {
        _pendingGroceryActions.add({
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
      }
      return success;
    } catch (e) {
      log('Error deleting grocery item: $e');
      _pendingGroceryActions.add({
        'action': 'delete',
        'fridgeId': fridgeId,
        'itemId': itemId,
      });
      return false;
    } finally {
      notifyListeners();
    }
  }

  // --- Sync logic ---
  Future<void> _syncPendingActions() async {
    // Sync fridge actions (add/update/delete)
    if (_pendingFridgeActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(_pendingFridgeActions)) {
        try {
          switch (action['action']) {
            case 'add':
              final ingredient = action['ingredient'] as Ingredient;
              final fridgeId = action['fridgeId'] as String;
              final itemData = {
                'id': ingredient.id,
                'name': ingredient.name,
                'category': ingredient.category,
                'imageURL': ingredient.imageURL,
                'quantity': ingredient.count,
              };
              await _fridgeService.addFridgeItem(fridgeId, itemData);
              break;
            case 'update':
              await _fridgeService.updateFridgeItem(
                action['fridgeId'],
                action['itemId'],
                action['newCount'],
              );
              break;
            case 'delete':
              await _fridgeService.deleteFridgeItem(
                action['fridgeId'],
                action['itemId'],
              );
              break;
          }
          _pendingFridgeActions.remove(action);
        } catch (e) {
          log('Failed to sync fridge action: $e');
          break;
        }
      }
    }

    // Sync fridge reorder actions
    if (_pendingFridgeOrderActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(_pendingFridgeOrderActions)) {
        try {
          if (action['action'] == 'reorder') {
            await _fridgeService.saveFridgeOrder(
              action['fridgeId'],
              List<String>.from(action['orderedIds']),
            );
          }
          _pendingFridgeOrderActions.remove(action);
        } catch (e) {
          log('Failed to sync fridge order: $e');
          break;
        }
      }
    }

    // Sync grocery actions (add/update/delete)
    if (_pendingGroceryActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(_pendingGroceryActions)) {
        try {
          switch (action['action']) {
            case 'add':
              final ingredient = action['ingredient'] as Ingredient;
              final fridgeId = action['fridgeId'] as String;
              final itemData = {
                'id': ingredient.id,
                'name': ingredient.name,
                'category': ingredient.category,
                'imageURL': ingredient.imageURL,
                'quantity': ingredient.count,
              };
              await _fridgeService.addGroceryItem(fridgeId, itemData);
              break;
            case 'update':
              await _fridgeService.updateGroceryItem(
                action['fridgeId'],
                action['itemId'],
                action['newCount'],
              );
              break;
            case 'delete':
              await _fridgeService.deleteGroceryItem(
                action['fridgeId'],
                action['itemId'],
              );
              break;
          }
          _pendingGroceryActions.remove(action);
        } catch (e) {
          log('Failed to sync grocery action: $e');
          break;
        }
      }
    }

    // Sync grocery reorder actions
    if (_pendingGroceryOrderActions.isNotEmpty) {
      for (final action
          in List<Map<String, dynamic>>.from(_pendingGroceryOrderActions)) {
        try {
          if (action['action'] == 'reorder') {
            await _fridgeService.saveGroceriesOrder(
              action['fridgeId'],
              List<String>.from(action['orderedIds']),
            );
          }
          _pendingGroceryOrderActions.remove(action);
        } catch (e) {
          log('Failed to sync groceries order: $e');
          break;
        }
      }
    }

    notifyListeners();
  }

  // --- Generic filtering and sorting logic ---

  List<Ingredient> _applyGenericFiltersAndSorting({
    required List<Ingredient> source,
    required String filter,
    required String? category,
    required String? sortOption,
  }) {
    var result = List<Ingredient>.from(source);

    if (category != null && category.isNotEmpty) {
      result = result
          .where((ingredient) =>
              ingredient.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (filter.isNotEmpty) {
      result = result
          .where((ingredient) =>
              ingredient.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }

    if (sortOption == 'Name') {
      result.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortOption == 'Quantity') {
      result.sort((a, b) => b.count.compareTo(a.count));
    }

    return result;
  }

  // --- Filtering and sorting for fridge ---

  List<String> getCategories() {
    final categories =
        _ingredients.map((ingredient) => ingredient.category).toSet().toList();
    categories.sort();
    return categories;
  }

  set selectedCategory(String? value) {
    _selectedCategory = value;
    _applyFiltersAndSorting();
  }

  set selectedSortOption(String? value) {
    _selectedSortOption = value;
    _applyFiltersAndSorting();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFiltersAndSorting();
  }

  void sortIngredients(String? sortOption) {
    _selectedSortOption = sortOption;
    _applyFiltersAndSorting();
  }

  void setFilter(String filter) {
    _filter = filter;
    _applyFiltersAndSorting();
  }

  void _applyFiltersAndSorting() {
    filteredIngredients = _applyGenericFiltersAndSorting(
      source: _ingredients,
      filter: _filter,
      category: _selectedCategory,
      sortOption: _selectedSortOption,
    );
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedSortOption = null;
    _filter = '';
    _applyFiltersAndSorting();
  }

  // --- Filtering and sorting for groceries ---

  List<String> getGroceryCategories() {
    final categories =
        _groceries.map((ingredient) => ingredient.category).toSet().toList();
    categories.sort();
    return categories;
  }

  String? get selectedGroceryCategory => _selectedGroceryCategory;
  String? get selectedGrocerySortOption => _selectedGrocerySortOption;

  void filterGroceriesByCategory(String? category) {
    _selectedGroceryCategory = category;
    _applyGroceryFiltersAndSorting();
  }

  void sortGroceries(String? sortOption) {
    _selectedGrocerySortOption = sortOption;
    _applyGroceryFiltersAndSorting();
  }

  void setGroceryFilter(String filter) {
    _groceryFilter = filter;
    _applyGroceryFiltersAndSorting();
  }

  void _applyGroceryFiltersAndSorting() {
    filteredGroceries = _applyGenericFiltersAndSorting(
      source: _groceries,
      filter: _groceryFilter,
      category: _selectedGroceryCategory,
      sortOption: _selectedGrocerySortOption,
    );
    notifyListeners();
  }

  void clearGroceryFilters() {
    _selectedGroceryCategory = null;
    _selectedGrocerySortOption = null;
    _groceryFilter = '';
    _applyGroceryFiltersAndSorting();
  }

  // --- Image recognition ---

  Future<void> recognizeIngredients(File image, String endpoint) async {
    _isLoading = true;
    recognizedIngredients = [];
    notifyListeners();

    try {
      final uploadPhoto = ImageService();
      recognizedIngredients = await uploadPhoto.processImage(image, endpoint);
    } catch (e) {
      log('Error recognizing ingredients: $e');
      recognizedIngredients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Move grocery to fridge ---

  Future<void> addGroceryToFridge(
      String fridgeId, Ingredient ingredient) async {
    // Check if the ingredient is already in the fridge
    final fridgeIndex = _ingredients.indexWhere((i) => i.id == ingredient.id);

    if (fridgeIndex != -1) {
      // Already in fridge: increment count
      final existing = _ingredients[fridgeIndex];
      final newCount = existing.count + ingredient.count;

      // Update in local DB
      await database.fridgeIngredientDao.insertOrUpdateFridgeIngredient(
        existing
            .toDbFridgeIngredient(fridgeId: fridgeId, isInFridge: true)
            .copyWith(count: newCount),
      );

      // Update in memory
      _ingredients[fridgeIndex].count = newCount;
    } else {
      // Not in fridge: add as new fridge item
      await database.fridgeIngredientDao.insertOrUpdateFridgeIngredient(
        ingredient.toDbFridgeIngredient(fridgeId: fridgeId, isInFridge: true),
      );
      _ingredients.add(ingredient);
    }

    // Remove from groceries in local DB and memory
    await database.fridgeIngredientDao.deleteGroceryItem(ingredient.id);
    _groceries.removeWhere((g) => g.id == ingredient.id);

    _applyFiltersAndSorting();
    _applyGroceryFiltersAndSorting();
    notifyListeners();

    // Optionally, sync with backend if online
    if (!connectivityProvider.isOffline) {
      await addFridgeItem(
        fridgeId,
        ingredient.id,
        ingredient.name,
        ingredient.category,
        ingredient.imageURL,
        ingredient.count,
      );
      await deleteGroceryItem(fridgeId, ingredient.id);
    } else {
      // Add to pending actions for sync
      _pendingFridgeActions.add({
        'action': 'update',
        'fridgeId': fridgeId,
        'itemId': ingredient.id,
        'newCount': _ingredients.firstWhere((i) => i.id == ingredient.id).count,
      });
      _pendingGroceryActions.add({
        'action': 'delete',
        'fridgeId': fridgeId,
        'itemId': ingredient.id,
      });
    }
  }

  // --- Increase/decrease count for fridge items ---

  void increaseCount(int filteredIndex, String fridgeId) async {
    final ingredient = filteredIngredients[filteredIndex];
    final newCount = ingredient.count + 1;

    final success = await updateFridgeItem(fridgeId, ingredient.id, newCount);
    if (success) {
      final mainIndex =
          _ingredients.indexWhere((ing) => ing.id == ingredient.id);
      if (mainIndex != -1) {
        _ingredients[mainIndex].count = newCount;
      }
      _applyFiltersAndSorting();
      notifyListeners();
    }
  }

  void decreaseCount(int filteredIndex, String fridgeId) async {
    final ingredient = filteredIngredients[filteredIndex];
    if (ingredient.count > 1) {
      final newCount = ingredient.count - 1;

      final success = await updateFridgeItem(fridgeId, ingredient.id, newCount);
      if (success) {
        final mainIndex =
            _ingredients.indexWhere((ing) => ing.id == ingredient.id);
        if (mainIndex != -1) {
          _ingredients[mainIndex].count = newCount;
        }
        _applyFiltersAndSorting();
        notifyListeners();
      }
    }
  }
}
