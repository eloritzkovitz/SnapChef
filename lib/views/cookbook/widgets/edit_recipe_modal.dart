import 'package:flutter/material.dart';
import '../../../models/recipe.dart';
import '../../../theme/colors.dart';

class EditRecipeModal extends StatefulWidget {
  final Recipe recipeObj;
  final void Function({
    required String title,
    required String description,
    required String mealType,
    required String cuisineType,
    required String difficulty,
    required int cookingTime,
    required int prepTime,
  }) onSave;

  const EditRecipeModal({
    super.key,
    required this.recipeObj,
    required this.onSave,
  });

  @override
  State<EditRecipeModal> createState() => _EditRecipeModalState();
}

class _EditRecipeModalState extends State<EditRecipeModal> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController cookingTimeController;
  late TextEditingController prepTimeController;
  late String mealType;
  late String cuisineType;
  late String difficulty;

  static const List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Drink'
  ];
  static const List<String> _cuisines = [
    'African',
    'American',
    'Brazilian',
    'British',
    'Caribbean',
    'Chinese',
    'Ethiopian',
    'Filipino',
    'French',
    'German',
    'Greek',
    'Indian',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Levantine',
    'Mexican',
    'Moroccan',
    'Persian',
    'Russian',
    'Spanish',
    'Thai',
    'Turkish',
    'Vietnamese'
  ];
  static const List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.recipeObj.title);
    descriptionController = TextEditingController(text: widget.recipeObj.description);
    cookingTimeController = TextEditingController(text: widget.recipeObj.cookingTime.toString());
    prepTimeController = TextEditingController(text: widget.recipeObj.prepTime.toString());
    mealType = widget.recipeObj.mealType;
    cuisineType = widget.recipeObj.cuisineType;
    difficulty = widget.recipeObj.difficulty;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    cookingTimeController.dispose();
    prepTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure dropdowns always have the current value
    final mealTypeItems = [
      ..._mealTypes,
      if (!_mealTypes.contains(mealType)) mealType,
    ];
    final cuisineTypeItems = [
      ..._cuisines,
      if (!_cuisines.contains(cuisineType)) cuisineType,
    ];
    final difficultyItems = [
      ..._difficulties,
      if (!_difficulties.contains(difficulty)) difficulty,
    ];

    return AlertDialog(
      title: const Text('Edit Recipe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: mealType,
              decoration: const InputDecoration(labelText: 'Meal Type'),
              items: mealTypeItems
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => mealType = val ?? mealType),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: cuisineType,
              decoration: const InputDecoration(labelText: 'Cuisine'),
              items: cuisineTypeItems
                  .map((cuisine) => DropdownMenuItem(
                        value: cuisine,
                        child: Text(cuisine),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => cuisineType = val ?? cuisineType),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: difficultyItems
                  .map((diff) => DropdownMenuItem(
                        value: diff,
                        child: Text(diff),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => difficulty = val ?? difficulty),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cookingTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cooking Time (min)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: prepTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Preparation Time (min)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(
              title: titleController.text,
              description: descriptionController.text,
              mealType: mealType,
              cuisineType: cuisineType,
              difficulty: difficulty,
              cookingTime: int.tryParse(cookingTimeController.text) ?? widget.recipeObj.cookingTime,
              prepTime: int.tryParse(prepTimeController.text) ?? widget.recipeObj.prepTime,
            );
            Navigator.pop(context);
          },
          child: const Text('Save', style: TextStyle(color: primaryColor)),
        ),
      ],
    );
  }
}