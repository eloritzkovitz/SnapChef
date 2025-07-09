import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/services/recipe_service.dart';

@GenerateNiceMocks([MockSpec<RecipeService>()])
import 'recipe_viewmodel_test.mocks.dart';

Ingredient get testIngredient => Ingredient(
      id: 'ing1',
      name: 'Salt',
      category: 'Spices',
      imageURL: 'assets/images/placeholder_image.png',
      count: 1,
    );

void main() async {
  late RecipeViewModel vm;
  late MockRecipeService mockRecipeService;
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  setUp(() {
    mockRecipeService = MockRecipeService();
    vm = RecipeViewModel(recipeService: mockRecipeService);    
    vm.recipe = '';
    vm.imageUrl = '';
    vm.generatedRecipe = null;
    vm.selectedIngredients.clear();
  });

  test('addIngredient adds ingredient if not already selected', () {
    final ingredient = testIngredient;
    expect(vm.selectedIngredients, isEmpty);
    vm.addIngredient(ingredient);
    expect(vm.selectedIngredients.contains(ingredient), isTrue);
  });

  test('addIngredient does not add duplicate ingredient', () {
    final ingredient = testIngredient;
    vm.addIngredient(ingredient);
    vm.addIngredient(ingredient);
    expect(vm.selectedIngredients.length, 1);
    expect(vm.selectedIngredients.first, ingredient);
  });

  test('removeIngredient removes ingredient from selected list', () {
    final ingredient = testIngredient;
    vm.addIngredient(ingredient);
    vm.removeIngredient(ingredient);
    expect(vm.selectedIngredients, isEmpty);
  });

  test('isIngredientSelected returns true if ingredient is selected', () {
    final ingredient = testIngredient;
    vm.addIngredient(ingredient);
    expect(vm.isIngredientSelected(ingredient), isTrue);
  });

  test('isIngredientSelected returns false if ingredient is not selected', () {
    final ingredient = testIngredient;
    expect(vm.isIngredientSelected(ingredient), isFalse);
  });

  test('clearSelectedIngredients clears all selected ingredients', () {
    final ingredient = testIngredient;
    vm.addIngredient(ingredient);
    vm.clearSelectedIngredients();
    expect(vm.selectedIngredients, isEmpty);
  });

  test('generateRecipe sets recipe, imageUrl, and generatedRecipe on success', () async {
    final ingredient = testIngredient;
    vm.addIngredient(ingredient);

    when(mockRecipeService.generateRecipe(any)).thenAnswer((_) async => {
      'recipe': 'Test Recipe\nStep 1\nStep 2',
      'imageUrl': 'http://image.url/test.png',
    });

    await vm.generateRecipe(
      mealType: 'Dinner',
      cuisine: 'Italian',
      difficulty: 'Easy',
      cookingTime: 30,
      prepTime: 10,
      preferences: {'vegan': false},
    );

    expect(vm.recipe, contains('Test Recipe'));
    expect(vm.imageUrl, contains('http'));
    expect(vm.generatedRecipe, isNotNull);
    expect(vm.generatedRecipe!.title, 'Test Recipe');
    expect(vm.generatedRecipe!.mealType, 'Dinner');
    expect(vm.generatedRecipe!.cuisineType, 'Italian');
    expect(vm.generatedRecipe!.difficulty, 'Easy');
    expect(vm.generatedRecipe!.prepTime, 10);
    expect(vm.generatedRecipe!.cookingTime, 30);
    expect(vm.generatedRecipe!.ingredients.contains(ingredient), isTrue);
    expect(vm.generatedRecipe!.instructions, contains('Step 1'));
  });

  test('generateRecipe sets error message on failure', () async {
    final ingredient = testIngredient;
    vm.addIngredient(ingredient);

    when(mockRecipeService.generateRecipe(any)).thenThrow(Exception('API error'));

    await vm.generateRecipe();

    expect(vm.recipe, contains('Failed to generate recipe'));
    expect(vm.generatedRecipe, isNull);
  });

  test('regenerateRecipeImage updates imageUrl and generatedRecipe.imageURL', () async {
    final ingredient = testIngredient;
    vm.addIngredient(ingredient);

    vm.generatedRecipe = Recipe(
      id: '',
      title: 'Test Recipe',
      description: '',
      mealType: 'Dinner',
      cuisineType: 'Italian',
      difficulty: 'Easy',
      prepTime: 10,
      cookingTime: 30,
      ingredients: [ingredient],
      instructions: ['Step 1', 'Step 2'],
      imageURL: '',
      rating: null,
      source: RecipeSource.ai,
    );

    when(mockRecipeService.regenerateRecipeImage(any))
        .thenAnswer((_) async => 'http://image.url/new.png');

    await vm.regenerateRecipeImage();

    expect(vm.imageUrl, 'http://image.url/new.png');
    expect(vm.generatedRecipe!.imageURL, 'http://image.url/new.png');
  });  
}