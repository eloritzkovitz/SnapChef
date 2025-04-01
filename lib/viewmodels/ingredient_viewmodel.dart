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

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  // Increase the count of an ingredient
  void increaseCount(int index) {
    _ingredients[index].count++;
    notifyListeners();
  }

  // Decrease the count of an ingredient
  void decreaseCount(int index) {
    if (_ingredients[index].count > 0) {
      _ingredients[index].count--;
      notifyListeners();
    }
  }

  // Add a new ingredient to the list
  void addIngredient(Ingredient ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  // Remove an ingredient by index
  void removeIngredient(int index) {
    _ingredients.removeAt(index);
    notifyListeners();
  }
}