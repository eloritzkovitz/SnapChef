import 'package:flutter/material.dart';
import '../../services/generate_recipe.dart';

class GenerateRecipeScreen extends StatelessWidget {
  
  const GenerateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Recipe', style: TextStyle(fontWeight: FontWeight.bold)),        
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: const GenerateRecipe(),
    );
  }
}