import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../core/base_viewmodel.dart';
import '../database/app_database.dart' as db;
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_provider.dart';
import '../repositories/cookbook_repository.dart';
import '../services/sync_service.dart';
import '../utils/sort_filter_mixin.dart';

class CookbookViewModel extends BaseViewModel with SortFilterMixin<Recipe> {
  final List<Recipe> _recipes = [];

  final db.AppDatabase database = GetIt.I<db.AppDatabase>();
  final ConnectivityProvider connectivityProvider =
      GetIt.I<ConnectivityProvider>();
  final CookbookRepository cookbookRepository = GetIt.I<CookbookRepository>();

  final SyncProvider syncProvider = GetIt.I<SyncProvider>();
  final SyncManager syncManager = GetIt.I<SyncManager>();

  String? selectedCuisine;
  String? selectedDifficulty;
  RangeValues? prepTimeRange;
  RangeValues? cookingTimeRange;
  RangeValues? ratingRange;
  String? selectedSource;

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  @override
  void dispose() {
    syncProvider.disposeSync();
    syncManager.unregister(syncProvider.syncPendingActions);
    super.dispose();
  }

  CookbookViewModel() {
    syncManager.register(syncProvider.syncPendingActions);
    syncProvider.initSync(connectivityProvider);
    syncProvider.loadPendingActions();
  }

  // --- Cookbook logic ---

