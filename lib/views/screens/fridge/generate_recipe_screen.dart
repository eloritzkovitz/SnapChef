import 'package:flutter/material.dart';
import '../../../services/generate_recipe.dart';

class GenerateRecipeScreen extends StatelessWidget {
  
  const GenerateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Recipe')),
      body: const GenerateRecipe(),
    );
  }
}