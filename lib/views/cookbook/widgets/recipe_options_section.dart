import 'package:flutter/material.dart';
import '../../../constants/recipe_constants.dart';

class RecipeOptionsSection extends StatelessWidget {
  final String? selectedMealType;
  final String? selectedCuisine;
  final String? selectedDifficulty;
  final TextEditingController prepTimeController;
  final TextEditingController cookingTimeController;  
  final void Function(String?) onMealTypeChanged;
  final void Function(String?) onCuisineChanged;
  final void Function(String?) onDifficultyChanged;

  const RecipeOptionsSection({
    super.key,
    required this.selectedMealType,
    required this.selectedCuisine,
    required this.selectedDifficulty,
    required this.prepTimeController,
    required this.cookingTimeController,    
    required this.onMealTypeChanged,
    required this.onCuisineChanged,
    required this.onDifficultyChanged,
  });  

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
          items: mealTypes
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
          items: cuisines
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
          items: difficulties
              .map((difficulty) => DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty),
                  ))
              .toList(),
          onChanged: onDifficultyChanged,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: cookingTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cooking Time (minutes)',
            border: OutlineInputBorder(),
          ),
        ),     
      ],
    );
  }
}