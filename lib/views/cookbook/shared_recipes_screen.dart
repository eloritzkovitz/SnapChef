import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_shared_recipe_screen.dart';
import './widgets/recipe_card.dart';
import '../../viewmodels/cookbook_viewmodel.dart';

class SharedRecipesScreen extends StatelessWidget {
  const SharedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cookbookViewModel = Provider.of<CookbookViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Builder(
        builder: (context) {
          if (cookbookViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sharedRecipes = cookbookViewModel.sharedRecipes;

          if (sharedRecipes.isEmpty) {
            return const Center(
              child: Text(
                'No shared recipes.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: sharedRecipes.length,
            itemBuilder: (context, index) {
              final sharedRecipe = sharedRecipes[index];
              return RecipeCard(
                key: ValueKey(sharedRecipe.recipe.id),
                recipe: sharedRecipe.recipe,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewSharedRecipeScreen(
                        sharedRecipe: sharedRecipe,                        
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}