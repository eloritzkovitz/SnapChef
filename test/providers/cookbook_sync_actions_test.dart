import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/providers/sync_actions/cookbook_sync_actions.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/repositories/cookbook_repository.dart';

class MockCookbookRepository extends Mock implements CookbookRepository {}

void main() {
  late MockCookbookRepository mockRepo;
  late CookbookSyncActions actions;
  late Recipe recipe;

  Recipe getTestRecipe() => Recipe(
        id: 'r1',
        title: 'Test Recipe',
        description: 'A test recipe',
        mealType: 'Dinner',
        cuisineType: 'Italian',
        difficulty: 'Easy',
        prepTime: 10,
        cookingTime: 20,
        ingredients: [],
        instructions: ['Step 1', 'Step 2'],
        imageURL: null,
        rating: null,
        isFavorite: false,
        source: RecipeSource.user,
      );

  setUp(() {
    mockRepo = MockCookbookRepository();
    actions = CookbookSyncActions(mockRepo);
    recipe = getTestRecipe();

    when(mockRepo.addRecipeToCookbookRemote('c1', recipe)).thenAnswer((_) async => true);
    when(mockRepo.updateRecipeRemote('c1', 'r1', recipe)).thenAnswer((_) async => true);
    when(mockRepo.deleteRecipeRemote('c1', 'r1')).thenAnswer((_) async => true);
    when(mockRepo.saveRecipeOrderRemote('c1', ['r1', 'r2'])).thenAnswer((_) async {});
    when(mockRepo.toggleRecipeFavoriteStatusRemote('c1', 'r1')).thenAnswer((_) async => true);
  });

  test('add calls addRecipeToCookbookRemote', () async {
    final action = {
      'action': 'add',
      'cookbookId': 'c1',
      'recipe': recipe.toJson(),
    };
    await actions.handleCookbookAction(action);
    verify(mockRepo.addRecipeToCookbookRemote('c1', recipe)).called(1);
  }, skip: true);

  test('update calls updateRecipeRemote', () async {
    final action = {
      'action': 'update',
      'cookbookId': 'c1',
      'recipeId': 'r1',
      'updatedRecipe': recipe.toJson(),
    };
    await actions.handleCookbookAction(action);
    verify(mockRepo.updateRecipeRemote('c1', 'r1', recipe)).called(1);
  }, skip: true);

  test('delete calls deleteRecipeRemote', () async {
    final action = {
      'action': 'delete',
      'cookbookId': 'c1',
      'recipeId': 'r1',
    };
    await actions.handleCookbookAction(action);
    verify(mockRepo.deleteRecipeRemote('c1', 'r1')).called(1);
  }, skip: true);

  test('reorder calls saveRecipeOrderRemote', () async {
    final action = {
      'action': 'reorder',
      'cookbookId': 'c1',
      'orderedIds': ['r1', 'r2'],
    };
    await actions.handleCookbookAction(action);
    verify(mockRepo.saveRecipeOrderRemote('c1', ['r1', 'r2'])).called(1);
  }, skip: true);

  test('toggleFavorite calls toggleRecipeFavoriteStatusRemote', () async {
    final action = {
      'action': 'toggleFavorite',
      'cookbookId': 'c1',
      'recipeId': 'r1',
    };
    await actions.handleCookbookAction(action);
    verify(mockRepo.toggleRecipeFavoriteStatusRemote('c1', 'r1')).called(1);
  }, skip: true);
}