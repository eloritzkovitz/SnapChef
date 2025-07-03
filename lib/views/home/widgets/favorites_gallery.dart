import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../cookbook/view_recipe_screen.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../theme/colors.dart';
import '../../../utils/image_util.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../viewmodels/cookbook_viewmodel.dart';

class FavoritesGallery extends StatelessWidget {
  final CarouselSliderController? carouselController;

  const FavoritesGallery({super.key, this.carouselController});

  @override
  Widget build(BuildContext context) {
    final isOffline = Provider.of<ConnectivityProvider>(context).isOffline;

    return Consumer<CookbookViewModel>(
      builder: (context, cookbookViewModel, _) {
        final favoriteRecipes =
            cookbookViewModel.filteredItems.where((r) => r.isFavorite).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardSize = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOffline
                      ? 'Oops! You are offline...'
                      : 'Your Favorite Recipes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (isOffline)
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
                            'assets/images/default_offline_image.png',
                            width: cardSize,
                            height: cardSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'You are offline. Some functionality will be disabled.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else if (favoriteRecipes.isEmpty)
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
                else if (favoriteRecipes.length == 1)
                  // Show a single card without scroll/slider
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRecipeScreen(
                            recipe: favoriteRecipes[0],
                            cookbookId: Provider.of<UserViewModel>(
                                        context,
                                        listen: false)
                                    .cookbookId ??
                                '',
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
                          child: favoriteRecipes[0].imageURL != null &&
                                  favoriteRecipes[0].imageURL!.isNotEmpty
                              ? Image.network(
                                  ImageUtil()
                                      .getFullImageUrl(favoriteRecipes[0].imageURL),
                                  width: cardSize,
                                  height: cardSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: cardSize,
                                      height: cardSize,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported,
                                          size: 60, color: Colors.grey),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            favoriteRecipes[0].title,
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
                          rating: (favoriteRecipes[0].rating?.toDouble() ?? 0.0),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: primaryColor),
                          itemCount: 5,
                          itemSize: 32.0,
                          unratedColor: Colors.grey[300],
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                  )
                else
                  CarouselSlider.builder(
                    carouselController: carouselController,
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
                                  cookbookId: Provider.of<UserViewModel>(
                                              context,
                                              listen: false)
                                          .cookbookId ??
                                      '',
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