import 'package:flutter/material.dart';
import '../../../models/ingredient.dart';
import '../../../theme/colors.dart';

class IngredientChipList extends StatelessWidget {
  final List<Ingredient> ingredients;
  final void Function(Ingredient) onRemove;

  const IngredientChipList({
    super.key,
    required this.ingredients,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: ingredients.map((ingredient) {
          return Chip(
            label: Text(
              ingredient.name,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: primarySwatch[200],
            side: BorderSide(color: primarySwatch[200]!),
            deleteIcon: const Icon(Icons.close, color: Colors.white),
            onDeleted: () => onRemove(ingredient),
          );
        }).toList(),
      ),
    );
  }
}
