import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class FridgeViewModel extends ChangeNotifier {
  final List<Ingredient> _ingredients = [
    Ingredient(
      id: '1',
      name: 'Tomato',
      category: 'Vegetable',
      imageURL: 'https://example.com/tomato.jpg',
      count: 2,
    ),
    Ingredient(
      id: '2',
      name: 'Carrot',
      category: 'Vegetable',
      imageURL: 'https://example.com/carrot.jpg',
      count: 5,
    ),
    Ingredient(
      id: '3',
      name: 'Onion',
      category: 'Vegetable',
      imageURL: 'https://example.com/onion.jpg',
      count: 3,
    ),
  ];

  String _filter = '';

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  List<Ingredient> get filteredIngredients {
    if (_filter.isEmpty) {
      return _ingredients;
    }
    return _ingredients
        .where((ingredient) => ingredient.name.toLowerCase().contains(_filter.toLowerCase()))
        .toList();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void increaseCount(int index) {
    _ingredients[index].count++;
    notifyListeners();
  }

  void decreaseCount(int index) {
    if (_ingredients[index].count > 0) {
      _ingredients[index].count--;
      notifyListeners();
    }
  }
}