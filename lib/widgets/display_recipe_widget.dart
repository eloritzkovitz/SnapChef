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
        .replaceAll(RegExp(r'\*\*|__'), '') // Remove bold markers
        .replaceAll(RegExp(r'_'), '') // Remove italic markers
        .replaceAll(RegExp(r'#+ '), '') // Remove heading markers
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '') // Remove links
        .replaceAll(RegExp(r'`'), '') // Remove inline code markers
        .replaceAll(RegExp(r'\n'), ' ') // Replace newlines with spaces
        .trim(); // Trim leading/trailing whitespace
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Ensure no default background color
      body: Container(
        color: Colors.white, // Set the background color explicitly
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Render the recipe text as Markdown with proper constraints
            if (recipe.isNotEmpty)
              Expanded(
                child: Markdown(
                  data: recipe,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    h2: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    p: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
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
      floatingActionButton:
          recipe.isNotEmpty ? TTSWidget(text: stripMarkdown(recipe)) : null,
    );
  }
}