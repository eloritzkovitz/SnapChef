import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../view_recipe_screen.dart';
import '../../../models/recipe.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../theme/colors.dart';
import '../../../utils/image_util.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rating = recipe.rating?.toDouble() ?? 0.0;

    // Choose icon and tooltip based on recipe source
    final sourceIcon = recipe.source == RecipeSource.ai
        ? Icon(Icons.smart_toy, size: 18, color: primaryColor)
        : recipe.source == RecipeSource.shared
            ? Icon(Icons.people_alt, size: 18, color: primaryColor)
            : Icon(Icons.person, size: 18, color: primaryColor);

    final sourceTooltip = recipe.source == RecipeSource.ai
        ? 'AI Generated'
        : recipe.source == RecipeSource.shared
            ? 'Shared Recipe'
            : 'User Recipe';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: primarySwatch[900],
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewRecipeScreen(
                    recipe: recipe,
                    cookbookId:
                        Provider.of<UserViewModel>(context, listen: false)
                                .cookbookId ??
                            '',
                  ),
                ),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with source and favorite indicator
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: recipe.imageURL != null &&
                            recipe.imageURL!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl:
                                ImageUtil().getFullImageUrl(recipe.imageURL),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                  // Source icon
                  Positioned(
                    top: -6,
                    left: -6,
                    child: Tooltip(
                      message: sourceTooltip,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.white,
                        child: sourceIcon,
                      ),
                    ),
                  ),
                  // Favorite heart
                  if (recipe.isFavorite)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.white,
                        child:
                            Icon(Icons.favorite, color: Colors.red, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: primaryColor),
                      itemCount: 5,
                      itemSize: 20.0,
                      unratedColor: Colors.grey,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.restaurant,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          recipe.mealType,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.room_service,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          recipe.cuisineType,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.emoji_events,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTime}m',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTime}m',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
