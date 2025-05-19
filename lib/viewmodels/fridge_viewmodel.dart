import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../services/image_service.dart';
import '../services/fridge_service.dart';

class FridgeViewModel extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];
  List<Ingredient> filteredIngredients = [];
  List<dynamic> recognizedIngredients = [];
  final FridgeService _fridgeService = FridgeService();

  String _filter = '';
  String? _selectedCategory;
  String? _selectedSortOption;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  // Fetch ingredients from the user's fridge
  Future<void> fetchFridgeIngredients(String fridgeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _fridgeService.fetchFridgeItems(fridgeId);

      _ingredients.clear();
      if (items.isNotEmpty) {
        _ingredients.addAll(
          items.map((item) {
            return Ingredient(
              id: item['id'],
              name: item['name'],
              category: item['category'],
              imageURL:
                  item['imageURL'] ?? 'assets/images/placeholder_image.png',
              count: item['quantity'],
            );
          }).toList(),
        );
      }

      // Apply the current filter and sort options
      _applyFiltersAndSorting();
      notifyListeners();
    } catch (e) {
      log('Error fetching fridge ingredients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process an image and recognize ingredients
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

  // Get unique categories from the ingredients
  List<String> getCategories() {
    final categories =
        _ingredients.map((ingredient) => ingredient.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Filter ingredients by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFiltersAndSorting();
  }

  // Sort ingredients
  void sortIngredients(String sortOption) {
    _selectedSortOption = sortOption;
    _applyFiltersAndSorting();
  }

  // Apply filters and sorting
  void _applyFiltersAndSorting() {
    // Start with the full list of ingredients
    filteredIngredients = List.from(_ingredients);

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filteredIngredients = filteredIngredients.where((ingredient) {
        return ingredient.category.toLowerCase() ==
            _selectedCategory!.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (_filter.isNotEmpty) {
      filteredIngredients = filteredIngredients.where((ingredient) {
        return ingredient.name.toLowerCase().contains(_filter.toLowerCase());
      }).toList();
    }

    // Apply sorting
    if (_selectedSortOption == 'Name') {
      filteredIngredients.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedSortOption == 'Quantity') {
      filteredIngredients
          .sort((a, b) => b.count.compareTo(a.count)); // Descending by quantity
    }

    notifyListeners();
  }

  // Set filter for searching ingredients
  void setFilter(String filter) {
    _filter = filter;
    _applyFiltersAndSorting();
  }

  // Add ingredient to fridge (local and backend)
  Future<bool> addIngredientToFridge(String fridgeId, String id, String name,
      String category, String? imageURL, int quantity) async {
    try {
      // Check if the ingredient already exists in the fridge
      final existingIngredientIndex =
          _ingredients.indexWhere((ingredient) => ingredient.id == id);

      if (existingIngredientIndex != -1) {
        // Ingredient exists, increment its quantity
        final existingIngredient = _ingredients[existingIngredientIndex];
        final newQuantity = existingIngredient.count + quantity;

        // Update the quantity on the backend using the service
        final success = await _fridgeService.updateFridgeItem(
            fridgeId, existingIngredient.id, newQuantity);
        if (success) {
          // Update the quantity locally
          _ingredients[existingIngredientIndex].count = newQuantity;
          _applyFiltersAndSorting();
          return true;
        } else {
          log('Failed to update ingredient quantity');
          return false;
        }
      } else {
        // Ingredient does not exist, add it as a new ingredient
        final itemData = {
          'id': id,
          'name': name,
          'category': category,
          'imageURL': imageURL ?? '',
          'quantity': quantity,
        };

        final success = await _fridgeService.addFridgeItem(fridgeId, itemData);
        if (success) {
          // Add the new ingredient locally
          _ingredients.add(
            Ingredient(
              id: id,
              name: name,
              category: category,
              imageURL: imageURL ?? '',
              count: quantity,
            ),
          );
          _applyFiltersAndSorting();
          return true;
        } else {
          log('Failed to add ingredient to fridge');
          return false;
        }
      }
    } catch (e) {
      log('Error adding ingredient to fridge: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Update ingredient count in fridge (local and backend)
  Future<bool> updateItem(String fridgeId, String itemId, int newCount) async {
    try {
      final success =
          await _fridgeService.updateFridgeItem(fridgeId, itemId, newCount);
      if (success) {
        final index =
            _ingredients.indexWhere((ingredient) => ingredient.id == itemId);
        if (index != -1) {
          _ingredients[index].count = newCount;
          _applyFiltersAndSorting();
        }
        return true;
      } else {
        log('Failed to update item');
        return false;
      }
    } catch (e) {
      log('Error updating item: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Delete ingredient from fridge (local and backend)
  Future<bool> deleteItem(String fridgeId, String itemId) async {
    try {
      final success = await _fridgeService.deleteFridgeItem(fridgeId, itemId);
      if (success) {
        _ingredients.removeWhere((ingredient) => ingredient.id == itemId);
        _applyFiltersAndSorting();
        return true;
      } else {
        log('Failed to delete item');
        return false;
      }
    } catch (e) {
      log('Error deleting item: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Increase ingredient count
  void increaseCount(int filteredIndex, String fridgeId) async {
    final ingredient = filteredIngredients[filteredIndex];
    final newCount = ingredient.count + 1;

    final success = await updateItem(fridgeId, ingredient.id, newCount);
    if (success) {
      // Find and update in the main list
      final mainIndex =
          _ingredients.indexWhere((ing) => ing.id == ingredient.id);
      if (mainIndex != -1) {
        _ingredients[mainIndex].count = newCount;
      }
      _applyFiltersAndSorting();
      notifyListeners();
    }
  }

  // Decrease ingredient count
  void decreaseCount(int filteredIndex, String fridgeId) async {
    final ingredient = filteredIngredients[filteredIndex];
    if (ingredient.count > 1) {
      final newCount = ingredient.count - 1;

      final success = await updateItem(fridgeId, ingredient.id, newCount);
      if (success) {
        // Find and update in the main list
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
