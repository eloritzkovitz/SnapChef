import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import 'recipe_result_screen.dart';

class GenerateRecipeScreen extends StatelessWidget {
  GenerateRecipeScreen({super.key});

  final TextEditingController _ingredientsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Enter ingredients (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: recipeViewModel.isLoading
                  ? null
                  : () async {
                      await recipeViewModel.generateRecipe(_ingredientsController.text);
                      if (recipeViewModel.recipe.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeResultScreen(
                              recipe: recipeViewModel.recipe,
                              imageUrl: recipeViewModel.imageUrl,
                            ),
                          ),
                        );
                      }
                    },
              child: recipeViewModel.isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}