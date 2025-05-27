import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_recipe_screen.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';

class SharedRecipesScreen extends StatelessWidget {
  const SharedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedRecipes = Provider.of<CookbookViewModel>(context).sharedRecipes;
    final cookbookId = Provider.of<UserViewModel>(context, listen: false).cookbookId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: sharedRecipes.isEmpty
          ? const Center(
              child: Text(
                'No shared recipes.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: sharedRecipes.length,
              itemBuilder: (context, index) {
                final sharedRecipe = sharedRecipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(sharedRecipe.recipe.title),
                    subtitle: Text(
                      'From: ${sharedRecipe.fromUser} • Status: ${sharedRecipe.status[0].toUpperCase()}${sharedRecipe.status.substring(1)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRecipeScreen(
                            recipe: sharedRecipe.recipe,
                            cookbookId: cookbookId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}