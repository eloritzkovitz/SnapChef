import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/models/shared_recipe.dart';

class MockSharedRecipeViewModel extends ChangeNotifier
    implements SharedRecipeViewModel {
  final List<SharedRecipe> _sharedWithMeRecipes = [];
  final List<SharedRecipe> _sharedByMeRecipes = [];

  @override
  List<SharedRecipe>? get sharedWithMeRecipes => _sharedWithMeRecipes;

  @override
  List<SharedRecipe>? get sharedByMeRecipes => _sharedByMeRecipes;

  @override
  List<GroupedSharedRecipe> get groupedSharedByMeRecipes => _groupedSharedByMeRecipes;
  List<GroupedSharedRecipe> _groupedSharedByMeRecipes = [];

  set groupedSharedByMeRecipes(List<GroupedSharedRecipe> value) {
    _groupedSharedByMeRecipes = value;
  }

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchSharedRecipes(String cookbookId, String userId) async {}

  @override
  Future<void> removeSharedRecipe(String cookbookId, String sharedRecipeId,
      {required bool isSharedByMe}) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
