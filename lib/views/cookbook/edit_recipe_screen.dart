import 'package:flutter/material.dart';
import '../../../constants/recipe_constants.dart';
import '../../../models/ingredient.dart';
import '../../../models/recipe.dart';
import '../../../theme/colors.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/snapchef_appbar.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipeObj;
  final void Function({
    required String title,
    required String description,
    required String mealType,
    required String cuisineType,
    required String difficulty,
    required int prepTime,
    required int cookingTime,
    required List<String> instructions,
    required List<Ingredient> ingredients,
    required String imageURL,
    required double? rating,
    required String raw,
  }) onSave;

  const EditRecipeScreen({
    super.key,
    required this.recipeObj,
    required this.onSave,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookingTimeController;
  late TextEditingController _instructionsController;
  late ScrollController _instructionsScrollController;

  String? _selectedMealType;
  String? _selectedCuisine;
  String? _selectedDifficulty;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipeObj.title);
    _descriptionController = TextEditingController(text: widget.recipeObj.description);
    _prepTimeController = TextEditingController(text: widget.recipeObj.prepTime.toString());
    _cookingTimeController = TextEditingController(text: widget.recipeObj.cookingTime.toString());
    _instructionsController = TextEditingController(
      text: widget.recipeObj.instructions.join('\n'),
    );
    _instructionsScrollController = ScrollController();
    _selectedMealType = widget.recipeObj.mealType;
    _selectedCuisine = widget.recipeObj.cuisineType;
    _selectedDifficulty = widget.recipeObj.difficulty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookingTimeController.dispose();
    _instructionsController.dispose();
    _instructionsScrollController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final mealType = _selectedMealType ?? '';
    final cuisineType = _selectedCuisine ?? '';
    final difficulty = _selectedDifficulty ?? '';
    final prepTime = int.tryParse(_prepTimeController.text) ?? 0;
    final cookingTime = int.tryParse(_cookingTimeController.text) ?? 0;
    final instructions = _instructionsController.text
        .split('\n')
        .map((l) => l.trimRight())
        .where((l) => l.isNotEmpty)
        .toList();

    widget.onSave(
      title: title,
      description: description,
      mealType: mealType,
      cuisineType: cuisineType,
      difficulty: difficulty,
      prepTime: prepTime,
      cookingTime: cookingTime,
      instructions: instructions,
      ingredients: widget.recipeObj.ingredients,
      imageURL: widget.recipeObj.imageURL ?? '',
      rating: widget.recipeObj.rating,
      raw: _instructionsController.text,
    );

    setState(() => _isSaving = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final availableHeight = MediaQuery.of(context).size.height - viewInsets.bottom - kToolbarHeight - 32;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final isUserRecipe = widget.recipeObj.source == RecipeSource.user;

    return BaseScreen(
      appBar: SnapChefAppBar(
        title: const Text(
          'Edit Recipe',
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
                                prefixIcon: const Icon(Icons.title, color: Colors.grey),
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
                                prefixIcon: const Icon(Icons.description, color: Colors.grey),
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
                                      labelStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.restaurant, color: Colors.grey),
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
                                    onChanged: (val) => setState(() => _selectedMealType = val),
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
                                      labelStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.room_service, color: Colors.grey),
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
                                    onChanged: (val) => setState(() => _selectedCuisine = val),
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
                                      labelStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.emoji_events, color: Colors.grey),
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
                                    onChanged: (val) => setState(() => _selectedDifficulty = val),
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
                                      labelStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                                      labelStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.timer, color: Colors.grey),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: primaryColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Edit your recipe instructions below:',
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
                                  controller: _instructionsScrollController,
                                  thumbVisibility: true,
                                  child: TextFormField(
                                    controller: _instructionsController,
                                    maxLines: null,
                                    expands: true,
                                    scrollController: _instructionsScrollController,
                                    readOnly: !isUserRecipe,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: isUserRecipe ? Colors.grey[200] : Colors.grey[100],
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
                                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                                    onPressed: _isSaving ? null : () => _saveRecipe(context),
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
                            label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                            onPressed: _isSaving ? null : () => _saveRecipe(context),
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