import 'package:flutter/material.dart';
import '../../models/ingredient.dart';
import '../../widgets/display_recipe_widget.dart';

class ViewRecipeScreen extends StatelessWidget {
  final String recipe;
  final String imageUrl;
  final List<Ingredient> usedIngredients;

  const ViewRecipeScreen({
    super.key,
    required this.recipe,
    required this.imageUrl,
    required this.usedIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DisplayRecipeWidget(
          recipe: recipe,
          imageUrl: imageUrl          
        ),
      ),
    );
  }
}