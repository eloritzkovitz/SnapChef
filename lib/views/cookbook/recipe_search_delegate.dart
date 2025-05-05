import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'view_recipe_screen.dart';
import './widgets/recipe_card.dart';

class RecipeSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
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
                  recipeId: recipe.id,
                  cookbookId: Provider.of<AuthViewModel>(context, listen: false).cookbookId ?? '',
                  recipe: recipe.instructions.join('\n'),
                  imageUrl: recipe.imageURL ?? '',
                  usedIngredients: recipe.ingredients,
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
                  recipeId: recipe.id,
                  cookbookId: Provider.of<AuthViewModel>(context, listen: false).cookbookId ?? '',
                  recipe: recipe.instructions.join('\n'),
                  imageUrl: recipe.imageURL ?? '',
                  usedIngredients: recipe.ingredients,
                ),
              ),
            );
          },
        );
      },
    );
  }
}