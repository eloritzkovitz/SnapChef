import 'package:flutter/material.dart';
import '../../widgets/tts_widget.dart';

class RecipeResultScreen extends StatelessWidget {
  final String recipe;
  final String imageUrl;

  const RecipeResultScreen({super.key, required this.recipe, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Result', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.black,        
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.isNotEmpty)
                const Text(
                  "Recipe:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              Text(recipe),
              const SizedBox(height: 20),
              if (imageUrl.isNotEmpty)
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
                      imageUrl,
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
      floatingActionButton: recipe.isNotEmpty
          ? TTSWidget(text: recipe)
          : null,
    );
  }
}