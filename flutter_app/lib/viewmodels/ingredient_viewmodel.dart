import 'package:flutter/material.dart';
import '/models/ingredient.dart';
import '/services/api_service.dart';

class IngredientViewModel extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];
  bool _isLoading = false;

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;

  Future<void> fetchIngredients() async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    try {
      final response = await ApiService.fetchIngredients();
      _ingredients.clear();
      _ingredients.addAll(response.map((data) => Ingredient.fromJson(data)));
    } catch (e) {
      // Handle errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}