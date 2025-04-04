import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../viewmodels/recipe_viewmodel.dart';

class GenerateRecipeScreen extends StatelessWidget {
  GenerateRecipeScreen({super.key});

  final TextEditingController _ingredientsController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speakRecipe(String recipe) async {
    if (recipe.isNotEmpty) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Enter ingredients (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: recipeViewModel.isLoading
                  ? null
                  : () => recipeViewModel.generateRecipe(_ingredientsController.text),
              child: recipeViewModel.isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Generate'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipeViewModel.recipe.isNotEmpty)
                      const Text(
                        "Recipe:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(recipeViewModel.recipe),
                    const SizedBox(height: 20),
                    if (recipeViewModel.imageUrl.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Generated Image:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            recipeViewModel.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                'Failed to load image.',
                                style: TextStyle(color: Colors.red),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: recipeViewModel.recipe.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _speakRecipe(recipeViewModel.recipe),
              child: const Icon(Icons.volume_up),
            )
          : null,
    );
  }
}