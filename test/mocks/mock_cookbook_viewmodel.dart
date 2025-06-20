import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/models/ingredient.dart';

class MockCookbookViewModel extends ChangeNotifier
    implements CookbookViewModel {
  String? _selectedCategory;
  String? _selectedCuisine;
  String? _selectedDifficulty;
  String? _selectedSortOption;
  String? _selectedSource;
  RangeValues? _prepTimeRange;
  RangeValues? _cookingTimeRange;
  RangeValues? _ratingRange;
  @override
  String filter = '';

  final List<Recipe> _mockRecipes = [
    Recipe(
      id: '1',
      title: 'Test Recipe',
      description: 'A test recipe',
      mealType: 'Dinner',
      cuisineType: 'Italian',
      difficulty: 'Easy',
      prepTime: 10,
      cookingTime: 20,
      ingredients: [
        Ingredient(
          id: 'ing1',
          name: 'Tomato',
          category: 'Vegetable',
          imageURL: 'assets/images/placeholder_image.png',
          count: 2,
        ),
        Ingredient(
          id: 'ing2',
          name: 'Olive Oil',
          category: 'Oil',
          imageURL: 'assets/images/placeholder_image.png',
          count: 1,
        ),
      ],
      instructions: ['Chop tomatoes', 'Cook for 10 minutes'],
      imageURL: null,
      rating: 4.5,
      isFavorite: false,
      source: RecipeSource.user,
    ),
  ];

  @override
  String? get selectedCategory => _selectedCategory;
  @override
  set selectedCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  @override
  String? get selectedCuisine => _selectedCuisine;
  @override
  set selectedCuisine(String? value) {
    _selectedCuisine = value;
    notifyListeners();
  }

  @override
  String? get selectedDifficulty => _selectedDifficulty;
  @override
  set selectedDifficulty(String? value) {
    _selectedDifficulty = value;
    notifyListeners();
  }

  @override
  String? get selectedSortOption => _selectedSortOption;
  @override
  set selectedSortOption(String? value) {
    _selectedSortOption = value;
    notifyListeners();
  }

  @override
  String? get selectedSource => _selectedSource;
  @override
  set selectedSource(String? value) {
    _selectedSource = value;
    notifyListeners();
  }

  @override
  RangeValues? get prepTimeRange => _prepTimeRange ?? const RangeValues(0, 60);
  @override
  set prepTimeRange(RangeValues? value) {
    _prepTimeRange = value;
    notifyListeners();
  }

  @override
  RangeValues? get cookingTimeRange =>
      _cookingTimeRange ?? const RangeValues(0, 60);
  @override
  set cookingTimeRange(RangeValues? value) {
    _cookingTimeRange = value;
    notifyListeners();
  }

  @override
  RangeValues? get ratingRange => _ratingRange ?? const RangeValues(0, 5);
  @override
  set ratingRange(RangeValues? value) {
    _ratingRange = value;
    notifyListeners();
  }

  // Filtering/sorting methods
  @override
  List<String> getCategories() => [
        'Vegetable',
        'Fruit',
        'Meat',
        'Dairy',
        'Grain',
        'Oil',
        'Spice',
        'Seafood',
        'Beverage',
        'Other',
      ];

  @override
  List<String> getCuisines() => [
        'Italian',
        'Mexican',
        'Indian',
        'American',
        'Other',
      ];

  @override
  List<String> getDifficulties() => [
        'Easy',
        'Medium',
        'Hard',
      ];

  @override
  int get minPrepTime => 0;
  @override
  int get maxPrepTime => 60;
  @override
  int get minCookingTime => 0;
  @override
  int get maxCookingTime => 120;
  @override
  double get minRating => 0;
  @override
  double get maxRating => 5;

  @override
  List<Recipe> get filteredItems => _mockRecipes;

  @override
  List<Recipe> get recipes => _mockRecipes;

  @override
  bool get isLoading => false;

  @override
  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return _mockRecipes;
    return _mockRecipes
        .where((recipe) =>
            recipe.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void applyFiltersAndSorting() {}

  @override
  void clearFilters() {
    _selectedCategory = null;
    _selectedSortOption = null;
    filter = '';
    _selectedCuisine = null;
    _selectedDifficulty = null;
    _prepTimeRange = null;
    _cookingTimeRange = null;
    _ratingRange = null;
    _selectedSource = null;
    notifyListeners();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> fetchCookbookRecipes(String cookbookId) async {    
  }
}
