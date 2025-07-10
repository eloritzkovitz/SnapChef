import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/models/shared_recipe.dart';

class MockSharedRecipeViewModel extends ChangeNotifier
    implements SharedRecipeViewModel {
  List<SharedRecipe> _sharedWithMeRecipes = [];
  List<SharedRecipe> _sharedByMeRecipes = [];

  @override
  List<SharedRecipe> get sharedByMeRecipes => _sharedByMeRecipes;
  @override
  set sharedByMeRecipes(List<SharedRecipe>? value) => _sharedByMeRecipes = value ?? [];

  @override
  List<SharedRecipe> get sharedWithMeRecipes => _sharedWithMeRecipes;
  @override
  set sharedWithMeRecipes(List<SharedRecipe>? value) => _sharedWithMeRecipes = value ?? [];

  List<GroupedSharedRecipe> _groupedSharedByMeRecipes = [];
  @override
  List<GroupedSharedRecipe> get groupedSharedByMeRecipes => _groupedSharedByMeRecipes;
  set groupedSharedByMeRecipes(List<GroupedSharedRecipe> value) {
    _groupedSharedByMeRecipes = value;
  }

  SharedRecipe? _sharedRecipe;
  SharedRecipe? get sharedRecipe => _sharedRecipe;

  void setSharedRecipe(SharedRecipe recipe) {
    _sharedRecipe = recipe;
    notifyListeners();
  }

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchSharedRecipes(String cookbookId, [String? userId]) async {
    notifyListeners();
  }

  @override
  Future<void> removeSharedRecipe(String cookbookId, String sharedRecipeId,
      {required bool isSharedByMe}) async {    
    _sharedByMeRecipes.removeWhere((r) => r.id == sharedRecipeId);
    _sharedWithMeRecipes.removeWhere((r) => r.id == sharedRecipeId);
    notifyListeners();
  }

  Future<void> addSharedRecipeToCookbook(SharedRecipe sharedRecipe) async {
    notifyListeners();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  void clear() {
  }
}