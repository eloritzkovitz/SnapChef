import 'package:flutter/material.dart';
import 'package:snapchef/database/app_database.dart' hide Recipe, Ingredient;
import 'package:snapchef/repositories/cookbook_repository.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/utils/sort_filter_mixin.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/providers/sync_provider.dart';

class MockCookbookViewModel extends ChangeNotifier
    with SortFilterMixin<Recipe>
    implements CookbookViewModel {
  // --- BaseViewModel fields ---
  @override
  bool isLoading = false;
  @override
  bool isLoggingOut = false;
  @override
  String? errorMessage;

  @override
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void setLoggingOut(bool value) {
    isLoggingOut = value;
    notifyListeners();
  }

  @override
  void setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  @override
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void clear() {
    filteredItems = [];
    filter = '';
    selectedCategory = null;
    selectedSortOption = null;
    selectedCuisine = null;
    selectedDifficulty = null;
    prepTimeRange = null;
    cookingTimeRange = null;
    ratingRange = null;
    selectedSource = null;
    setLoading(false);
    notifyListeners();
  }

  // --- SortFilterMixin fields ---
  MockCookbookViewModel() {
    filteredItems = List<Recipe>.from(_mockRecipes);
  }

  // --- CookbookViewModel fields ---
  @override
  String? selectedCuisine;
  @override
  String? selectedDifficulty;
  @override
  RangeValues? prepTimeRange;
  @override
  RangeValues? cookingTimeRange;
  @override
  RangeValues? ratingRange;
  @override
  String? selectedSource;

  // --- Dummy data ---
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
  List<Recipe> get recipes => _mockRecipes;

  @override
  List<Recipe> get sourceList => _mockRecipes;

  // --- Filtering/sorting logic for the mock ---
  @override
  bool filterByCategory(Recipe item, String? category) => true;
  @override
  bool filterBySearch(Recipe item, String filter) => true;
  @override
  int sortItems(Recipe a, Recipe b, String? sortOption) => 0;

  // --- Filtering/sorting API ---
  @override
  void applyFiltersAndSorting() {
    filteredItems = List<Recipe>.from(_mockRecipes);
    notifyListeners();
  }

  @override
  void clearFilters() {
    selectedCategory = null;
    selectedSortOption = null;
    filter = '';
    selectedCuisine = null;
    selectedDifficulty = null;
    prepTimeRange = null;
    cookingTimeRange = null;
    ratingRange = null;
    selectedSource = null;
    applyFiltersAndSorting();
  }

  Recipe? get recipe => _mockRecipes.first;

  Recipe? get selectedRecipe => _mockRecipes.first;

  bool addToCookbookCallback = false;  

  // --- CookbookViewModel methods ---
  @override
  Future<void> fetchCookbookRecipes(String cookbookId) async {}

  @override
  Future<bool> addRecipeToCookbook({
    required String cookbookId,
    required String title,
    required String description,
    required String mealType,
    required String cuisineType,
    required String difficulty,
    required int prepTime,
    required int cookingTime,
    required List<Ingredient> ingredients,
    required List<String> instructions,
    String? imageURL,
    double? rating,
    required RecipeSource source,
    String? raw,
  }) async {
    addToCookbookCallback = true;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> updateRecipe({
    required String cookbookId,
    required String recipeId,
    required String title,
    required String description,
    required String mealType,
    required String cuisineType,
    required String difficulty,
    required int prepTime,
    required int cookingTime,
    required List<Ingredient> ingredients,
    required List<String> instructions,
    String? imageURL,
    double? rating,
  }) async {
    return true;
  }

  @override
  Future<bool> toggleRecipeFavoriteStatus(
      String cookbookId, String recipeId) async {
    final index = _mockRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      final old = _mockRecipes[index];
      _mockRecipes[index] = old.copyWith(isFavorite: !old.isFavorite);
      notifyListeners();
    }
    return true;
  }

  @override
  Future<bool> deleteRecipe(String cookbookId, String recipeId) async {
    return true;
  }

  @override
  Future<bool> regenerateRecipeImage({
    required String cookbookId,
    required String recipeId,
    required Map<String, dynamic> payload,
  }) async {
    return true;
  }

  @override
  Future<void> shareRecipeWithFriend({
    required String cookbookId,
    required String recipeId,
    required String friendId,
  }) async {}

  @override
  Future<void> reorderRecipe(
      int oldIndex, int newIndex, String cookbookId) async {}

  @override
  Future<void> saveRecipeOrder(String cookbookId) async {}

  List<Recipe> Function(String)? searchRecipesOverride;

  @override
  List<Recipe> searchRecipes(String query) {
    if (searchRecipesOverride != null) {
      return searchRecipesOverride!(query);
    }
    if (query.isEmpty) return _mockRecipes;
    return _mockRecipes
        .where((recipe) =>
            recipe.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // --- Category/cuisine/difficulty getters for UI ---
  @override
  List<String> getCategories() {
    final categories =
        _mockRecipes.map((recipe) => recipe.mealType).toSet().toList();
    categories.sort();
    return categories;
  }

  @override
  List<String> getCuisines() {
    final cuisines =
        _mockRecipes.map((recipe) => recipe.cuisineType).toSet().toList();
    cuisines.sort();
    return cuisines;
  }

  @override
  List<String> getDifficulties() {
    final difficulties =
        _mockRecipes.map((recipe) => recipe.difficulty).toSet().toList();
    difficulties.sort();
    return difficulties;
  }

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

  // --- Required dependencies (dummy implementations) ---
  @override
  ConnectivityProvider get connectivityProvider => ConnectivityProvider();

  @override
  CookbookRepository get cookbookRepository => CookbookRepository();

  @override
  AppDatabase get database => AppDatabase();

  @override
  SyncManager get syncManager => SyncManager(connectivityProvider);

  @override
  SyncProvider get syncProvider => SyncProvider();
}
