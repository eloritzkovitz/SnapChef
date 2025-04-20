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
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        height: 300,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Failed to load image.',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    ),
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