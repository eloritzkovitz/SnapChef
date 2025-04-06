import 'package:flutter/material.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import './widgets/ingredient_card.dart';

class FridgeGridView extends StatelessWidget {
  final List<dynamic> ingredients;
  final String fridgeId;
  final FridgeViewModel viewModel;
  final Function(dynamic ingredient) onDelete;

  const FridgeGridView({
    super.key,
    required this.ingredients,
    required this.fridgeId,
    required this.viewModel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8,
      ),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return IngredientCard(
          ingredient: ingredient,
          onIncrease: () => viewModel.increaseCount(index, fridgeId),
          onDecrease: () => viewModel.decreaseCount(index, fridgeId),
          onDelete: () => onDelete(ingredient),
        );
      },
    );
  }
}