  /// Fetches all recipes in the cookbook.
  Future<void> fetchCookbookRecipes(String cookbookId) async {
    setLoading(true);
    notifyListeners();

    final isOffline = connectivityProvider.isOffline;
    if (isOffline) {
      await _loadCookbookRecipesFromLocalDb(cookbookId);
      setLoading(false);
      notifyListeners();
      return;
    }

    await syncProvider.syncPendingActions();

    try {
      // 1. Fetch remote recipes
      final remoteRecipes =
          await cookbookRepository.fetchCookbookRecipesRemote(cookbookId);
      // 2. Fetch local recipes
      final localRecipes =
          await cookbookRepository.fetchCookbookRecipesLocal(cookbookId);

      // 3. Merge: keep local-only recipes (not in remote)
      final remoteIds = remoteRecipes.map((r) => r.id).toSet();
      final localOnlyRecipes =
          localRecipes.where((r) => !remoteIds.contains(r.id)).toList();

      _recipes.clear();
      _recipes.addAll(remoteRecipes);
      _recipes.addAll(localOnlyRecipes);

      await cookbookRepository.storeCookbookRecipesLocal(cookbookId, _recipes);

      applyFiltersAndSorting();
    } catch (e) {
      log('Error fetching cookbook recipes: $e');
      await _loadCookbookRecipesFromLocalDb(cookbookId);
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Loads recipes from local DB.
  Future<void> _loadCookbookRecipesFromLocalDb(String userId) async {
    final localRecipes =
        await cookbookRepository.fetchCookbookRecipesLocal(userId);
    _recipes.clear();
    _recipes.addAll(localRecipes);
    applyFiltersAndSorting();
  }

  /// Adds a recipe to the cookbook.
  Future<bool> addRecipeToCookbook({
    required String cookbookId,
    required String title,
    required String description,
    required String mealType,
    required String cuisineType,
    required String difficulty,
    required int prepTime,
    required int cookingTime,
    required List<Ingredient> ingredients,
    required List<String> instructions,
    String? imageURL,
    double? rating,
    required RecipeSource source,
    String? raw,
  }) async {
    try {
      final recipe = Recipe(
        id: DateTime.now().toString(),
        title: title,
        description: description,
        mealType: mealType,
        cuisineType: cuisineType,
        difficulty: difficulty,
        prepTime: prepTime,
        cookingTime: cookingTime,
        ingredients: ingredients,
        instructions: instructions,
        imageURL: imageURL ?? '',
        rating: rating,
        isFavorite: false,
        source: source,
      );

      final isOffline = connectivityProvider.isOffline;
      if (isOffline) {
        // Save locally and queue for sync
        await cookbookRepository.addRecipeToCookbookLocal(cookbookId, recipe);
        syncProvider.addPendingAction('cookbook', {
          'action': 'add',
          'cookbookId': cookbookId,
          'recipe': recipe.toJson(),
        });
        await syncProvider.savePendingActions();
        _recipes.add(recipe);
        await cookbookRepository.storeCookbookRecipesLocal(
            cookbookId, _recipes);
        applyFiltersAndSorting();
        notifyListeners();
        return true;
      }

      final success = await cookbookRepository.addRecipeToCookbookRemote(
        cookbookId,
        recipe,
        raw: raw,
      );
      if (success) {
        _recipes.add(recipe);
        await cookbookRepository.storeCookbookRecipesLocal(
            cookbookId, _recipes);
        applyFiltersAndSorting();
        notifyListeners();
      }
      return success;
    } catch (e) {
      log('Error adding recipe to cookbook: $e');
      return false;
    }
  }

  /// Updates a recipe in the cookbook.
  Future<bool> updateRecipe({
    required String cookbookId,
    required String recipeId,
    required String title,
    required String description,
    required String mealType,
    required String cuisineType,
    required String difficulty,
    required int prepTime,
    required int cookingTime,
    required List<Ingredient> ingredients,
    required List<String> instructions,
    String? imageURL,
    double? rating,
  }) async {
    try {
      final updatedRecipe = Recipe(
        id: recipeId,
        title: title,
        description: description,
        mealType: mealType,
        cuisineType: cuisineType,
        difficulty: difficulty,
        prepTime: prepTime,
        cookingTime: cookingTime,
        ingredients: ingredients,
        instructions: instructions,
        imageURL: imageURL ?? '',
        rating: rating,
        isFavorite: false,
        source: RecipeSource.user,
      );

      final isOffline = connectivityProvider.isOffline;
      if (isOffline) {
        await cookbookRepository.updateRecipeLocal(cookbookId, updatedRecipe);
        syncProvider.addPendingAction('cookbook', {
          'action': 'update',
          'cookbookId': cookbookId,
          'recipeId': recipeId,
          'updatedRecipe': updatedRecipe.toJson(),
        });
        await syncProvider.savePendingActions();
        final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
        if (index != -1) {
          _recipes[index] = updatedRecipe;
          await cookbookRepository.storeCookbookRecipesLocal(
              cookbookId, _recipes);
          applyFiltersAndSorting();
          notifyListeners();
        }
        return true;
      }

      final success = await cookbookRepository.updateRecipeRemote(
        cookbookId,
        recipeId,
        updatedRecipe,
      );
      if (success) {
        final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
        if (index != -1) {
          _recipes[index] = updatedRecipe;
          await cookbookRepository.storeCookbookRecipesLocal(
              cookbookId, _recipes);
          applyFiltersAndSorting();
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      log('Error updating recipe: $e');
      return false;
    }
  }

  /// Regenerates the image for a recipe in the cookbook.
  Future<bool> regenerateRecipeImage({
    required String cookbookId,
    required String recipeId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final newImageUrl = await cookbookRepository.regenerateRecipeImage(
          cookbookId, recipeId, payload);
      final index = _recipes.indexWhere((r) => r.id == recipeId);
      if (index == -1) return false;
      if (index != -1) {
        _recipes[index] = _recipes[index].copyWith(imageURL: newImageUrl);
        applyFiltersAndSorting();
        notifyListeners();
      }
      return true;
    } catch (e) {
      log('Error regenerating recipe image: $e');
      return false;
    }
  }

  /// Toggles the favorite status of a recipe.
  Future<bool> toggleRecipeFavoriteStatus(
      String cookbookId, String recipeId) async {
    try {
      final isOffline = connectivityProvider.isOffline;
      final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
      if (index == -1) return false;

      if (isOffline) {
        await cookbookRepository.toggleRecipeFavoriteStatusLocal(
            recipeId, !_recipes[index].isFavorite);
        syncProvider.addPendingAction('cookbook', {
          'action': 'toggleFavorite',
          'cookbookId': cookbookId,
          'recipeId': recipeId,
        });
        await syncProvider.savePendingActions();
        _recipes[index] =
            _recipes[index].copyWith(isFavorite: !_recipes[index].isFavorite);
        await cookbookRepository.storeCookbookRecipesLocal(
            cookbookId, _recipes);
        applyFiltersAndSorting();
        notifyListeners();
        return true;
      }

      final success = await cookbookRepository.toggleRecipeFavoriteStatusRemote(
          cookbookId, recipeId);
      if (success) {
        _recipes[index] =
            _recipes[index].copyWith(isFavorite: !_recipes[index].isFavorite);
        await cookbookRepository.storeCookbookRecipesLocal(
            cookbookId, _recipes);
        applyFiltersAndSorting();
        notifyListeners();
      }
      return success;
    } catch (e) {
      log('Error toggling favorite status: $e');
      return false;
    }
  }

  /// Reorders a recipe in the cookbook.
  Future<void> reorderRecipe(
      int oldIndex, int newIndex, String cookbookId) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex < 0 ||
        oldIndex >= _recipes.length ||
        newIndex < 0 ||
        newIndex >= _recipes.length) {
      return;
    }
    final recipe = filteredItems.removeAt(oldIndex);
    filteredItems.insert(newIndex, recipe);

    // Also reorder in the main _recipes list to keep everything in sync
    final oldId = recipe.id;
    final oldMainIndex = _recipes.indexWhere((r) => r.id == oldId);
    if (oldMainIndex != -1) {
      final mainRecipe = _recipes.removeAt(oldMainIndex);

      // Find the new index in the main list based on the next recipe in filteredItems
      int newMainIndex;
      if (newIndex + 1 < filteredItems.length) {
        // Insert before the next recipe in filteredItems
        final nextId = filteredItems[newIndex + 1].id;
        newMainIndex = _recipes.indexWhere((r) => r.id == nextId);
        if (newMainIndex == -1) {
          newMainIndex = _recipes.length;
        }
      } else {
        // Insert at the end
        newMainIndex = _recipes.length;
      }
      _recipes.insert(newMainIndex, mainRecipe);
    }

    final isOffline = connectivityProvider.isOffline;
    final orderedIds = _recipes.map((r) => r.id).toList();

    if (isOffline) {
      await cookbookRepository.saveRecipeOrderLocal(orderedIds);
      syncProvider.addPendingAction('cookbook', {
        'action': 'reorder',
        'cookbookId': cookbookId,
        'orderedIds': orderedIds,
      });
      await syncProvider.savePendingActions();
      await cookbookRepository.storeCookbookRecipesLocal(cookbookId, _recipes);
      notifyListeners();
      return;
    }

    // Save the new order to backend
    await saveRecipeOrder(cookbookId);
    await cookbookRepository.storeCookbookRecipesLocal(cookbookId, _recipes);
    notifyListeners();
  }

  /// Saves the new order to backend.
  Future<void> saveRecipeOrder(String cookbookId) async {
    try {
      // Send the list of recipe IDs in the new order
      final orderedIds = _recipes.map((r) => r.id).toList();
      await cookbookRepository.saveRecipeOrderRemote(cookbookId, orderedIds);
    } catch (e) {
      log('Error saving recipe order: $e');
    }
  }

  /// Shares a recipe with a friend,
  Future<void> shareRecipeWithFriend({
    required String cookbookId,
    required String recipeId,
    required String friendId,
  }) async {
    await cookbookRepository.shareRecipeWithFriend(
      cookbookId: cookbookId,
      recipeId: recipeId,
      friendId: friendId,
    );
  }

  /// Deletes a recipe from the cookbook.
  Future<bool> deleteRecipe(String cookbookId, String recipeId) async {
    try {
      final isOffline = connectivityProvider.isOffline;
      if (isOffline) {
        await cookbookRepository.deleteRecipeLocal(recipeId);
        _recipes.removeWhere((recipe) => recipe.id == recipeId);
        syncProvider.addPendingAction('cookbook', {
          'action': 'delete',
          'cookbookId': cookbookId,
          'recipeId': recipeId,
        });
        await syncProvider.savePendingActions();
        applyFiltersAndSorting();
        notifyListeners();
        return true;
      }

      final success =
          await cookbookRepository.deleteRecipeRemote(cookbookId, recipeId);
      if (success) {
        await cookbookRepository.deleteRecipeLocal(recipeId);
        _recipes.removeWhere((recipe) => recipe.id == recipeId);
        applyFiltersAndSorting();
        notifyListeners();
      }
      return success;
    } catch (e) {
      log('Error deleting recipe: $e');
      return false;
    }
  }

  /// Searches recipes by name.
  List<Recipe> searchRecipes(String query) {
    return _recipes
        .where((recipe) =>
            recipe.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // --- SortFilterMixin implementation ---
  @override
  List<Recipe> get sourceList => _recipes;

  @override
  bool filterByCategory(Recipe item, String? category) =>
      category == null || category.isEmpty
          ? true
          : item.mealType.toLowerCase() == category.toLowerCase();

  @override
  bool filterBySearch(Recipe item, String filter) =>
      item.title.toLowerCase().contains(filter.toLowerCase());

  @override
  int sortItems(Recipe a, Recipe b, String? sortOption) {
    if (sortOption == 'Name') {
      return a.title.compareTo(b.title);
    } else if (sortOption == 'Rating') {
      return (b.rating ?? 0).compareTo(a.rating ?? 0);
    } else if (sortOption == 'PrepTime') {
      return a.prepTime.compareTo(b.prepTime);
    } else if (sortOption == 'CookingTime') {
      return a.cookingTime.compareTo(b.cookingTime);
    }
    return 0;
  }

  // --- Category/cuisine/difficulty getters for UI ---
  List<String> getCategories() {
    final categories =
        _recipes.map((recipe) => recipe.mealType).toSet().toList();
    categories.sort();
    return categories;
  }

  List<String> getCuisines() {
    final cuisines =
        _recipes.map((recipe) => recipe.cuisineType).toSet().toList();
    cuisines.sort();
    return cuisines;
  }

  List<String> getDifficulties() {
    final difficulties =
        _recipes.map((recipe) => recipe.difficulty).toSet().toList();
    difficulties.sort();
    return difficulties;
  }

  int get minPrepTime => _recipes.isEmpty
      ? 0
      : _recipes.map((r) => r.prepTime).reduce((a, b) => a < b ? a : b);
  int get maxPrepTime => _recipes.isEmpty
      ? 0
      : _recipes.map((r) => r.prepTime).reduce((a, b) => a > b ? a : b);
  int get minCookingTime => _recipes.isEmpty
      ? 0
      : _recipes.map((r) => r.cookingTime).reduce((a, b) => a < b ? a : b);
  int get maxCookingTime => _recipes.isEmpty
      ? 0
      : _recipes.map((r) => r.cookingTime).reduce((a, b) => a > b ? a : b);
  double get minRating => _recipes.isEmpty
      ? 0
      : _recipes.map((r) => r.rating ?? 0).reduce((a, b) => a < b ? a : b);
  double get maxRating => _recipes.isEmpty
      ? 0
      : _recipes.map((r) => r.rating ?? 0).reduce((a, b) => a > b ? a : b);

  @override
  void applyFiltersAndSorting() {
    // Start with all recipes
    filteredItems = List<Recipe>.from(_recipes);

    // Category (meal type)
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filteredItems = filteredItems
          .where((r) =>
              r.mealType.toLowerCase() == selectedCategory!.toLowerCase())
          .toList();
    }

    // Cuisine
    if (selectedCuisine != null && selectedCuisine!.isNotEmpty) {
      filteredItems = filteredItems
          .where((r) =>
              r.cuisineType.toLowerCase() == selectedCuisine!.toLowerCase())
          .toList();
    }

    // Difficulty
    if (selectedDifficulty != null && selectedDifficulty!.isNotEmpty) {
      filteredItems = filteredItems
          .where((r) =>
              r.difficulty.toLowerCase() == selectedDifficulty!.toLowerCase())
          .toList();
    }

    // Prep Time
    if (prepTimeRange != null) {
      filteredItems = filteredItems
          .where((r) =>
              r.prepTime >= prepTimeRange!.start.toInt() &&
              r.prepTime <= prepTimeRange!.end.toInt())
          .toList();
    }

    // Cooking Time
    if (cookingTimeRange != null) {
      filteredItems = filteredItems
          .where((r) =>
              r.cookingTime >= cookingTimeRange!.start.toInt() &&
              r.cookingTime <= cookingTimeRange!.end.toInt())
          .toList();
    }

    // Rating
    if (ratingRange != null) {
      filteredItems = filteredItems.where((r) {
        final rating = r.rating ?? 0;
        return rating >= ratingRange!.start && rating <= ratingRange!.end;
      }).toList();
    }

    // Source
    if (selectedSource != null && selectedSource!.isNotEmpty) {
      filteredItems = filteredItems.where((r) {
        if (selectedSource == 'ai') {
          return r.source == RecipeSource.ai;
        } else if (selectedSource == 'user' || selectedSource == 'manual') {
          return r.source == RecipeSource.user;
        }
        return true;
      }).toList();
    }

    if (filter.isNotEmpty) {
      filteredItems =
          filteredItems.where((item) => filterBySearch(item, filter)).toList();
    }

    if (selectedSortOption != null && selectedSortOption!.isNotEmpty) {
      filteredItems.sort((a, b) => sortItems(a, b, selectedSortOption));
    }

    notifyListeners();
  }

  @override
  void clearFilters() {
    selectedCategory = null;
    selectedSortOption = null;
    filter = '';
    selectedCuisine = null;
    selectedDifficulty = null;
    prepTimeRange = null;
    cookingTimeRange = null;
    ratingRange = null;
    selectedSource = null;
    applyFiltersAndSorting();
  }

  @override
  void clear() {
    _recipes.clear();
    selectedCuisine = null;
    selectedDifficulty = null;
    prepTimeRange = null;
    cookingTimeRange = null;
    ratingRange = null;
    selectedSource = null;
    filter = '';
    selectedCategory = null;
    selectedSortOption = null;
    filteredItems = [];
    setLoading(false);
    notifyListeners();
  }
}
