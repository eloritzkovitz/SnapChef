import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../services/cookbook_service.dart';

class CookbookViewModel extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  List<Recipe> filteredRecipes = [];
  final CookbookService _cookbookService = CookbookService();

  String _filter = '';
  String? _selectedCategory;
  String? _selectedCuisine;
  String? _selectedSortOption;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  // Fetch all recipes in the cookbook
  Future<void> fetchCookbookRecipes(String cookbookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cookbookService.fetchCookbookRecipes(cookbookId);

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
              imageURL: item['imageURL'] ?? 'assets/images/placeholder_image.png',
              rating: item['rating'] != null ? (item['rating'] as num).toDouble() : null,
            );
          }).toList(),
        );
      }

      _applyFiltersAndSorting();
    } catch (e) {
      log('Error fetching cookbook recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
        'instructions': instructions,
        'imageURL': imageURL,
        'rating': rating,
      };

      final success = await _cookbookService.addRecipeToCookbook(recipeData, cookbookId);
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
        'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
        'instructions': instructions,
        'imageURL': imageURL,
        'rating': rating,
      };

      final success = await _cookbookService.updateCookbookRecipe(cookbookId, recipeId, updatedData);
      if (success) {
        final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
        if (index != -1) {
          _recipes[index] = Recipe(
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

  // Delete a recipe from the cookbook
  Future<bool> deleteRecipe(String cookbookId, String recipeId) async {
    try {
      final success = await _cookbookService.deleteCookbookRecipe(cookbookId, recipeId);
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
    final categories = _recipes.map((recipe) => recipe.mealType).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get a list of all cuisines
  List<String> getCuisines() {
    final cuisines = _recipes.map((recipe) => recipe.cuisineType).toSet().toList();
    cuisines.sort();
    return cuisines;
  }

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
        return recipe.mealType.toLowerCase() == _selectedCategory!.toLowerCase();
      }).toList();
    }

    if (_selectedCuisine != null && _selectedCuisine!.isNotEmpty) {
      filteredRecipes = filteredRecipes.where((recipe) {
        return recipe.cuisineType.toLowerCase() == _selectedCuisine!.toLowerCase();
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
    }
    notifyListeners();
  }

  // Search recipes by name
  List<Recipe> searchRecipes(String query) {
    return _recipes
        .where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}