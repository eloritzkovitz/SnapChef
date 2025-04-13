import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import 'recipe_result_screen.dart';

class GenerateRecipeScreen extends StatefulWidget {
  GenerateRecipeScreen({super.key});

  @override
  _GenerateRecipeScreenState createState() => _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends State<GenerateRecipeScreen> {
  final List<String> _selectedIngredients = []; // To store selected ingredients

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
                  : ListView.builder(
                      itemCount: fridgeViewModel.ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = fridgeViewModel.ingredients[index];
                        final isSelected = _selectedIngredients.contains(ingredient.name);

                        return CheckboxListTile(
                          title: Text(ingredient.name),
                          subtitle: Text('Quantity: ${ingredient.count}'),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedIngredients.add(ingredient.name);
                              } else {
                                _selectedIngredients.remove(ingredient.name);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),

            // Generate Recipe Button
            ElevatedButton(
              onPressed: recipeViewModel.isLoading || _selectedIngredients.isEmpty
                  ? null
                  : () async {
                      // Send selected ingredients to the RecipeViewModel
                      await recipeViewModel.generateRecipe(_selectedIngredients);
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