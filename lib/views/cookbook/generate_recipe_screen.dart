import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_result_screen.dart';
import 'widgets/ingredient_chip_list.dart';
import 'widgets/ingredient_selection_modal.dart';
import '../../constants/recipe_options.dart';
import '../../models/ingredient.dart';
import '../../models/preferences.dart';
import '../../theme/colors.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';

class GenerateRecipeScreen extends StatefulWidget {
  const GenerateRecipeScreen({super.key});

  @override
  State<GenerateRecipeScreen> createState() => _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends State<GenerateRecipeScreen> {
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedMealType;
  String? _selectedCuisine;
  String? _selectedDifficulty;

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
    _prepTimeController.dispose();
    _cookingTimeController.dispose();
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

  void _resetFields() {
    setState(() {
      _selectedMealType = null;
      _selectedCuisine = null;
      _selectedDifficulty = null;
      _prepTimeController.clear();
      _cookingTimeController.clear();
      _searchController.clear();
      _filteredIngredients.clear();

      final recipeViewModel =
          Provider.of<RecipeViewModel>(context, listen: false);
      recipeViewModel.clearSelectedIngredients();
    });
  }

  void _showIngredientSelectionPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const IngredientSelectionModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final recipeViewModel = Provider.of<RecipeViewModel>(context);
    final fridgeViewModel = Provider.of<FridgeViewModel>(context);

    final preferences = userViewModel.user?.preferences ??
        Preferences(
            allergies: [], dietaryPreferences: {}, notificationPreferences: {});    

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _resetFields();
        }
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Redesigned options section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Meal Type Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedMealType,
                              decoration: InputDecoration(
                                labelText: 'Meal Type',
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.restaurant,
                                    color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                              ),
                              items: mealTypes
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedMealType = val),
                              isExpanded: true,
                              isDense: true,
                              iconEnabledColor: primaryColor,
                            ),
                            const SizedBox(height: 8),
                            // Cuisine Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedCuisine,
                              decoration: InputDecoration(
                                labelText: 'Cuisine',
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.room_service,
                                    color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                              ),
                              items: cuisines
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCuisine = val),
                              isExpanded: true,
                              isDense: true,
                              iconEnabledColor: primaryColor,
                            ),
                            const SizedBox(height: 8),
                            // Difficulty Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedDifficulty,
                              decoration: InputDecoration(
                                labelText: 'Difficulty',
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.emoji_events,
                                    color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                              ),
                              items: difficulties
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedDifficulty = val),
                              isExpanded: true,
                              isDense: true,
                              iconEnabledColor: primaryColor,
                            ),
                            const SizedBox(height: 8),
                            // Prep Time
                            TextFormField(
                              controller: _prepTimeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Prep Time (min)',
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.access_time,
                                    color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Cooking Time
                            TextFormField(
                              controller: _cookingTimeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cooking Time (min)',
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon:
                                    const Icon(Icons.timer, color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Ingredients',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: fridgeViewModel.ingredients.isEmpty
                                ? null
                                : () => _showIngredientSelectionPopup(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primarySwatch[200],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        recipeViewModel.selectedIngredients.isEmpty
                            ? Center(
                                child: Text(
                                  'Please add ingredients in order to generate recipes',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Column(
                                children: [
                                  IngredientChipList(
                                    ingredients:
                                        recipeViewModel.selectedIngredients,
                                    onRemove: (ingredient) => recipeViewModel
                                        .removeIngredient(ingredient),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: recipeViewModel.isLoading ||
                            recipeViewModel.selectedIngredients.isEmpty
                        ? null
                        : () async {
                            await recipeViewModel.generateRecipe(
                              mealType: _selectedMealType,
                              cuisine: _selectedCuisine,
                              difficulty: _selectedDifficulty,
                              prepTime: _prepTimeController.text.isNotEmpty
                                  ? int.tryParse(_prepTimeController.text)
                                  : null,
                              cookingTime: _cookingTimeController
                                      .text.isNotEmpty
                                  ? int.tryParse(_cookingTimeController.text)
                                  : null,
                              preferences: preferences.toRecipeJson(),
                            );
                            if (recipeViewModel.recipe.isNotEmpty &&
                                context.mounted) {
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
                                    prepTime: _prepTimeController
                                            .text.isNotEmpty
                                        ? int.tryParse(_prepTimeController.text)
                                        : null,
                                    cookingTime:
                                        _cookingTimeController.text.isNotEmpty
                                            ? int.tryParse(
                                                _cookingTimeController.text)
                                            : null,
                                  ),
                                ),
                              ).then((_) {
                                _resetFields();
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: recipeViewModel.isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Generate',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
