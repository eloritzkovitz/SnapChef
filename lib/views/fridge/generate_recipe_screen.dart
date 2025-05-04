import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import 'recipe_result_screen.dart';

class GenerateRecipeScreen extends StatefulWidget {
  const GenerateRecipeScreen({super.key});

  @override
  State<GenerateRecipeScreen> createState() => _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends State<GenerateRecipeScreen> {
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();

  String? _selectedMealType;
  String? _selectedCuisine;
  String? _selectedDifficulty;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<String> _cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _cookingTimeController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

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
            // Dropdowns and Input Fields for Recipe Options
            _buildOptionsSection(),

            const SizedBox(height: 16),

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
                      await recipeViewModel.generateRecipe(
                        mealType: _selectedMealType,
                        cuisine: _selectedCuisine,
                        difficulty: _selectedDifficulty,
                        cookingTime: _cookingTimeController.text.isNotEmpty
                            ? int.tryParse(_cookingTimeController.text)
                            : null,
                        prepTime: _prepTimeController.text.isNotEmpty
                            ? int.tryParse(_prepTimeController.text)
                            : null,
                      );
                      if (recipeViewModel.recipe.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeResultScreen(
                              recipe: recipeViewModel.recipe,
                              imageUrl: recipeViewModel.imageUrl,
                              usedIngredients:
                                  recipeViewModel.selectedIngredients,
                              mealType: _selectedMealType,
                              cuisineType: _selectedCuisine,
                              difficulty: _selectedDifficulty,
                              cookingTime: _cookingTimeController
                                      .text.isNotEmpty
                                  ? int.tryParse(_cookingTimeController.text)
                                  : null,
                              prepTime: _prepTimeController.text.isNotEmpty
                                  ? int.tryParse(_prepTimeController.text)
                                  : null,
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

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal Type Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Meal Type',
            border: OutlineInputBorder(),
          ),
          value: _selectedMealType,
          items: _mealTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedMealType = value;
            });
          },
        ),
        const SizedBox(height: 8),

        // Cuisine Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Cuisine',
            border: OutlineInputBorder(),
          ),
          value: _selectedCuisine,
          items: _cuisines
              .map((cuisine) => DropdownMenuItem(
                    value: cuisine,
                    child: Text(cuisine),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCuisine = value;
            });
          },
        ),
        const SizedBox(height: 8),

        // Difficulty Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Difficulty',
            border: OutlineInputBorder(),
          ),
          value: _selectedDifficulty,
          items: _difficulties
              .map((difficulty) => DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedDifficulty = value;
            });
          },
        ),
        const SizedBox(height: 8),

        // Cooking Time Input
        TextFormField(
          controller: _cookingTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cooking Time (minutes)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),

        // Preparation Time Input
        TextFormField(
          controller: _prepTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Preparation Time (minutes)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
