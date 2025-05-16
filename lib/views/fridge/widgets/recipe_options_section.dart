import 'package:flutter/material.dart';

class RecipeOptionsSection extends StatelessWidget {
  final String? selectedMealType;
  final String? selectedCuisine;
  final String? selectedDifficulty;
  final TextEditingController cookingTimeController;
  final TextEditingController prepTimeController;
  final void Function(String?) onMealTypeChanged;
  final void Function(String?) onCuisineChanged;
  final void Function(String?) onDifficultyChanged;

  const RecipeOptionsSection({
    super.key,
    required this.selectedMealType,
    required this.selectedCuisine,
    required this.selectedDifficulty,
    required this.cookingTimeController,
    required this.prepTimeController,
    required this.onMealTypeChanged,
    required this.onCuisineChanged,
    required this.onDifficultyChanged,
  });

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
    'Vietnamese',
  ];

  static const List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Meal Type',
            border: OutlineInputBorder(),
          ),
          value: selectedMealType,
          items: _mealTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: onMealTypeChanged,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Cuisine',
            border: OutlineInputBorder(),
          ),
          value: selectedCuisine,
          items: _cuisines
              .map((cuisine) => DropdownMenuItem(
                    value: cuisine,
                    child: Text(cuisine),
                  ))
              .toList(),
          onChanged: onCuisineChanged,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Difficulty',
            border: OutlineInputBorder(),
          ),
          value: selectedDifficulty,
          items: _difficulties
              .map((difficulty) => DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty),
                  ))
              .toList(),
          onChanged: onDifficultyChanged,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: cookingTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cooking Time (minutes)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: prepTimeController,
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