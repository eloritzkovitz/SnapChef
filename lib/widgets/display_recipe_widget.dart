import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../theme/colors.dart';
import '../../utils/text_util.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../widgets/tts_widget.dart';

class DisplayRecipeWidget extends StatefulWidget {
  final String? recipeString;
  final Recipe? recipeObject;
  final String? imageUrl;
  final String? cookbookId;
  final Widget Function(String imageUrl)? imageBuilder;

  const DisplayRecipeWidget({
    super.key,
    this.recipeString,
    this.recipeObject,
    this.imageUrl,
    this.cookbookId,
    this.imageBuilder,
  });

  @override
  State<DisplayRecipeWidget> createState() => _DisplayRecipeWidgetState();
}

class _DisplayRecipeWidgetState extends State<DisplayRecipeWidget> {
  late double? _localRating;

  @override
  void initState() {
    super.initState();
    _localRating = widget.recipeObject?.rating;
  }

  @override
  void dispose() {
    // Stop TTS when leaving the page
    TTSWidget.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeObject = widget.recipeObject;
    final String recipe = recipeObject != null
        ? (recipeObject.instructions.join('\n'))
        : (widget.recipeString ?? '');

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
                if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.imageBuilder != null
                          ? widget.imageBuilder!(widget.imageUrl!)
                          : CachedNetworkImage(
                              imageUrl: widget.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/placeholder_image.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                    ),
                  ),
                if (recipeObject != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        initialRating: _localRating ?? 0,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 32.0,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: primaryColor,
                        ),
                        updateOnDrag: true,
                        onRatingUpdate: (newRating) async {
                          setState(() {
                            _localRating = newRating;
                          });
                          if (widget.cookbookId != null) {
                            await Provider.of<CookbookViewModel>(context,
                                    listen: false)
                                .updateRecipe(
                              cookbookId: widget.cookbookId!,
                              recipeId: recipeObject.id,
                              title: recipeObject.title,
                              description: recipeObject.description,
                              mealType: recipeObject.mealType,
                              cuisineType: recipeObject.cuisineType,
                              difficulty: recipeObject.difficulty,
                              cookingTime: recipeObject.cookingTime,
                              prepTime: recipeObject.prepTime,
                              ingredients: recipeObject.ingredients,
                              instructions: recipeObject.instructions,
                              imageURL: recipeObject.imageURL,
                              rating: newRating,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Rating updated!')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _localRating != null
                            ? _localRating!.toStringAsFixed(1)
                            : 'No rating',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
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
      floatingActionButton: recipe.trim().isNotEmpty
          ? TTSWidget(text: stripMarkdown(recipe, preserveNewlines: true))
          : null,
    );
  }
}
