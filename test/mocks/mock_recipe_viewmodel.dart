import 'package:flutter/foundation.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';

class MockRecipeViewModel extends ChangeNotifier implements RecipeViewModel {

  @override
  bool isLoading = false;

  @override
  String recipe = 'Mock Recipe Title\nMock Step 1\nMock Step 2';

  @override
  String imageUrl = 'https://example.com/mock_image.jpg';

  @override
  final List<Ingredient> selectedIngredients = [
    Ingredient(
      id: '1',
      name: 'Mock Ingredient 1',
      category: 'Vegetable',
      imageURL: 'assets/images/placeholder_image.png',
      count: 1,
    ),
    Ingredient(
      id: '2',
      name: 'Mock Ingredient 2',
      category: 'Protein',
      imageURL: 'assets/images/placeholder_image.png',
      count: 2,
    ),
  ];

  @override
  Recipe? generatedRecipe = Recipe(
    id: 'mock-id',
    title: 'Mock Recipe Title',
    description: 'Mock description',
    mealType: 'Dinner',
    cuisineType: 'Mock Cuisine',
    difficulty: 'Easy',
    prepTime: 10,
    cookingTime: 20,
    ingredients: [
      Ingredient(
        id: '1',
        name: 'Mock Ingredient 1',
        category: 'Vegetable',
        imageURL: 'assets/images/placeholder_image.png',
        count: 1,
      ),
      Ingredient(
        id: '2',
        name: 'Mock Ingredient 2',
        category: 'Protein',
        imageURL: 'assets/images/placeholder_image.png',
        count: 2,
      ),
    ],
    instructions: ['Mock Step 1', 'Mock Step 2'],
    imageURL: 'https://example.com/mock_image.jpg',
    rating: null,
    source: RecipeSource.ai,
  );

  @override
  Future<void> generateRecipe({
    String? mealType,
    String? cuisine,
    String? difficulty,
    int? cookingTime,
    int? prepTime,
    Map<String, dynamic>? preferences,
  }) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10));
    isLoading = false;
    recipe = 'Mock Recipe Title\nMock Step 1\nMock Step 2';
    imageUrl = 'https://example.com/mock_image.jpg';
    generatedRecipe = Recipe(
      id: 'mock-id',
      title: 'Mock Recipe Title',
      description: 'Mock description',
      mealType: mealType ?? 'Dinner',
      cuisineType: cuisine ?? 'Mock Cuisine',
      difficulty: difficulty ?? 'Easy',
      prepTime: prepTime ?? 10,
      cookingTime: cookingTime ?? 20,
      ingredients: List<Ingredient>.from(selectedIngredients),
      instructions: ['Mock Step 1', 'Mock Step 2'],
      imageURL: imageUrl,
      rating: null,
      source: RecipeSource.ai,
    );
    notifyListeners();
  }

  @override
  Future<void> regenerateRecipeImage({
    String? title,
    String? description,
    String? mealType,
    String? cuisine,
    String? difficulty,
    int? cookingTime,
    int? prepTime,
    Map<String, dynamic>? preferences,
    List<String>? ingredients,
  }) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10));
    imageUrl = 'https://example.com/mock_image_regenerated.jpg';
    if (generatedRecipe != null) {
      generatedRecipe = generatedRecipe!.copyWith(imageURL: imageUrl);
    }
    isLoading = false;
    notifyListeners();
  }
  
  @override
  void addIngredient(Ingredient ingredient) {
   
  }
  
  @override
  void clearSelectedIngredients() {   
  }
  
  @override
  bool isIngredientSelected(Ingredient ingredient) {    
    throw UnimplementedError();
  }
  
  @override
  void removeIngredient(Ingredient ingredient) {    
  }
}