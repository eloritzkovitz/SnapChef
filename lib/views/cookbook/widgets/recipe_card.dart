import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../view_recipe_screen.dart';
import '../../../models/recipe.dart';
import '../../../theme/colors.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    Key? key,
    required this.recipe,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rating = recipe.rating?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: primarySwatch[900],
      child: ListTile(
        leading: recipe.imageURL != null && recipe.imageURL!.isNotEmpty
            ? Image.network(
                recipe.imageURL!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported,
                      size: 50, color: Colors.grey);
                },
              )
            : const Icon(Icons.image, size: 50, color: Colors.grey),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            RatingBarIndicator(
              rating: rating,
              itemBuilder: (context, _) => const Icon(Icons.star, color: primaryColor),
              itemCount: 5,
              itemSize: 20.0,
              unratedColor: Colors.grey,
              direction: Axis.horizontal,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  recipe.mealType,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.room_service, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  recipe.cuisineType,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.emoji_events, size: 16, color: Colors.grey),
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
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
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
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewRecipeScreen(
                    recipe: recipe,
                    cookbookId: Provider.of<AuthViewModel>(context, listen: false).cookbookId ?? '',
                  ),
                ),
              );
            },
      ),
    );
  }
}