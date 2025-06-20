import 'package:snapchef/models/shared_recipe.dart';

class MockSharedRecipeRepository { 
  final database = null;
  final sharedRecipeService = null;

  Future<Map<String, List<SharedRecipe>>> fetchSharedRecipesRemote(String cookbookId) async => {
    'sharedWithMe': [],
    'sharedByMe': [],
  };

  Future<List<SharedRecipe>> fetchSharedRecipesLocal(String userId) async => [];

  Future<void> addSharedRecipeLocal(SharedRecipe sharedRecipe) async {}

  Future<void> storeSharedRecipesLocal(List<SharedRecipe> sharedRecipes) async {}

  Future<void> removeSharedRecipeRemote(String cookbookId, String sharedRecipeId) async {}

  Future<void> removeSharedRecipeLocal(String sharedRecipeId) async {}
}