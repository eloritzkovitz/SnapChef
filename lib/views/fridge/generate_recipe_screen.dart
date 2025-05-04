import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../models/ingredient.dart';
import 'recipe_result_screen.dart';

class GenerateRecipeScreen extends StatefulWidget {
  const GenerateRecipeScreen({super.key});

  @override
  State<GenerateRecipeScreen> createState() => _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends State<GenerateRecipeScreen> {
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedMealType;
  String? _selectedCuisine;
  String? _selectedDifficulty;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<String> _cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  List<Ingredient> _filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterIngredients(_searchController.text);
    });
  }

  @override
  void dispose() {
    _cookingTimeController.dispose();
    _prepTimeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterIngredients(String query) {
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);

    setState(() {
      _filteredIngredients = fridgeViewModel.ingredients
          .where((ingredient) =>
              ingredient.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Clears the ingredient list and settings
  void _resetFields() {
    setState(() {
      _selectedMealType = null;
      _selectedCuisine = null;
      _selectedDifficulty = null;
      _cookingTimeController.clear();
      _prepTimeController.clear();
      _searchController.clear();
      _filteredIngredients.clear();

      final recipeViewModel =
          Provider.of<RecipeViewModel>(context, listen: false);
      recipeViewModel.clearSelectedIngredients();
    });
  }

  void _showIngredientSelectionPopup(BuildContext context) {
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);
    final recipeViewModel =
        Provider.of<RecipeViewModel>(context, listen: false);

    setState(() {
      _filteredIngredients = fridgeViewModel.ingredients;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to adjust for the keyboard
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar and Close Button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _filterIngredients(
                                    value); // Dynamically filter ingredients
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Search Ingredients',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.pop(context); // Close the popup
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Ingredient List
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.5, // Adjust height
                      child: ListView.builder(
                        itemCount: _filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = _filteredIngredients[index];
                          final isSelected =
                              recipeViewModel.isIngredientSelected(ingredient);

                          return ListTile(
                            title: Text(ingredient.name),
                            subtitle: Text('Quantity: ${ingredient.count}'),
                            trailing: Checkbox(
                              value: isSelected,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    recipeViewModel.addIngredient(ingredient);
                                  } else {
                                    recipeViewModel
                                        .removeIngredient(ingredient);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                if (!isSelected) {
                                  recipeViewModel.addIngredient(ingredient);
                                } else {
                                  recipeViewModel.removeIngredient(ingredient);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);
    final fridgeViewModel = Provider.of<FridgeViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        _resetFields(); // Clear fields when navigating back
        return true; // Allow the navigation to proceed
      },
      child: Scaffold(
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

              // Ingredient Selection Button
              ElevatedButton(
                onPressed: fridgeViewModel.ingredients.isEmpty
                    ? null
                    : () => _showIngredientSelectionPopup(context),
                child: const Text('Select Ingredients'),
              ),

              const SizedBox(height: 16),

              // Selected Ingredients Checklist
              Expanded(
                child: ListView(
                  children:
                      recipeViewModel.selectedIngredients.map((ingredient) {
                    return ListTile(
                      title: Text(ingredient.name),
                      subtitle: Text('Quantity: ${ingredient.count}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                        onPressed: () {
                          recipeViewModel.removeIngredient(ingredient);
                        },
                      ),
                    );
                  }).toList(),
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
                          _resetFields(); // Clear fields after saving
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
