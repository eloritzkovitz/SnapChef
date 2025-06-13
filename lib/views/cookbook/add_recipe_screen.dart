import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/recipe_options.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../theme/colors.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/snapchef_appbar.dart';

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
    final lines = input.split('\n').map((l) => l.trimRight()).toList();
    String title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'User-made Recipe';
    String description = _descriptionController.text.trim();
    List<String> instructions = List.from(lines);
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
      source: RecipeSource.user,
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
      source: RecipeSource.user,
      raw: rawInput,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe added!')),
        );
      }
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final availableHeight = MediaQuery.of(context).size.height -
        viewInsets.bottom -
        kToolbarHeight -
        32;

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BaseScreen(
      appBar: SnapChefAppBar(
        title: const Text(
          'Add Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon:
                                    const Icon(Icons.title, color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.description,
                                    color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
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
                                        borderSide:
                                            BorderSide(color: primaryColor),
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
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
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
                                        borderSide:
                                            BorderSide(color: primaryColor),
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
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
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
                                        borderSide:
                                            BorderSide(color: primaryColor),
                                      ),
                                    ),
                                    items: difficulties
                                        .map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            ))
                                        .toList(),
                                    onChanged: (val) => setState(
                                        () => _selectedDifficulty = val),
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
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
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
                                        borderSide:
                                            BorderSide(color: primaryColor),
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
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.timer,
                                          color: Colors.grey),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                            BorderSide(color: primaryColor),
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
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Scrollbar(
                                  controller: _recipeScrollController,
                                  thumbVisibility: true,
                                  child: TextFormField(
                                    controller: _recipeTextController,
                                    maxLines: null,
                                    expands: true,
                                    scrollController: _recipeScrollController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),                                      
                                      contentPadding: const EdgeInsets.fromLTRB(12, -10, 12, 12),
                                      hintText: '''# My Recipe

This is a description of my recipe.

**Ingredients:**
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your recipe.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isKeyboardOpen)
                              SafeArea(
                                top: false,
                                child: SizedBox(
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
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Icon(Icons.save),
                                    label: Text(_isSaving
                                        ? 'Saving...'
                                        : 'Save Recipe'),
                                    onPressed: _isSaving
                                        ? null
                                        : () => _saveRecipe(context),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!isKeyboardOpen)
                      SafeArea(
                        top: false,
                        child: SizedBox(
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
                            label:
                                Text(_isSaving ? 'Saving...' : 'Save Recipe'),
                            onPressed:
                                _isSaving ? null : () => _saveRecipe(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}