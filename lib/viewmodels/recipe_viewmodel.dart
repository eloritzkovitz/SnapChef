import '../core/base_viewmodel.dart';
import '../services/recipe_service.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

class RecipeViewModel extends BaseViewModel {
  final RecipeService _recipeService;
  RecipeViewModel({RecipeService? recipeService})
      : _recipeService = recipeService ?? RecipeService();

  String recipe = '';
  String imageUrl = '';
  final List<Ingredient> selectedIngredients = [];
  Recipe? generatedRecipe;

  /// Adds an ingredient to the selected list.
  void addIngredient(Ingredient ingredient) {
    if (!selectedIngredients.contains(ingredient)) {
      selectedIngredients.add(ingredient);
      notifyListeners();
    }
  }

  /// Removes an ingredient from the selected list
  void removeIngredient(Ingredient ingredient) {
    selectedIngredients.remove(ingredient);
    notifyListeners();
  }

  /// Checks if an ingredient is selected.
  bool isIngredientSelected(Ingredient ingredient) {
    return selectedIngredients.contains(ingredient);
  }

  /// Clears all selected ingredients.
  void clearSelectedIngredients() {
    selectedIngredients.clear();
    notifyListeners();
  }

  /// Generates a recipe based on the selected ingredients and additional options.  
  Future<void> generateRecipe({
    String? mealType,
    String? cuisine,
    String? difficulty,
    int? cookingTime,
    int? prepTime,
    Map<String, dynamic>? preferences,
  }) async {
    setLoading(true);
    recipe = '';
    imageUrl = '';
    generatedRecipe = null;
    notifyListeners();

    try {
      // Convert the list of selected ingredients to a format suitable for the backend
      final ingredientsString =
          selectedIngredients.map((e) => e.name).join(',');

      // Prepare the request payload
      final requestPayload = {
        'ingredients': ingredientsString,
        'mealType': mealType,
        'cuisine': cuisine,
        'difficulty': difficulty,
        'cookingTime': cookingTime,
        'prepTime': prepTime,
        'preferences': preferences,
      };

      // Call the backend service to generate the recipe
      final result = await _recipeService.generateRecipe(requestPayload);

      // Update the recipe and image URL with the response from the backend
      recipe = result['recipe'] ?? 'No recipe generated.';
      imageUrl = result['imageUrl'] ?? '';

      // Parse and store the generated recipe as a Recipe object
      String title = 'Generated Recipe';
      final lines = recipe.split('\n').map((l) => l.trim()).toList();
      for (final line in lines) {
        if (line.isNotEmpty && !line.startsWith('*')) {
          title = line;
          break;
        }
      }

      generatedRecipe = Recipe(
        id: '',
        title: title,
        description: '',
        mealType: mealType ?? '',
        cuisineType: cuisine ?? '',
        difficulty: difficulty ?? '',
        prepTime: prepTime ?? 0,
        cookingTime: cookingTime ?? 0,
        ingredients: List<Ingredient>.from(selectedIngredients),
        instructions: recipe.split('\n'),
        imageURL: imageUrl,
        rating: null,
        source: RecipeSource.ai,
      );
    } catch (error) {
      recipe = 'Failed to generate recipe: $error';
      generatedRecipe = null;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Regenerates the recipe image based on the current recipe or selected ingredients.
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
    setLoading(true);
    notifyListeners();

    try {
      // Use provided values, or fall back to generatedRecipe, or selectedIngredients
      final Recipe? recipeObj = generatedRecipe;
      final ingredientsList = ingredients ??
          (recipeObj != null
              ? recipeObj.ingredients.map((e) => e.name).toList()
              : selectedIngredients.map((e) => e.name).toList());

      final requestPayload = {
        'title': title ?? recipeObj?.title ?? '',
        'description': description ?? recipeObj?.description ?? '',
        'ingredients': ingredientsList,
        'mealType': mealType ?? recipeObj?.mealType ?? '',
        'cuisine': cuisine ?? recipeObj?.cuisineType ?? '',
        'difficulty': difficulty ?? recipeObj?.difficulty ?? '',
        'cookingTime': cookingTime ?? recipeObj?.cookingTime,
        'prepTime': prepTime ?? recipeObj?.prepTime,
        'preferences': preferences,
      };

      final newImageUrl =
          await _recipeService.regenerateRecipeImage(requestPayload);
      imageUrl = newImageUrl;

      // Update the generatedRecipe's imageURL as well
      if (generatedRecipe != null) {
        generatedRecipe = generatedRecipe!.copyWith(imageURL: newImageUrl);
      }
    } catch (error) {
      // Optionally handle error
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  @override
  void clear() {
    recipe = '';
    imageUrl = '';
    selectedIngredients.clear();
    generatedRecipe = null;
    setError(null);
    setLoading(false);
    notifyListeners();
  }
}
