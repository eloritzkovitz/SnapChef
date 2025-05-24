import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/recipe_options.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../theme/colors.dart';

class AddRecipeScreen extends StatefulWidget {
  final String? cookbookId;
  const AddRecipeScreen({super.key, this.cookbookId});

  @override
  State<AddRecipeScreen> createState() => _AddManualRecipeScreenState();
}

class _AddManualRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipeTextController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();

  final ScrollController _recipeScrollController = ScrollController();

  String? _selectedMealType;
  String? _selectedCuisine;
  String? _selectedDifficulty;

  bool _isSaving = false;

  @override
  void dispose() {
    _recipeTextController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookingTimeController.dispose();
    _recipeScrollController.dispose();
    super.dispose();
  }

  // Parses the markdown-like input into a Recipe object
  Recipe parsePersonalRecipe(String input) {
    final lines = input.split('\n').map((l) => l.trim()).toList();
    String title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'Personal Recipe';
    String description = _descriptionController.text.trim();
    List<String> instructions = [];
    List<Ingredient> ingredients = [];
    String mealType = _selectedMealType ?? '';
    String cuisineType = _selectedCuisine ?? '';
    String difficulty = _selectedDifficulty ?? '';
    int prepTime = _prepTimeController.text.isNotEmpty
        ? int.tryParse(_prepTimeController.text) ?? 0
        : 0;
    int cookingTime = _cookingTimeController.text.isNotEmpty
        ? int.tryParse(_cookingTimeController.text) ?? 0
        : 0;
    String imageURL = '';
    double? rating;
    bool inIngredients = false;
    bool inInstructions = false;

    for (final line in lines) {
      if (line.isEmpty) continue;
      if (line.toLowerCase().contains('ingredients')) {
        inIngredients = true;
        inInstructions = false;
        continue;
      }
      if (line.toLowerCase().contains('instructions')) {
        inIngredients = false;
        inInstructions = true;
        continue;
      }
      if (inIngredients && line.startsWith('*')) {
        ingredients.add(Ingredient(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: line.replaceFirst('*', '').trim(),
          category: '',
          imageURL: '',
          count: 1,
        ));
      }
      if (inInstructions && line.startsWith('*')) {
        instructions.add(line.replaceFirst('*', '').trim());
      }
    }

    return Recipe(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      mealType: mealType,
      cuisineType: cuisineType,
      difficulty: difficulty,
      prepTime: prepTime,
      cookingTime: cookingTime,
      ingredients: ingredients,
      instructions: instructions,
      imageURL: imageURL,
      rating: rating,
    );
  }

  Future<void> _saveRecipe(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final rawInput = _recipeTextController.text;
    final recipe = parsePersonalRecipe(rawInput);

    final user = Provider.of<UserViewModel>(context, listen: false);
    final cookbookId = widget.cookbookId ?? user.cookbookId ?? '';

    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    await cookbookViewModel.addRecipeToCookbook(
      cookbookId: cookbookId,
      title: recipe.title,
      description: recipe.description,
      mealType: recipe.mealType,
      cuisineType: recipe.cuisineType,
      difficulty: recipe.difficulty,
      prepTime: recipe.prepTime,
      cookingTime: recipe.cookingTime,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageURL: recipe.imageURL,
      rating: recipe.rating,
      raw: rawInput,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final availableHeight = MediaQuery.of(context).size.height -
        viewInsets.bottom -
        kToolbarHeight -
        32; // 32 for padding

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Manual Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMealType,
                              decoration: InputDecoration(
                                labelText: 'Meal Type',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCuisine,
                              decoration: InputDecoration(
                                labelText: 'Cuisine',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedDifficulty,
                              decoration: InputDecoration(
                                labelText: 'Difficulty',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _prepTimeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Prep Time (min)',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _cookingTimeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cooking Time (min)',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Paste or type your recipe in the format below:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: availableHeight * 0.5,
                          minHeight: 120,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Scrollbar(
                            controller: _recipeScrollController,
                            thumbVisibility: true,
                            child: TextFormField(
                              controller: _recipeTextController,
                              maxLines: null,
                              expands: true,
                              scrollController: _recipeScrollController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(12),
                                hintText: '''**Ingredients:**
*   1 cup Flour
*   2 Eggs

**Instructions:**
*   Mix ingredients.
*   Bake for 20 minutes.
''',
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your recipe.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save Recipe'),
                          onPressed:
                              _isSaving ? null : () => _saveRecipe(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}