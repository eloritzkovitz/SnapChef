import 'package:snapchef/models/shared_recipe.dart';
import 'package:snapchef/repositories/shared_recipe_repository.dart';
import 'package:snapchef/database/app_database.dart' hide SharedRecipe;
import 'package:snapchef/services/shared_recipe_service.dart';

class MockSharedRecipeRepository implements SharedRecipeRepository {
  @override
  AppDatabase get database => throw UnimplementedError();

  @override
  SharedRecipeService get sharedRecipeService => throw UnimplementedError();

  @override
  Future<Map<String, List<SharedRecipe>>> fetchSharedRecipesRemote(String cookbookId) async => {
    'sharedWithMe': [],
    'sharedByMe': [],
  };

  @override
  Future<List<SharedRecipe>> fetchSharedRecipesLocal(String userId) async => [];

  @override
  Future<void> addSharedRecipeLocal(SharedRecipe sharedRecipe) async {}

  @override
  Future<void> storeSharedRecipesLocal(List<SharedRecipe> sharedRecipes) async {}

  @override
  Future<void> removeSharedRecipeRemote(String cookbookId, String sharedRecipeId) async {}

  @override
  Future<void> removeSharedRecipeLocal(String sharedRecipeId) async {}
}