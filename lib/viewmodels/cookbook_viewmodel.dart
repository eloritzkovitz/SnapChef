import 'dart:developer';
import 'package:flutter/material.dart';
import '../database/app_database.dart' as db;
import '../database/daos/recipe_dao.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/shared_recipe.dart';
import '../providers/connectivity_provider.dart';
import '../services/cookbook_service.dart';

class CookbookViewModel extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  List<Recipe> filteredRecipes = [];
  List<SharedRecipe>? sharedWithMeRecipes = [];
  List<SharedRecipe>? sharedByMeRecipes = [];
  final CookbookService _cookbookService = CookbookService();
  final db.AppDatabase database;
  final ConnectivityProvider connectivityProvider;

  CookbookViewModel({
    required this.database,
    required this.connectivityProvider,
  });

  RecipeDao get recipeDao => database.recipeDao;

  String _filter = '';
  String? _selectedCategory;
  String? _selectedCuisine;
  String? _selectedDifficulty;
  RangeValues? _prepTimeRange;
  RangeValues? _cookingTimeRange;
  RangeValues? _ratingRange;
  String? _selectedSortOption;
  String? _selectedSource;

  String? get selectedCategory => _selectedCategory;
  String? get selectedCuisine => _selectedCuisine;
  String? get selectedDifficulty => _selectedDifficulty;
  RangeValues? get prepTimeRange => _prepTimeRange;
  RangeValues? get cookingTimeRange => _cookingTimeRange;
  RangeValues? get ratingRange => _ratingRange;
  String? get selectedSortOption => _selectedSortOption;
  String? get selectedSource => _selectedSource;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  // Fetch all recipes in the cookbook
  Future<void> fetchCookbookRecipes(String cookbookId) async {  
    _isLoading = true;
    notifyListeners();

    final isOffline = connectivityProvider.isOffline;
    if (isOffline) {
      await _loadCookbookRecipesFromLocalDb(cookbookId);
      _isLoading = false;
      notifyListeners();     
      return;
    }

    try {
      final items = await _cookbookService
          .fetchCookbookRecipes(cookbookId)
          .timeout(const Duration(seconds: 3), onTimeout: () {        
        throw Exception('Network timeout');
      });

      _recipes.clear();
      if (items.isNotEmpty) {
        _recipes.addAll(
          items.map((item) {
            return Recipe(
              id: item['_id'] ?? '',
              title: item['title'],
              description: item['description'],
              mealType: item['mealType'],
              cuisineType: item['cuisineType'],
              difficulty: item['difficulty'],
              prepTime: item['prepTime'],
              cookingTime: item['cookingTime'],
              ingredients: (item['ingredients'] as List<dynamic>)
                  .map((ingredient) => Ingredient.fromJson(ingredient))
                  .toList(),
              instructions: List<String>.from(item['instructions']),
              imageURL:
                  item['imageURL'] ?? 'assets/images/placeholder_image.png',
              rating: item['rating'] != null
                  ? (item['rating'] as num).toDouble()
                  : null,
              isFavorite: item['isFavorite'] ?? false,
              source: item['source'] == 'ai'
                  ? RecipeSource.ai
                  : item['source'] == 'shared'
                      ? RecipeSource.shared
                      : RecipeSource.user,
            );
          }).toList(),
        );
        await _storeCookbookRecipesLocally(cookbookId, _recipes);
      }

      _applyFiltersAndSorting();
    } catch (e) {
      log('Error fetching cookbook recipes: $e');
      await _loadCookbookRecipesFromLocalDb(cookbookId);
    } finally {
      _isLoading = false;
      notifyListeners();      
    }
  }

  // Load recipes from local DB using RecipeDao
  Future<void> _loadCookbookRecipesFromLocalDb(String userId) async {
    final localRecipes = await recipeDao.getCookbookRecipes(userId);
    _recipes.clear();
    _recipes.addAll(
        localRecipes.map((dbRecipe) => Recipe.fromDb(dbRecipe.toJson())));
    _applyFiltersAndSorting();
  }

