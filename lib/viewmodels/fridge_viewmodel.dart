import 'dart:developer';
import 'dart:io';
import 'package:get_it/get_it.dart';
import '../core/base_viewmodel.dart';
import '../models/ingredient.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_provider.dart';
import '../services/image_service.dart';
import '../viewmodels/ingredient_viewmodel.dart';
import '../services/sync_service.dart';
import '../repositories/fridge_repository.dart';
import '../services/fridge_service.dart';
import 'ingredient_list_controller.dart';

class FridgeViewModel extends BaseViewModel {
  // --- Fields & Constructor ---
  final List<Ingredient> _ingredients = [];
  final List<Ingredient> _groceries = [];
  List<dynamic> recognizedIngredients = [];

  late final IngredientListController fridgeController;
  late final IngredientListController groceriesController;

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);
  List<Ingredient> get groceries => List.unmodifiable(_groceries);

  final ConnectivityProvider connectivityProvider =
      GetIt.I<ConnectivityProvider>();
  final SyncProvider syncProvider = GetIt.I<SyncProvider>();
  final SyncManager syncManager = GetIt.I<SyncManager>();
  final FridgeRepository fridgeRepository = GetIt.I<FridgeRepository>();

  FridgeService get fridgeService => fridgeRepository.fridgeService;

  FridgeViewModel() {
    fridgeController = IngredientListController(_ingredients);
    groceriesController = IngredientListController(_groceries);
    fridgeController.addListener(notifyListeners);
    groceriesController.addListener(notifyListeners);
    syncManager.register(syncProvider.syncPendingActions);
    syncProvider.initSync(connectivityProvider);
    syncProvider.loadPendingActions();
  }

  Future<void> fetchData({
    required String fridgeId,
    required IngredientViewModel ingredientViewModel,
  }) async {
    await Future.wait([
      fetchFridgeIngredients(fridgeId, ingredientViewModel),
      fetchGroceries(fridgeId, ingredientViewModel),
    ]);
  }

  @override
  void dispose() {
    syncProvider.disposeSync();
    syncManager.unregister(syncProvider.syncPendingActions);
    super.dispose();
  }

  // --- Data Fetching & Sync ---
  Future<void> fetchFridgeIngredients(
      String fridgeId, IngredientViewModel ingredientViewModel) async {
    setLoading(true);
    notifyListeners();

    final isOffline = connectivityProvider.isOffline;
    if (isOffline) {
      await _loadFridgeIngredientsFromLocalDb(fridgeId);
      setLoading(false);
      notifyListeners();
      return;
    }

    await syncProvider.syncPendingActions();

    try {
      final remoteItems =
          await fridgeRepository.fetchFridgeItemsRemote(fridgeId);
      final localItems = await fridgeRepository.fetchFridgeItemsLocal(fridgeId);

      // Merge: keep local-only items (not in remote)
      final remoteIds = remoteItems.map((i) => i.id).toSet();
      final localOnlyItems =
          localItems.where((i) => !remoteIds.contains(i.id)).toList();

      _ingredients.clear();
      _ingredients.addAll(remoteItems);
      _ingredients.addAll(localOnlyItems);
      fridgeController.applyFiltersAndSorting();

      // Store merged list locally
      await fridgeRepository.storeFridgeItemsLocal(fridgeId, _ingredients);

      // Update imageURLs using IngredientViewModel
      await updateFridgeIngredientImageURLs(ingredientViewModel, fridgeId);
    } catch (e) {
      log('Error fetching fridge ingredients: $e');
      await _loadFridgeIngredientsFromLocalDb(fridgeId);
    } finally {
      setLoading(false);
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

    await syncProvider.syncPendingActions();

    try {
      final remoteItems = await fridgeRepository.fetchGroceriesRemote(fridgeId);
      final localItems = await fridgeRepository.fetchGroceriesLocal(fridgeId);

      // Merge: keep local-only items (not in remote)
      final remoteIds = remoteItems.map((i) => i.id).toSet();
      final localOnlyItems =
          localItems.where((i) => !remoteIds.contains(i.id)).toList();

      _groceries.clear();
      _groceries.addAll(remoteItems);
      _groceries.addAll(localOnlyItems);
      groceriesController.applyFiltersAndSorting();

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

  /// Loads fridge ingredients from local database.
  Future<void> _loadFridgeIngredientsFromLocalDb(String fridgeId) async {
    final localIngredients =
        await fridgeRepository.fetchFridgeItemsLocal(fridgeId);
    _ingredients.clear();
    _ingredients.addAll(localIngredients);
    fridgeController.applyFiltersAndSorting();
  }

  /// Loads groceries from local database.
  Future<void> _loadGroceriesFromLocalDb(String fridgeId) async {
    final localGroceries = await fridgeRepository.fetchGroceriesLocal(fridgeId);
    _groceries.clear();
    _groceries.addAll(localGroceries);
    groceriesController.applyFiltersAndSorting();
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
    await syncProvider.savePendingActions();
    final idx = list.indexWhere((i) => i.id == ingredient.id);

    if (idx != -1) {
      final newQuantity = list[idx].count + ingredient.count;
      if (isOffline) {
        syncProvider.addPendingAction('fridge', {
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': ingredient.id,
          'newCount': newQuantity,
        });
        await syncProvider.savePendingActions();
        list[idx].count = newQuantity;
        applyFilters();
        return true;
      }
      try {
        final success = await remoteUpdateAction(newQuantity);
        if (success) {
          list[idx].count = newQuantity;
          applyFilters();
          return true;
        } else {
          return false;
        }
      } catch (e) {
        // Catch remote error and return false
        return false;
      }
    } else {
      if (isOffline) {
        syncProvider.addPendingAction('fridge', {
          'action': 'add',
          'fridgeId': fridgeId,
          'ingredient': ingredient.toJson(),
        });
        await syncProvider.savePendingActions();
        list.add(ingredient);
        applyFilters();
        return true;
      }
      try {
        final success = await remoteAddAction();
        if (success) {
          list.add(ingredient);
          applyFilters();
          return true;
        } else {
          return false;
        }
      } catch (e) {
        // Catch remote error and return false
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
      await syncProvider.savePendingActions();
      list.removeWhere((ingredient) => ingredient.id == itemId);
      applyFilters();

      if (isOffline) {
        syncProvider.addPendingAction('fridge', {
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
        await syncProvider.savePendingActions();
        notifyListeners();
        return true;
      }

      final success = await remoteDeleteAction();
      if (!success) {
        syncProvider.addPendingAction('fridge', {
          'action': 'delete',
          'fridgeId': fridgeId,
          'itemId': itemId,
        });
        await syncProvider.savePendingActions();
      }
      return success;
    } catch (e) {
      syncProvider.addPendingAction('fridge', {
        'action': 'delete',
        'fridgeId': fridgeId,
        'itemId': itemId,
      });
      await syncProvider.savePendingActions();
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
      pendingActions: syncProvider.pendingActionQueues['fridge'] ??= [],
      isOffline: connectivityProvider.isOffline,
      applyFilters: fridgeController.applyFiltersAndSorting,
    );
  }

  Future<bool> updateFridgeItem(
      String fridgeId, String itemId, int newCount) async {
    try {
      final index =
          _ingredients.indexWhere((ingredient) => ingredient.id == itemId);
      if (index != -1) {
        _ingredients[index].count = newCount;
        fridgeController.applyFiltersAndSorting();
        await fridgeRepository.addOrUpdateFridgeItem(
          fridgeId,
          _ingredients[index],
        );
      }

      if (connectivityProvider.isOffline) {
        syncProvider.addPendingAction('fridge', {
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        await syncProvider.savePendingActions();
        notifyListeners();
        return true;
      }

      final success = await fridgeRepository.updateFridgeItemRemote(
          fridgeId, itemId, newCount);
      if (!success) {
        syncProvider.addPendingAction('fridge', {
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        await syncProvider.savePendingActions();
      }
      return success;
    } catch (e) {
      log('Error updating item: $e');
      syncProvider.addPendingAction('fridge', {
        'action': 'update',
        'fridgeId': fridgeId,
        'itemId': itemId,
        'newCount': newCount,
      });
      await syncProvider.savePendingActions();
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
      pendingActions: syncProvider.pendingActionQueues['fridge'] ??= [],
      isOffline: connectivityProvider.isOffline,
      applyFilters: fridgeController.applyFiltersAndSorting,
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
      pendingActions: syncProvider.pendingActionQueues['grocery'] ??= [],
      isOffline: connectivityProvider.isOffline,
      applyFilters: groceriesController.applyFiltersAndSorting,
    );
  }

  Future<bool> updateGroceryItem(
      String fridgeId, String itemId, int newCount) async {
    try {
      final index =
          _groceries.indexWhere((ingredient) => ingredient.id == itemId);
      if (index != -1) {
        _groceries[index].count = newCount;
        groceriesController.applyFiltersAndSorting();
        await fridgeRepository.addOrUpdateGroceryItem(
          fridgeId,
          _groceries[index],
        );
      }

      if (connectivityProvider.isOffline) {
        syncProvider.addPendingAction('grocery', {
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        await syncProvider.savePendingActions();
        notifyListeners();
        return true;
      }

      final success = await fridgeRepository.updateGroceryItemRemote(
          fridgeId, itemId, newCount);
      if (!success) {
        syncProvider.addPendingAction('grocery', {
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': itemId,
          'newCount': newCount,
        });
        await syncProvider.savePendingActions();
      }
      return success;
    } catch (e) {
      log('Error updating grocery item: $e');
      syncProvider.addPendingAction('grocery', {
        'action': 'update',
        'fridgeId': fridgeId,
        'itemId': itemId,
        'newCount': newCount,
      });
      await syncProvider.savePendingActions();
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
      pendingActions: syncProvider.pendingActionQueues['grocery'] ??= [],
      isOffline: connectivityProvider.isOffline,
      applyFilters: groceriesController.applyFiltersAndSorting,
    );
  }

  // --- Reorder Logic ---
  Future<void> reorderIngredient(
      int oldIndex, int newIndex, String fridgeId) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex < 0 ||
        oldIndex >= _ingredients.length ||
        newIndex < 0 ||
        newIndex >= _ingredients.length) {
      return;
    }
    final ingredient = fridgeController.filteredItems.removeAt(oldIndex);
    fridgeController.filteredItems.insert(newIndex, ingredient);

    // Also reorder in the main _ingredients list to keep everything in sync
    final oldId = ingredient.id;
    final oldMainIndex = _ingredients.indexWhere((i) => i.id == oldId);
    if (oldMainIndex != -1) {
      final mainIngredient = _ingredients.removeAt(oldMainIndex);

      int newMainIndex;
      if (newIndex + 1 < fridgeController.filteredItems.length) {
        final nextId = fridgeController.filteredItems[newIndex + 1].id;
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
      syncProvider.addPendingAction('fridge', {
        'action': 'reorder',
        'fridgeId': fridgeId,
        'orderedIds': _ingredients.map((i) => i.id).toList(),
      });
      await syncProvider.savePendingActions();
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
    if (oldIndex < 0 ||
        oldIndex >= _groceries.length ||
        newIndex < 0 ||
        newIndex >= _groceries.length) {
      return;
    }
    final item = groceriesController.filteredItems.removeAt(oldIndex);
    groceriesController.filteredItems.insert(newIndex, item);

    // Also reorder in the main groceries list
    final oldId = item.id;
    final oldMainIndex = _groceries.indexWhere((g) => g.id == oldId);
    if (oldMainIndex != -1) {
      final mainItem = _groceries.removeAt(oldMainIndex);
      int newMainIndex;
      if (newIndex + 1 < groceriesController.filteredItems.length) {
        final nextId = groceriesController.filteredItems[newIndex + 1].id;
        newMainIndex = _groceries.indexWhere((g) => g.id == nextId);
        if (newMainIndex == -1) newMainIndex = _groceries.length;
      } else {
        newMainIndex = _groceries.length;
      }
      _groceries.insert(newMainIndex, mainItem);
    }

    // Save the new order
    if (connectivityProvider.isOffline) {
      syncProvider.addPendingAction('grocery', {
        'action': 'reorder',
        'fridgeId': fridgeId,
        'orderedIds': _groceries.map((g) => g.id).toList(),
      });
      await syncProvider.savePendingActions();
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
      _ingredients[fridgeIndex].count = newCount;
      fridgeController.applyFiltersAndSorting();

      // Update remotely if online
      if (!connectivityProvider.isOffline) {
        await fridgeRepository.updateFridgeItemRemote(
          fridgeId,
          existing.id,
          newCount,
        );
      }
    } else {
      // Not in fridge: add as new fridge item
      await fridgeRepository.addOrUpdateFridgeItem(
        fridgeId,
        ingredient,
      );
      _ingredients.add(ingredient);
      fridgeController.applyFiltersAndSorting();

      // Add remotely if online
      if (!connectivityProvider.isOffline) {
        await fridgeRepository.addFridgeItemRemote(
          fridgeId,
          ingredient,
        );
      }
    }

    // Remove from groceries in local DB and memory
    await fridgeRepository.deleteGroceryItemLocal(ingredient.id);
    _groceries.removeWhere((g) => g.id == ingredient.id);
    groceriesController.applyFiltersAndSorting();

    // Remove remotely if online
    if (!connectivityProvider.isOffline) {
      await fridgeRepository.deleteGroceryItemRemote(fridgeId, ingredient.id);
    }

    // Offline sync logic
    if (connectivityProvider.isOffline) {
      final fridgeIndex = _ingredients.indexWhere((i) => i.id == ingredient.id);
      if (fridgeIndex != -1) {
        syncProvider.addPendingAction('fridge', {
          'action': 'update',
          'fridgeId': fridgeId,
          'itemId': ingredient.id,
          'newCount': _ingredients[fridgeIndex].count,
        });
      } else {
        syncProvider.addPendingAction('fridge', {
          'action': 'add',
          'fridgeId': fridgeId,
          'ingredient': ingredient.toJson(),
        });
      }
      syncProvider.addPendingAction('grocery', {
        'action': 'delete',
        'fridgeId': fridgeId,
        'itemId': ingredient.id,
      });
      await syncProvider.savePendingActions();
    }
  }

  // --- Count Change ---
  void changeCount({
    required int filteredIndex,
    required String fridgeId,
    required int delta,
  }) async {
    final ingredient = fridgeController.filteredItems[filteredIndex];
    final newCount = ingredient.count + delta;
    if (newCount < 1) return;

    final success = await updateFridgeItem(fridgeId, ingredient.id, newCount);
    if (success) {
      final mainIndex =
          _ingredients.indexWhere((ing) => ing.id == ingredient.id);
      if (mainIndex != -1) {
        _ingredients[mainIndex].count = newCount;
        fridgeController.applyFiltersAndSorting();
      }
    }
  }

  // --- Image Recognition ---
  Future<void> recognizeIngredients(File image, String endpoint) async {
    setLoading(true);
    recognizedIngredients = [];
    notifyListeners();

    try {
      final uploadPhoto = ImageService();
      recognizedIngredients = await uploadPhoto.processImage(image, endpoint);
    } catch (e) {
      log('Error recognizing ingredients: $e');
      recognizedIngredients = [];
    } finally {
      setLoading(false);
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

  @override
  void clear() {
    _ingredients.clear();
    _groceries.clear();
    recognizedIngredients = [];
    fridgeController.clear();
    groceriesController.clear();
    setLoading(false);
    notifyListeners();
  }
}
