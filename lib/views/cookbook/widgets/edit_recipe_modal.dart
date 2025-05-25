import 'package:flutter/material.dart';
import '../../../constants/recipe_options.dart';
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
    required int prepTime,
    required int cookingTime,    
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
  late TextEditingController prepTimeController;
  late TextEditingController cookingTimeController;  
  late String mealType;
  late String cuisineType;
  late String difficulty;  

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.recipeObj.title);
    descriptionController = TextEditingController(text: widget.recipeObj.description);
    prepTimeController = TextEditingController(text: widget.recipeObj.prepTime.toString());
    cookingTimeController = TextEditingController(text: widget.recipeObj.cookingTime.toString());    
    mealType = widget.recipeObj.mealType;
    cuisineType = widget.recipeObj.cuisineType;
    difficulty = widget.recipeObj.difficulty;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    prepTimeController.dispose();
    cookingTimeController.dispose();    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure dropdowns always have the current value
    final mealTypeItems = [
      ...mealTypes,
      if (!mealTypes.contains(mealType)) mealType,
    ];
    final cuisineTypeItems = [
      ...cuisines,
      if (!cuisines.contains(cuisineType)) cuisineType,
    ];
    final difficultyItems = [
      ...difficulties,
      if (!difficulties.contains(difficulty)) difficulty,
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
              controller: prepTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Preparation Time (min)'),
            ),           
            const SizedBox(height: 8),
             TextField(
              controller: cookingTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cooking Time (min)'),
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
              prepTime: int.tryParse(prepTimeController.text) ?? widget.recipeObj.prepTime,
              cookingTime: int.tryParse(cookingTimeController.text) ?? widget.recipeObj.cookingTime,              
            );
            Navigator.pop(context);
          },
          child: const Text('Save', style: TextStyle(color: primaryColor)),
        ),
      ],
    );
  }
}