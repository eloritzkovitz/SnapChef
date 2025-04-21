import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../widgets/tts_widget.dart';

class DisplayRecipeWidget extends StatelessWidget {
  final String recipe;
  final String imageUrl;

  const DisplayRecipeWidget({
    super.key,
    required this.recipe,
    required this.imageUrl,
  });

  // Strip markdown formatting from the recipe text
  String stripMarkdown(String markdownText) {
    return markdownText
        .replaceAll(RegExp(r'\*\*|__'), '')
        .replaceAll(RegExp(r'_'), '')
        .replaceAll(RegExp(r'#+ '), '')
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '')
        .replaceAll(RegExp(r'`'), '')
        .replaceAll(RegExp(r'\n'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Failed to load image.',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (recipe.isNotEmpty)
                  MarkdownBody(
                    data: recipe,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      h2: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      p: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          recipe.isNotEmpty ? TTSWidget(text: stripMarkdown(recipe)) : null,
    );
  }
}
