import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../mixins/fridge_sync_mixin.dart';
import '../mixins/fridge_filter_mixin.dart';
import '../mixins/helpers_mixin.dart';
import '../models/ingredient.dart';
import '../providers/connectivity_provider.dart';
import '../services/image_service.dart';
import '../viewmodels/ingredient_viewmodel.dart';
import '../services/sync_service.dart';
import '../repositories/fridge_repository.dart';
import '../services/fridge_service.dart';

class FridgeViewModel extends ChangeNotifier
    with FridgeFilterMixin, FridgeSyncMixin, HelpersMixin {
  // --- Fields & Constructor ---
  final List<Ingredient> _ingredients = [];
  final List<Ingredient> _groceries = [];
  List<dynamic> recognizedIngredients = [];

  @override
  List<Ingredient> get ingredientsSource => _ingredients;
  @override
  List<Ingredient> get groceriesSource => _groceries;
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);
  List<Ingredient> get groceries => List.unmodifiable(_groceries);

  final ConnectivityProvider connectivityProvider;
  final SyncManager syncManager;
  final FridgeRepository fridgeRepository;

  @override
  FridgeService get fridgeService => fridgeRepository.fridgeService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FridgeViewModel({
    required this.connectivityProvider,
    required this.syncManager,
    required this.fridgeRepository,
  }) {
    syncManager.register(syncPendingActions);
    initFridgeSync(connectivityProvider);
  }

  @override
  void dispose() {
    disposeFridgeSync();
    syncManager.unregister(syncPendingActions);
    super.dispose();
  }

  // --- Data Fetching & Sync ---
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

    await syncPendingActions();

    try {
      final remoteItems =
          await fridgeRepository.fetchFridgeItemsRemote(fridgeId);
      final localItems = await fridgeRepository.fetchFridgeItemsLocal(fridgeId);

      // Merge: keep local-only items (not in remote)
      final remoteIds = remoteItems.map((i) => i.id).toSet();
      final localOnlyItems =
          localItems.where((i) => !remoteIds.contains(i.id)).toList();

      updateAndNotify(() {
        _ingredients.clear();
        _ingredients.addAll(remoteItems);
        _ingredients.addAll(localOnlyItems);
      }, applyFiltersAndSorting);

      // Store merged list locally
      await fridgeRepository.storeFridgeItemsLocal(fridgeId, _ingredients);

      // Update imageURLs using IngredientViewModel
      await updateFridgeIngredientImageURLs(ingredientViewModel, fridgeId);
    } catch (e) {
      log('Error fetching fridge ingredients: $e');
      await _loadFridgeIngredientsFromLocalDb(fridgeId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroceries(
      String fridgeId, IngredientViewModel ingredientViewModel) async {
    final isOffline = connectivityProvider.isOffline;
    if (isOffline) {
      await _loadGroceriesFromLocalDb(fridgeId);
      notifyListeners();
      return;
    }

    await syncPendingActions();

    try {
      final remoteItems = await fridgeRepository.fetchGroceriesRemote(fridgeId);
      final localItems = await fridgeRepository.fetchGroceriesLocal(fridgeId);

      // Merge: keep local-only items (not in remote)
      final remoteIds = remoteItems.map((i) => i.id).toSet();
      final localOnlyItems =
          localItems.where((i) => !remoteIds.contains(i.id)).toList();

      updateAndNotify(() {
        _groceries.clear();
        _groceries.addAll(remoteItems);
        _groceries.addAll(localOnlyItems);
      }, applyGroceryFiltersAndSorting);

      // Store merged list locally
      await fridgeRepository.storeGroceriesLocal(fridgeId, _groceries);

      // Update imageURLs using IngredientViewModel
      await updateFridgeIngredientImageURLs(ingredientViewModel, fridgeId);
    } catch (e) {
      log('Error fetching groceries: $e');
      await _loadGroceriesFromLocalDb(fridgeId);
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadFridgeIngredientsFromLocalDb(String fridgeId) async {
    final localIngredients =
        await fridgeRepository.fetchFridgeItemsLocal(fridgeId);
    updateAndNotify(() {
      _ingredients.clear();
      _ingredients.addAll(localIngredients);
    }, applyFiltersAndSorting);
  }

  Future<void> _loadGroceriesFromLocalDb(String fridgeId) async {
    final localGroceries = await fridgeRepository.fetchGroceriesLocal(fridgeId);
    updateAndNotify(() {
      _groceries.clear();
      _groceries.addAll(localGroceries);
    }, applyGroceryFiltersAndSorting);
  }

  // --- Add/Update/Delete Helpers ---
  Future<bool> _addOrUpdateIngredient({
    required List<Ingredient> list,
    required String fridgeId,
    required Ingredient ingredient,
    required Future<void> Function() localDbAction,
    required Future<bool> Function() remoteAddAction,
    required Future<bool> Function(int) remoteUpdateAction,
    required List<Map<String, dynamic>> pendingActions,
    required bool isOffline,
    required void Function() applyFilters,
  }) async {
    await localDbAction();
    final idx = list.indexWhere((i) => i.id == ingredient.id);

    if (idx != -1) {
      final newQuantity = list[idx].count + ingredient.count;
      if (isOffline) {
        pendingActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': ingredient.id,
          'newCount': newQuantity,
        });
        updateAndNotify(() {
          list[idx].count = newQuantity;
        }, applyFilters);
        return true;
      }
      final success = await remoteUpdateAction(newQuantity);
      if (success) {
        updateAndNotify(() {
          list[idx].count = newQuantity;
        }, applyFilters);
        return true;
      } else {
        return false;
      }
    } else {
      if (isOffline) {
        pendingActions.add({
          'action': 'add',
          'fridgeId': fridgeId,
          'ingredient': ingredient,
        });
        updateAndNotify(() {
          list.add(ingredient);
        }, applyFilters);
        return true;
      }
      final success = await remoteAddAction();
      if (success) {
        updateAndNotify(() {
          list.add(ingredient);
        }, applyFilters);
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> _deleteIngredient({
    required List<Ingredient> list,
    required String fridgeId,
    required String itemId,
    required Future<void> Function() localDbAction,
    required Future<bool> Function() remoteDeleteAction,
    required List<Map<String, dynamic>> pendingActions,
    required bool isOffline,
    required void Function() applyFilters,
  }) async {
    try {
      await localDbAction();
      updateAndNotify(() {
        list.removeWhere((ingredient) => ingredient.id == itemId);
      }, applyFilters);

      if (isOffline) {
        pendingActions.add({
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
        notifyListeners();
        return true;
      }

      final success = await remoteDeleteAction();
      if (!success) {
        pendingActions.add({
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
      }
      return success;
    } catch (e) {
      pendingActions.add({
        'action': 'delete',
        'fridgeId': fridgeId,
        'itemId': itemId,
      });
      return false;
    } finally {
      notifyListeners();
    }
  }

  // --- Fridge CRUD ---
  Future<bool> addFridgeItem(String fridgeId, String id, String name,
      String category, String? imageURL, int quantity) async {
    final ingredient = Ingredient(
      id: id,
      name: name,
      category: category,
      imageURL: imageURL ?? '',
      count: quantity,
    );
    return _addOrUpdateIngredient(
      list: _ingredients,
      fridgeId: fridgeId,
      ingredient: ingredient,
      localDbAction: () =>
          fridgeRepository.addOrUpdateFridgeItem(fridgeId, ingredient),
      remoteAddAction: () =>
          fridgeRepository.addFridgeItemRemote(fridgeId, ingredient),
      remoteUpdateAction: (newCount) => fridgeRepository.updateFridgeItemRemote(
          fridgeId, ingredient.id, newCount),
      pendingActions: pendingFridgeActions,
      isOffline: connectivityProvider.isOffline,
      applyFilters: applyFiltersAndSorting,
    );
  }

  Future<bool> updateFridgeItem(
      String fridgeId, String itemId, int newCount) async {
    try {
      final index =
          _ingredients.indexWhere((ingredient) => ingredient.id == itemId);
      if (index != -1) {
        updateAndNotify(() {
          _ingredients[index].count = newCount;
        }, applyFiltersAndSorting);
        await fridgeRepository.addOrUpdateFridgeItem(
          fridgeId,
          _ingredients[index],
        );
      }

      if (connectivityProvider.isOffline) {
        pendingFridgeActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        notifyListeners();
        return true;
      }

      final success = await fridgeRepository.updateFridgeItemRemote(
          fridgeId, itemId, newCount);
      if (!success) {
        pendingFridgeActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
      }
      return success;
    } catch (e) {
      log('Error updating item: $e');
      pendingFridgeActions.add({
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

  Future<bool> deleteFridgeItem(String fridgeId, String itemId) async {
    return _deleteIngredient(
      list: _ingredients,
      fridgeId: fridgeId,
      itemId: itemId,
      localDbAction: () => fridgeRepository.deleteFridgeItemLocal(itemId),
      remoteDeleteAction: () =>
          fridgeRepository.deleteFridgeItemRemote(fridgeId, itemId),
      pendingActions: pendingFridgeActions,
      isOffline: connectivityProvider.isOffline,
      applyFilters: applyFiltersAndSorting,
    );
  }

  // --- Grocery CRUD ---
  Future<bool> addGroceryItem(String fridgeId, String id, String name,
      String category, String? imageURL, int quantity) async {
    final ingredient = Ingredient(
      id: id,
      name: name,
      category: category,
      imageURL: imageURL ?? '',
      count: quantity,
    );
    return _addOrUpdateIngredient(
      list: _groceries,
      fridgeId: fridgeId,
      ingredient: ingredient,
      localDbAction: () =>
          fridgeRepository.addOrUpdateGroceryItem(fridgeId, ingredient),
      remoteAddAction: () =>
          fridgeRepository.addGroceryItemRemote(fridgeId, ingredient),
      remoteUpdateAction: (newCount) => fridgeRepository
          .updateGroceryItemRemote(fridgeId, ingredient.id, newCount),
      pendingActions: pendingGroceryActions,
      isOffline: connectivityProvider.isOffline,
      applyFilters: applyGroceryFiltersAndSorting,
    );
  }

  Future<bool> updateGroceryItem(
      String fridgeId, String itemId, int newCount) async {
    try {
      final index =
          _groceries.indexWhere((ingredient) => ingredient.id == itemId);
      if (index != -1) {
        updateAndNotify(() {
          _groceries[index].count = newCount;
        }, applyGroceryFiltersAndSorting);
        await fridgeRepository.addOrUpdateGroceryItem(
          fridgeId,
          _groceries[index],
        );
      }

      if (connectivityProvider.isOffline) {
        pendingGroceryActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        notifyListeners();
        return true;
      }

      final success = await fridgeRepository.updateGroceryItemRemote(
          fridgeId, itemId, newCount);
      if (!success) {
        pendingGroceryActions.add({
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
      }
      return success;
    } catch (e) {
      log('Error updating grocery item: $e');
      pendingGroceryActions.add({
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

  Future<bool> deleteGroceryItem(String fridgeId, String itemId) async {
    return _deleteIngredient(
      list: _groceries,
      fridgeId: fridgeId,
      itemId: itemId,
      localDbAction: () => fridgeRepository.deleteGroceryItemLocal(itemId),
      remoteDeleteAction: () =>
          fridgeRepository.deleteGroceryItemRemote(fridgeId, itemId),
      pendingActions: pendingGroceryActions,
      isOffline: connectivityProvider.isOffline,
      applyFilters: applyGroceryFiltersAndSorting,
    );
  }

  // --- Reorder Logic ---
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
      pendingFridgeOrderActions.add({
        'action': 'reorder',
        'fridgeId': fridgeId,
        'orderedIds': _ingredients.map((i) => i.id).toList(),
      });
      // Optionally, persist order locally if needed
    } else {
      await fridgeRepository.saveFridgeOrder(
          fridgeId, _ingredients.map((i) => i.id).toList());
    }

    notifyListeners();
  }

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
      pendingGroceryOrderActions.add({
        'action': 'reorder',
        'fridgeId': fridgeId,
        'orderedIds': _groceries.map((g) => g.id).toList(),
      });
      // Optionally, persist order locally if needed
    } else {
      await fridgeRepository.saveGroceriesOrder(
          fridgeId, _groceries.map((g) => g.id).toList());
    }

    notifyListeners();
  }

  Future<void> saveFridgeOrder(String fridgeId) async {
    try {
      final orderedIds = _ingredients.map((i) => i.id).toList();
      await fridgeRepository.saveFridgeOrder(fridgeId, orderedIds);
    } catch (e) {
      log('Error saving fridge order: $e');
    }
  }

  Future<void> saveGroceriesOrder(String fridgeId) async {
    try {
      final orderedIds = _groceries.map((g) => g.id).toList();
      await fridgeRepository.saveGroceriesOrder(fridgeId, orderedIds);
    } catch (e) {
      log('Error saving groceries order: $e');
    }
  }

  // --- Move Grocery to Fridge ---
  Future<void> addGroceryToFridge(
      String fridgeId, Ingredient ingredient) async {
    // Check if the ingredient is already in the fridge
    final fridgeIndex = _ingredients.indexWhere((i) => i.id == ingredient.id);

    if (fridgeIndex != -1) {
      // Already in fridge: increment count
      final existing = _ingredients[fridgeIndex];
      final newCount = existing.count + ingredient.count;

      // Update in local DB
      await fridgeRepository.addOrUpdateFridgeItem(
        fridgeId,
        existing.copyWith(count: newCount),
      );

      // Update in memory
      updateAndNotify(() {
        _ingredients[fridgeIndex].count = newCount;
      }, applyFiltersAndSorting);
    } else {
      // Not in fridge: add as new fridge item
      await fridgeRepository.addOrUpdateFridgeItem(
        fridgeId,
        ingredient,
      );
      updateAndNotify(() {
        _ingredients.add(ingredient);
      }, applyFiltersAndSorting);
    }

    // Remove from groceries in local DB and memory
    await fridgeRepository.deleteGroceryItemLocal(ingredient.id);
    updateAndNotify(() {
      _groceries.removeWhere((g) => g.id == ingredient.id);
    }, applyGroceryFiltersAndSorting);

    // Optionally, sync with backend if online
    if (!connectivityProvider.isOffline) {
      await fridgeRepository.updateFridgeItemRemote(
        fridgeId,
        ingredient.id,
        _ingredients.firstWhere((i) => i.id == ingredient.id).count,
      );
      await fridgeRepository.deleteGroceryItemRemote(fridgeId, ingredient.id);
    } else {
      // Add to pending actions for sync
      pendingFridgeActions.add({
        'action': 'update',
        'fridgeId': fridgeId,
        'itemId': ingredient.id,
        'newCount': _ingredients.firstWhere((i) => i.id == ingredient.id).count,
      });
      pendingGroceryActions.add({
        'action': 'delete',
        'fridgeId': fridgeId,
        'itemId': ingredient.id,
      });
    }
  }

  // --- Count Change ---
  void changeCount({
    required int filteredIndex,
    required String fridgeId,
    required int delta,
  }) async {
    final ingredient = filteredIngredients[filteredIndex];
    final newCount = ingredient.count + delta;
    if (newCount < 1) return;

    final success = await updateFridgeItem(fridgeId, ingredient.id, newCount);
    if (success) {
      final mainIndex =
          _ingredients.indexWhere((ing) => ing.id == ingredient.id);
      if (mainIndex != -1) {
        updateAndNotify(() {
          _ingredients[mainIndex].count = newCount;
        }, applyFiltersAndSorting);
      }
    }
  }

  // --- Image Recognition ---
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

  // --- Image URL Update ---
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
          await fridgeRepository.updateFridgeItemImageURL(
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
          await fridgeRepository.updateGroceryItemImageURL(
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
}