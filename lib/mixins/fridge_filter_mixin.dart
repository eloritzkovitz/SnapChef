import 'package:flutter/material.dart';
import '../models/ingredient.dart';

mixin FridgeFilterMixin on ChangeNotifier {
  List<Ingredient> filteredIngredients = [];
  List<Ingredient> filteredGroceries = [];

  String filter = '';
  String? selectedCategory;
  String? selectedSortOption;

  String groceryFilter = '';
  String? selectedGroceryCategory;
  String? selectedGrocerySortOption;

  List<Ingredient> get ingredientsSource;
  List<Ingredient> get groceriesSource;
  
  // Expose methods for filtering and sorting
  List<String> getCategories() => getCategoriesFrom(ingredientsSource);
  List<String> getGroceryCategories() => getCategoriesFrom(groceriesSource);
  void applyFiltersAndSorting() => _applyFiltersAndSorting();
  void applyGroceryFiltersAndSorting() => _applyGroceryFiltersAndSorting();  

  // Generic filtering and sorting logic
  List<Ingredient> applyGenericFiltersAndSorting({
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

  // Get unique categories from a list
  List<String> getCategoriesFrom(List<Ingredient> source) {
    final categories =
        source.map((ingredient) => ingredient.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Filtering and sorting for a list
  void applyFiltersAndSortingToList({
    required List<Ingredient> source,
    required String filter,
    required String? category,
    required String? sortOption,
    required void Function(List<Ingredient>) setFiltered,
  }) {
    setFiltered(applyGenericFiltersAndSorting(
      source: source,
      filter: filter,
      category: category,
      sortOption: sortOption,
    ));
    notifyListeners();
  }

  // Ingredient specific filtering and sorting
  void setFilter(String filter) {
    filter = filter;
    _applyFiltersAndSorting();
  }

  // Clear filters
  void clearFilters() {
    selectedCategory = null;
    selectedSortOption = null;
    filter = '';
    _applyFiltersAndSorting();
  }

  // Filter ingredients by category
  void filterByCategory(String? category) {
    selectedCategory = category;
    _applyFiltersAndSorting();
  }

  // Sort ingredients by selected option
  void sortIngredients(String? sortOption) {
    selectedSortOption = sortOption;
    _applyFiltersAndSorting();
  }

  // Apply filters and sorting for ingredients
  void _applyFiltersAndSorting() {
    filteredIngredients = applyGenericFiltersAndSorting(
      source: ingredientsSource,
      filter: filter,
      category: selectedCategory,
      sortOption: selectedSortOption,
    );
    notifyListeners();
  }

  // Grocery specific filtering and sorting
  void setGroceryFilter(String filter) {
    groceryFilter = filter;
    _applyGroceryFiltersAndSorting();
  }

  // Clear grocery filters
  void clearGroceryFilters() {
    selectedGroceryCategory = null;
    selectedGrocerySortOption = null;
    groceryFilter = '';
    _applyGroceryFiltersAndSorting();
  }

  // Filter groceries by category
  void filterGroceriesByCategory(String? category) {
    selectedGroceryCategory = category;
    _applyGroceryFiltersAndSorting();
  }

  // Sort groceries by selected option
  void sortGroceries(String? sortOption) {
    selectedGrocerySortOption = sortOption;
    _applyGroceryFiltersAndSorting();
  }

  // Apply filters and sorting for groceries
  void _applyGroceryFiltersAndSorting() {
    filteredGroceries = applyGenericFiltersAndSorting(
      source: groceriesSource,
      filter: groceryFilter,
      category: selectedGroceryCategory,
      sortOption: selectedGrocerySortOption,
    );
    notifyListeners();
  }  
}
