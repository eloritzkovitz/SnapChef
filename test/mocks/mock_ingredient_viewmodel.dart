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
  ];

  @override
  List<Ingredient> get ingredients => _ingredients;

  @override
  Map<String, Ingredient>? get ingredientMap =>
      {for (var ing in _ingredients) ing.name.trim().toLowerCase(): ing};

  @override
  bool get loading => false;

  @override
  Future<void> fetchIngredients() async {}

  // If you need to mock additional methods, add them here.
}