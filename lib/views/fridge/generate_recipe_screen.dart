import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import 'recipe_result_screen.dart';

class GenerateRecipeScreen extends StatelessWidget {
  const GenerateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);
    final fridgeViewModel = Provider.of<FridgeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display fridge items with checkboxes
            Expanded(
              child: fridgeViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : fridgeViewModel.ingredients.isEmpty
                      ? const Center(
                          child: Text(
                            'No ingredients in the fridge. Please add some before generating a recipe.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: fridgeViewModel.ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient =
                                fridgeViewModel.ingredients[index];
                            final isSelected = recipeViewModel
                                .isIngredientSelected(ingredient);

                            return CheckboxListTile(
                              title: Text(ingredient.name),
                              subtitle: Text('Quantity: ${ingredient.count}'),
                              value: isSelected,
                              onChanged: (bool? value) {
                                if (value == true) {
                                  recipeViewModel.addIngredient(ingredient);
                                } else {
                                  recipeViewModel.removeIngredient(ingredient);
                                }
                              },
                            );
                          },
                        ),
            ),

            // Generate Recipe Button
            ElevatedButton(
              onPressed: recipeViewModel.isLoading ||
                      recipeViewModel.selectedIngredients.isEmpty
                  ? null
                  : () async {
                      // Generate the recipe through the view model
                      await recipeViewModel.generateRecipe();
                      if (recipeViewModel.recipe.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeResultScreen(
                              recipe: recipeViewModel.recipe,
                              imageUrl: recipeViewModel.imageUrl,
                              usedIngredients:
                                  recipeViewModel.selectedIngredients,
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
