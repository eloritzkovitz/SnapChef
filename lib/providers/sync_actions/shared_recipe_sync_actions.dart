import '../../repositories/shared_recipe_repository.dart';

class SharedRecipeSyncActions {
  final SharedRecipeRepository sharedRecipeRepository;

  SharedRecipeSyncActions(this.sharedRecipeRepository);

  Future<void> handleSharedRecipeAction(Map<String, dynamic> action) async {
    switch (action['action']) {
      case 'removeShared':
        await sharedRecipeRepository.removeSharedRecipeRemote(
          action['cookbookId'],
          action['sharedRecipeId'],
        );
        // Also remove locally to keep in sync
        await sharedRecipeRepository.removeSharedRecipeLocal(action['sharedRecipeId']);
        break;      
      default:
        break;
    }
  }
}