// Store recipes locally using RecipeDao
  Future<void> _storeCookbookRecipesLocally(
      String userId, List<Recipe> recipes) async {
    for (final recipe in recipes) {
      await recipeDao.insertOrUpdateRecipe(recipe.toDbRecipe(userId: userId));
    }
  }

  // Fetch recipes shared with the user
  Future<void> fetchSharedRecipes(String cookbookId) async {
    final result = await _cookbookService.fetchSharedRecipes(cookbookId);
    sharedWithMeRecipes = result['sharedWithMe'] ?? [];
    sharedByMeRecipes = result['sharedByMe'] ?? [];
    notifyListeners();
  }

  // Add a recipe to the cookbook
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
      final recipeData = {
        'title': title,
        'description': description,
        'mealType': mealType,
        'cuisineType': cuisineType,
        'difficulty': difficulty,
        'prepTime': prepTime,
        'cookingTime': cookingTime,
        'ingredients':
            ingredients.map((ingredient) => ingredient.toJson()).toList(),
        'instructions': instructions,
        'imageURL': imageURL,
        'rating': rating,
        'isFavorite': false,
        'source': source == RecipeSource.ai
            ? 'ai'
            : source == RecipeSource.shared
                ? 'shared'
                : 'user',
        'raw': raw,
      };

      final success =
          await _cookbookService.addRecipeToCookbook(recipeData, cookbookId);
      if (success) {
        _recipes.add(
          Recipe(
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
          ),
        );
        _applyFiltersAndSorting();
        notifyListeners();
      }
      return success;
    } catch (e) {
      log('Error adding recipe to cookbook: $e');
      return false;
    }
  }

  // Update a recipe in the cookbook
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
      final updatedData = {
        'title': title,
        'description': description,
        'mealType': mealType,
        'cuisineType': cuisineType,
        'difficulty': difficulty,
        'prepTime': prepTime,
        'cookingTime': cookingTime,
        'ingredients':
            ingredients.map((ingredient) => ingredient.toJson()).toList(),
        'instructions': instructions,
        'imageURL': imageURL,
        'rating': rating,
      };

      final success = await _cookbookService.updateCookbookRecipe(
          cookbookId, recipeId, updatedData);
      if (success) {
        final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
        if (index != -1) {
          _recipes[index] = _recipes[index].copyWith(
            title: title,
            description: description,
            mealType: mealType,
            cuisineType: cuisineType,
            difficulty: difficulty,
            prepTime: prepTime,
            cookingTime: cookingTime,
            ingredients: ingredients,
            instructions: instructions,
            imageURL: imageURL ?? _recipes[index].imageURL,
            rating: rating,
          );
          _applyFiltersAndSorting();
        }
      }
      return success;
    } catch (e) {
      log('Error updating recipe: $e');
      return false;
    }
  }

  // Regenerate the image for a recipe in the cookbook
  Future<bool> regenerateRecipeImage({
    required String cookbookId,
    required String recipeId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final newImageUrl = await _cookbookService.regenerateRecipeImage(
          cookbookId, recipeId, payload);
      final index = _recipes.indexWhere((r) => r.id == recipeId);
      if (index != -1) {
        _recipes[index] = _recipes[index].copyWith(imageURL: newImageUrl);
        _applyFiltersAndSorting();
        notifyListeners();
      }
      return true;
    } catch (e) {
      log('Error regenerating recipe image: $e');
      return false;
    }
  }

  // Toggle the favorite status of a recipe
  Future<bool> toggleRecipeFavoriteStatus(
      String cookbookId, String recipeId) async {
    try {
      final success = await _cookbookService.toggleRecipeFavoriteStatus(
          cookbookId, recipeId);
      if (success) {
        final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
        if (index != -1) {
          _recipes[index] =
              _recipes[index].copyWith(isFavorite: !_recipes[index].isFavorite);
          _applyFiltersAndSorting();
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      log('Error toggling favorite status: $e');
      return false;
    }
  }

  // Reorder a recipe in the cookbook
  Future<void> reorderRecipe(
      int oldIndex, int newIndex, String cookbookId) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final recipe = filteredRecipes.removeAt(oldIndex);
    filteredRecipes.insert(newIndex, recipe);

    // Also reorder in the main _recipes list to keep everything in sync
    final oldId = recipe.id;
    final oldMainIndex = _recipes.indexWhere((r) => r.id == oldId);
    if (oldMainIndex != -1) {
      final mainRecipe = _recipes.removeAt(oldMainIndex);

      // Find the new index in the main list based on the next recipe in filteredRecipes
      int newMainIndex;
      if (newIndex + 1 < filteredRecipes.length) {
        // Insert before the next recipe in filteredRecipes
        final nextId = filteredRecipes[newIndex + 1].id;
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

    // Save the new order to backend
    await saveRecipeOrder(cookbookId);

    notifyListeners();
  }

  // Save the new order to backend
  Future<void> saveRecipeOrder(String cookbookId) async {
    try {
      // Send the list of recipe IDs in the new order
      final orderedIds = _recipes.map((r) => r.id).toList();
      await _cookbookService.saveRecipeOrder(cookbookId, orderedIds);
    } catch (e) {
      log('Error saving recipe order: $e');
    }
  }

  // Share a recipe with a friend
  Future<void> shareRecipeWithFriend({
    required String cookbookId,
    required String recipeId,
    required String friendId,
  }) async {
    await _cookbookService.shareRecipeWithFriend(
      cookbookId: cookbookId,
      recipeId: recipeId,
      friendId: friendId,
    );
  }

  // Remove a shared recipe
  Future<void> removeSharedRecipe(String cookbookId, String sharedRecipeId,
      {required bool isSharedByMe}) async {
    try {
      // Call the service to delete the shared recipe
      await _cookbookService.deleteSharedRecipe(cookbookId, sharedRecipeId);

      // Remove from the correct list
      if (isSharedByMe) {
        sharedByMeRecipes?.removeWhere((r) => r.id == sharedRecipeId);
      } else {
        sharedWithMeRecipes?.removeWhere((r) => r.id == sharedRecipeId);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Delete a recipe from the cookbook
  Future<bool> deleteRecipe(String cookbookId, String recipeId) async {
    try {
      final success =
          await _cookbookService.deleteCookbookRecipe(cookbookId, recipeId);
      if (success) {
        _recipes.removeWhere((recipe) => recipe.id == recipeId);
        _applyFiltersAndSorting();
      }
      return success;
    } catch (e) {
      log('Error deleting recipe: $e');
      return false;
    }
  }

  // Get a list of all categories
  List<String> getCategories() {
    final categories =
        _recipes.map((recipe) => recipe.mealType).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get a list of all cuisines
  List<String> getCuisines() {
    final cuisines =
        _recipes.map((recipe) => recipe.cuisineType).toSet().toList();
    cuisines.sort();
    return cuisines;
  }

  // Get a list of all difficulties
  List<String> getDifficulties() {
    final difficulties =
        _recipes.map((recipe) => recipe.difficulty).toSet().toList();
    difficulties.sort();
    return difficulties;
  }

  // Get min/max for prep/cooking time and rating
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

  // Filter recipes by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFiltersAndSorting();
  }

  // Filter recipes by cuisine
  void filterByCuisine(String? cuisine) {
    _selectedCuisine = cuisine;
    _applyFiltersAndSorting();
  }

  // Filter recipes by difficulty
  void filterByDifficulty(String? difficulty) {
    _selectedDifficulty = difficulty;
    _applyFiltersAndSorting();
  }

  // Filter recipes by prep time range
  void filterByPrepTime(RangeValues? range) {
    _prepTimeRange = range;
    _applyFiltersAndSorting();
  }

  // Filter recipes by cooking time range
  void filterByCookingTime(RangeValues? range) {
    _cookingTimeRange = range;
    _applyFiltersAndSorting();
  }

  // Filter recipes by rating range
  void filterByRating(RangeValues? range) {
    _ratingRange = range;
    _applyFiltersAndSorting();
  }

  // Filter recipes by source
  void filterBySource(String? source) {
    _selectedSource = source;
    _applyFiltersAndSorting();
  }

  // Sort recipes by selected option
  void sortRecipes(String sortOption) {
    _selectedSortOption = sortOption;
    _applyFiltersAndSorting();
  }

  // Set a filter for recipe titles
  void setFilter(String filter) {
    _filter = filter;
    _applyFiltersAndSorting();
  }

  // Apply filters and sorting to the recipes
  void _applyFiltersAndSorting() {
    filteredRecipes = List.from(_recipes);

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.mealType.toLowerCase() ==
            _selectedCategory!.toLowerCase();
      }).toList();
    }

    if (_selectedCuisine != null && _selectedCuisine!.isNotEmpty) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.cuisineType.toLowerCase() ==
            _selectedCuisine!.toLowerCase();
      }).toList();
    }

    if (_selectedDifficulty != null && _selectedDifficulty!.isNotEmpty) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.difficulty.toLowerCase() ==
            _selectedDifficulty!.toLowerCase();
      }).toList();
    }

    if (_prepTimeRange != null) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.prepTime >= _prepTimeRange!.start.toInt() &&
            recipe.prepTime <= _prepTimeRange!.end.toInt();
      }).toList();
    }

    if (_cookingTimeRange != null) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.cookingTime >= _cookingTimeRange!.start.toInt() &&
            recipe.cookingTime <= _cookingTimeRange!.end.toInt();
      }).toList();
    }

    if (_ratingRange != null) {
      filteredRecipes = filteredRecipes.where((recipe) {
        final rating = recipe.rating ?? 0;
        return rating >= _ratingRange!.start && rating <= _ratingRange!.end;
      }).toList();
    }

    if (_selectedSource != null && _selectedSource!.isNotEmpty) {
      filteredRecipes = filteredRecipes.where((recipe) {
        if (_selectedSource == 'ai') {
          return recipe.source == RecipeSource.ai;
        } else if (_selectedSource == 'user' || _selectedSource == 'manual') {
          return recipe.source == RecipeSource.user;
        }
        return true;
      }).toList();
    }

    if (_filter.isNotEmpty) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.title.toLowerCase().contains(_filter.toLowerCase());
      }).toList();
    }

    if (_selectedSortOption == 'Name') {
      filteredRecipes.sort((a, b) => a.title.compareTo(b.title));
    } else if (_selectedSortOption == 'Rating') {
      filteredRecipes.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (_selectedSortOption == 'PrepTime') {
      filteredRecipes.sort((a, b) => a.prepTime.compareTo(b.prepTime));
    } else if (_selectedSortOption == 'CookingTime') {
      filteredRecipes.sort((a, b) => a.cookingTime.compareTo(b.cookingTime));
    }
    notifyListeners();
  }

  // Search recipes by name
  List<Recipe> searchRecipes(String query) {
    return _recipes
        .where((recipe) =>
            recipe.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Reset all filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedCuisine = null;
    _selectedDifficulty = null;
    _prepTimeRange = null;
    _cookingTimeRange = null;
    _ratingRange = null;
    _filter = '';
    _selectedSortOption = null;
    _selectedSource = null;
    _applyFiltersAndSorting();
  }
}
