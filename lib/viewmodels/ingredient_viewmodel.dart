import 'package:flutter/material.dart';
import '../services/ingredient_service.dart';

class IngredientViewModel extends ChangeNotifier {
  List<dynamic>? _ingredients;
  Map<String, dynamic>? _ingredientMap;
  bool _loading = false;

  List<dynamic>? get ingredients => _ingredients;
  Map<String, dynamic>? get ingredientMap => _ingredientMap;
  bool get loading => _loading;

  final IngredientService _service;

  IngredientViewModel(this._service);

  /// Fetches all ingredients from the service and updates the state.
  Future<void> fetchIngredients() async {
    _loading = true;
    notifyListeners();
    _ingredients = await _service.getAllIngredients();
    // Build the map for fast lookup (case-insensitive, trimmed)
    _ingredientMap = {
      for (var ing in _ingredients!)
        ing['name'].toString().trim().toLowerCase(): ing
    };
    _loading = false;
    notifyListeners();
  }
}
