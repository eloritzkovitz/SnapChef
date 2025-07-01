import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/ingredient_list_controller.dart';
import 'package:snapchef/models/ingredient.dart';

class MockIngredientListController extends ChangeNotifier implements IngredientListController {
  List<Ingredient> _filteredItems = [];
  final List<Ingredient> _sourceList = [];
  @override
  String filter = '';
  @override
  String? selectedCategory;
  @override
  String? selectedSortOption;

  @override
  List<Ingredient> get filteredItems => _filteredItems;

  @override
  set filteredItems(List<Ingredient> items) {
    _filteredItems = items;
    notifyListeners();
  }

  @override
  List<Ingredient> get sourceList => _sourceList;

  @override
  List<String> getCategories() => _filteredItems.map((e) => e.category).toSet().toList();

  @override
  void clearFilters() {
    selectedCategory = null;
    selectedSortOption = null;
    filter = '';
    notifyListeners();
  }

  @override
  void filterByCategoryValue(String? cat) {
    selectedCategory = cat;
    notifyListeners();
  }

  @override
  void sortByOption(String? sort) {
    selectedSortOption = sort;
    notifyListeners();
  }

  @override
  void applyFiltersAndSorting() {
    notifyListeners();
  }

  @override
  void setFilter(String value) {
    filter = value;
    notifyListeners();
  }

  // --- Abstract methods from SortFilterMixin ---

  @override
  void clear() {
    _filteredItems.clear();
    _sourceList.clear();
    notifyListeners();
  }

  @override
  bool filterByCategory(Ingredient item, String? category) {
    return category == null || item.category == category;
  }

  @override
  bool filterBySearch(Ingredient item, String filter) {
    return filter.isEmpty || item.name.toLowerCase().contains(filter.toLowerCase());
  }

  @override
  int sortItems(Ingredient a, Ingredient b, String? sortOption) {
    return a.name.compareTo(b.name);
  }
}