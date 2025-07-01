import 'package:flutter/material.dart';
import '../utils/sort_filter_mixin.dart';
import '../models/ingredient.dart';

class IngredientListController extends ChangeNotifier
    with SortFilterMixin<Ingredient> {
  final List<Ingredient> _source;

  IngredientListController(this._source);

  @override
  /// Returns the source list of ingredients.
  List<Ingredient> get sourceList => _source;

  @override
  /// Filters ingredients by category.
  bool filterByCategory(Ingredient item, String? category) =>
      category == null || category.isEmpty
          ? true
          : item.category.toLowerCase() == category.toLowerCase();

  @override
  /// Filters ingredients by search string.
  bool filterBySearch(Ingredient item, String filter) =>
      item.name.toLowerCase().contains(filter.toLowerCase());

  @override
  /// Sorts the ingredients based on the selected sort option.
  int sortItems(Ingredient a, Ingredient b, String? sortOption) {
    if (sortOption == 'Name') {
      return a.name.compareTo(b.name);
    } else if (sortOption == 'Quantity') {
      return b.count.compareTo(a.count);
    }
    return 0;
  }

  /// Returns a list of unique categories from the source ingredients.
  List<String> getCategories() {
    final categories =
        _source.map((ingredient) => ingredient.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Clears the ingredient list and notifies listeners.
  void clear() {
    _source.clear();
    notifyListeners();
  }
}
