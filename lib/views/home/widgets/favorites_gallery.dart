import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../viewmodels/cookbook_viewmodel.dart';
import '../../cookbook/view_recipe_screen.dart';
import '../../../utils/image_util.dart';

class FavoritesGallery extends StatelessWidget {
  const FavoritesGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Consumer<CookbookViewModel>(
      builder: (context, cookbookViewModel, _) {
        final favoriteRecipes = cookbookViewModel.filteredRecipes
            .where((r) => r.isFavorite)
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardSize = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Favorite Recipes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (favoriteRecipes.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: cardSize,
                        height: cardSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/default_gallery_image.png',
                            width: cardSize,
                            height: cardSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'You have no favorite recipes yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else
                  CarouselSlider.builder(
                    itemCount: favoriteRecipes.length,
                    options: CarouselOptions(
                      height: cardSize + 146,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      viewportFraction: 1.0,
                      autoPlay: false,
                    ),
                    itemBuilder: (context, index, realIdx) {
                      final recipe = favoriteRecipes[index];
                      return SizedBox(
                        width: cardSize,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewRecipeScreen(
                                  recipe: recipe,
                                  cookbookId: userViewModel.cookbookId ?? '',
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: recipe.imageURL != null &&
                                        recipe.imageURL!.isNotEmpty
                                    ? Image.network(
                                        ImageUtil()
                                            .getFullImageUrl(recipe.imageURL),
                                        width: cardSize,
                                        height: cardSize,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: cardSize,
                                            height: cardSize,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                                Icons.image_not_supported,
                                                size: 60,
                                                color: Colors.grey),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: cardSize,
                                        height: cardSize,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image,
                                            size: 60, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  recipe.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 10),
                              RatingBarIndicator(
                                rating: (recipe.rating?.toDouble() ?? 0.0),
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: primaryColor),
                                itemCount: 5,
                                itemSize: 32.0,
                                unratedColor: Colors.grey[300],
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
