import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/models/ingredient.dart';

class MockIngredientViewModel extends ChangeNotifier implements IngredientViewModel {
  final List<Ingredient> _ingredients = [
    Ingredient(
      id: 'i1',
      name: 'Mock Ingredient',
      category: 'Mock Category',
      imageURL: '',
      count: 1,
    ),
    Ingredient(
      id: 'i2',
      name: 'Mock Ingredient 2',
      category: 'Mock Category 2',
      imageURL: '',
      count: 1,
    ),
  ];

  bool _isLoading = false;
  bool _isLoggingOut = false;
  String? _errorMessage;

  @override
  List<Ingredient> get ingredients => _ingredients;

  Map<String, Ingredient> _ingredientMap = {};

  @override
  Map<String, Ingredient>? get ingredientMap => _ingredientMap;

  set ingredientMap(Map<String, Ingredient>? value) {
    _ingredientMap = value ?? {};
    notifyListeners();
  }

  // --- BaseViewModel required members ---
  @override
  bool get isLoading => _isLoading;

  @override
  bool get isLoggingOut => _isLoggingOut;

  @override
  String? get errorMessage => _errorMessage;

  @override
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void setLoggingOut(bool value) {
    _isLoggingOut = value;
    notifyListeners();
  }

  @override
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- IngredientViewModel methods ---
  @override
  Future<void> fetchIngredients() async {
    setLoading(true);
    await Future.delayed(const Duration(milliseconds: 100));    
    setLoading(false);
  }

  @override
  void clear() {
    _ingredients.clear();
    _isLoading = false;
    _isLoggingOut = false;
    _errorMessage = null;
    notifyListeners();
  }
}