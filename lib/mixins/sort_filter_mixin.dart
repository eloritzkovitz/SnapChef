import 'package:flutter/material.dart';

mixin SortFilterMixin<T> on ChangeNotifier {
  // State for filtered list
  List<T> filteredItems = [];

  // Filtering/sorting state
  String filter = '';
  String? selectedCategory;
  String? selectedSortOption;  

  // The ViewModel must provide the source list
  List<T> get sourceList;

  // Expose methods for filtering and sorting
  void applyFiltersAndSorting() => _applyFiltersAndSorting();

  // The ViewModel must provide how to filter by category
  bool filterByCategory(T item, String? category);

  // The ViewModel must provide how to filter by search string
  bool filterBySearch(T item, String filter);

  // The ViewModel must provide how to sort
  int sortItems(T a, T b, String? sortOption);

  // Filtering/sorting API
  void setFilter(String value) {
    filter = value;
    _applyFiltersAndSorting();
  }

  void clearFilters() {
    selectedCategory = null;
    selectedSortOption = null;
    filter = '';
    _applyFiltersAndSorting();
  }

  void filterByCategoryValue(String? category) {
    selectedCategory = category;
    _applyFiltersAndSorting();
  }

  void sortByOption(String? sortOption) {
    selectedSortOption = sortOption;
    _applyFiltersAndSorting();
  }

  void _applyFiltersAndSorting() {
    filteredItems = List<T>.from(sourceList);

    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => filterByCategory(item, selectedCategory))
          .toList();
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
}