import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import 'view_recipe_screen.dart';
import './widgets/recipe_card.dart';
import '../../widgets/snapchef_search_delegate.dart';

class RecipeSearchDelegate extends SnapChefSearchDelegate {
  RecipeSearchDelegate() : super(label: 'Search recipes');

  @override
  List<Widget> buildActions(BuildContext context) {    
    return super.buildActions(context)!;
  }  

  @override
  Widget buildResults(BuildContext context) {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);
    final results = cookbookViewModel.searchRecipes(query);

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No recipes found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final recipe = results[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewRecipeScreen(
                  recipe: recipe,
                  cookbookId: Provider.of<UserViewModel>(context, listen: false).cookbookId ?? '',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);
    final suggestions = cookbookViewModel.searchRecipes(query);

    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'No matching recipes.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final recipe = suggestions[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewRecipeScreen(
                  recipe: recipe,
                  cookbookId: Provider.of<UserViewModel>(context, listen: false).cookbookId ?? '',
                ),
              ),
            );
          },
        );
      },
    );
  }
}