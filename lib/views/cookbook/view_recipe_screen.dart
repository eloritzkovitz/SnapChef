import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/views/cookbook/edit_recipe_screen.dart';
import '../../models/notifications/share_notification.dart';
import '../../models/recipe.dart';
import '../../models/user.dart';
import '../../providers/connectivity_provider.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/display_recipe_widget.dart';
import '../../widgets/snapchef_appbar.dart';

class ViewRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  final String cookbookId;
  final Widget Function(String imageUrl)? imageBuilder;

  const ViewRecipeScreen({
    super.key,
    required this.recipe,
    required this.cookbookId,
    this.imageBuilder,
  });

  @override
  State<ViewRecipeScreen> createState() => _ViewRecipeScreenState();
}

class _ViewRecipeScreenState extends State<ViewRecipeScreen> {
  late Recipe _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  // Show the edit recipe screen
  Future<void> _showEditRecipeScreen(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipeScreen(
          recipeObj: _recipe,
          onSave: ({
            required String title,
            required String description,
            required String mealType,
            required String cuisineType,
            required String difficulty,
            required int prepTime,
            required int cookingTime,
            required List<String> instructions,
            required List<Ingredient> ingredients,
            required String imageURL,
            required double? rating,
            required String raw,
          }) async {
            final success = await cookbookViewModel.updateRecipe(
              cookbookId: widget.cookbookId,
              recipeId: _recipe.id,
              title: title,
              description: description,
              mealType: mealType,
              cuisineType: cuisineType,
              difficulty: difficulty,
              prepTime: prepTime,
              cookingTime: cookingTime,
              ingredients: ingredients,
              instructions: instructions,
              imageURL: imageURL,
              rating: rating,
            );
            if (success) {
              setState(() {
                _recipe = _recipe.copyWith(
                  title: title,
                  description: description,
                  mealType: mealType,
                  cuisineType: cuisineType,
                  difficulty: difficulty,
                  prepTime: prepTime,
                  cookingTime: cookingTime,
                  instructions: instructions,
                  ingredients: ingredients,
                  imageURL: imageURL,
                  rating: rating,
                );
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe updated successfully')),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update recipe')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  // Regenerate the recipe image
  Future<void> _regenerateRecipeImage(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    final previousImageUrl = _recipe.imageURL;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Prepare payload
    final payload = {
      'title': _recipe.title,
      'description': _recipe.description,
      'mealType': _recipe.mealType,
      'cuisineType': _recipe.cuisineType,
      'difficulty': _recipe.difficulty,
      'prepTime': _recipe.prepTime,
      'cookingTime': _recipe.cookingTime,
      'ingredients': _recipe.ingredients.map((i) => i.toJson()).toList(),
      'instructions': _recipe.instructions,
      'rating': _recipe.rating,
    };

    final success = await cookbookViewModel.regenerateRecipeImage(
      cookbookId: widget.cookbookId,
      recipeId: _recipe.id,
      payload: payload,
    );

    // Get the updated recipe from the viewmodel (if needed)
    if (success) {
      final updatedRecipe = cookbookViewModel.filteredItems
          .firstWhere((r) => r.id == _recipe.id, orElse: () => _recipe);
      setState(() {
        _recipe = updatedRecipe;
      });
    }

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Hide loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recipe image regenerated!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              // Restore the previous image URL
              final cookbookViewModel =
                  Provider.of<CookbookViewModel>(context, listen: false);
              await cookbookViewModel.updateRecipe(
                cookbookId: widget.cookbookId,
                recipeId: _recipe.id,
                title: _recipe.title,
                description: _recipe.description,
                mealType: _recipe.mealType,
                cuisineType: _recipe.cuisineType,
                difficulty: _recipe.difficulty,
                prepTime: _recipe.prepTime,
                cookingTime: _recipe.cookingTime,
                ingredients: _recipe.ingredients,
                instructions: _recipe.instructions,
                imageURL: previousImageUrl,
                rating: _recipe.rating,
              );
              // Update local state
              setState(() {
                _recipe = _recipe.copyWith(imageURL: previousImageUrl);
              });
            },
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  // Toggle favorite status for the recipe
  Future<void> _toggleFavorite(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);
    final success = await cookbookViewModel.toggleRecipeFavoriteStatus(
      widget.cookbookId,
      _recipe.id,
    );
    if (success) {
      setState(() {
        _recipe = _recipe.copyWith(isFavorite: !_recipe.isFavorite);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_recipe.isFavorite
                ? 'Recipe added to favorites'
                : 'Recipe removed from favorites'),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to toggle favorite')),
        );
      }
    }
  }

  // Show share recipe dialog to select a friend
  Future<void> _showShareWithFriendDialog(BuildContext parentContext) async {
    final userViewModel =
        Provider.of<UserViewModel>(parentContext, listen: false);
    List<User> friends = await userViewModel.getFriends();
    List<User> filteredFriends = List.from(friends);

    if (context.mounted) {
      showModalBottomSheet(
        context: parentContext,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              void filterFriends(String query) {
                setModalState(() {
                  filteredFriends = friends
                      .where((friend) => friend.fullName
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                });
              }

              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SizedBox(
                  height: 400,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search friends...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          onChanged: filterFriends,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredFriends.isEmpty
                            ? const Center(child: Text('No friends found'))
                            : ListView.builder(
                                itemCount: filteredFriends.length,
                                itemBuilder: (context, index) {
                                  final friend = filteredFriends[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: (friend.profilePicture !=
                                                  null &&
                                              friend.profilePicture!.isNotEmpty)
                                          ? NetworkImage(ImageUtil()
                                              .getFullImageUrl(
                                                  friend.profilePicture!))
                                          : const AssetImage(
                                                  'assets/images/default_profile.png')
                                              as ImageProvider,
                                    ),
                                    title: Text(friend.fullName),
                                    onTap: () async {
                                      // Show confirmation dialog before sharing
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Share Recipe'),
                                          content: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                backgroundImage: (friend
                                                                .profilePicture !=
                                                            null &&
                                                        friend.profilePicture!
                                                            .isNotEmpty)
                                                    ? NetworkImage(ImageUtil()
                                                        .getFullImageUrl(friend
                                                            .profilePicture!))
                                                    : const AssetImage(
                                                            'assets/images/default_profile.png')
                                                        as ImageProvider,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                    'Share this recipe with ${friend.fullName}?'),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Share'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true &&
                                          context.mounted) {
                                        Navigator.pop(
                                            context); // Close the bottom sheet
                                        await _shareRecipe(
                                            parentContext, friend.id);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  // Share the recipe with a friend
  Future<void> _shareRecipe(BuildContext context, String friendId) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);
    final notificationsViewModel =
        Provider.of<NotificationsViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    try {
      await cookbookViewModel.shareRecipeWithFriend(
        cookbookId: widget.cookbookId,
        recipeId: _recipe.id,
        friendId: friendId,
      );

      // Add notification for sharing
      await notificationsViewModel.addNotification(
        ShareNotification(
          id: await notificationsViewModel.generateUniqueNotificationId(),
          title:
              '${userViewModel.user?.fullName ?? "Someone"} shared a recipe with you',
          body:
              '${userViewModel.user?.fullName ?? "Someone"} is now sharing "${_recipe.title}" with you.',
          scheduledTime: DateTime.now(),
          friendName: userViewModel.user?.fullName ?? "",
          recipeName: _recipe.title,
          senderId: userViewModel.user?.id ?? '',
          recipientId: friendId,
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe shared successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share recipe: $e')),
        );
      }
    }
  }

  // Show a confirmation dialog before deleting the recipe
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      _deleteRecipe(context);
    }
  }

  // Delete a recipe from the cookbook
  Future<void> _deleteRecipe(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    final bool success =
        await cookbookViewModel.deleteRecipe(widget.cookbookId, _recipe.id);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted successfully')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete recipe')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = Provider.of<ConnectivityProvider>(context).isOffline;

    return BaseScreen(
      appBar: SnapChefAppBar(
        title: const Text(
          'Recipe Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditRecipeScreen(context);
              }
              if (value == 'regenerate_image' && !isOffline) {
                _regenerateRecipeImage(context);
              }
              if (value == 'toggle_favorite') {
                _toggleFavorite(context);
              }
              if (value == 'share' && !isOffline) {
                _showShareWithFriendDialog(context);
              }
              if (value == 'delete') {
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.black),
                    SizedBox(width: 8),
                    Flexible(child: Text('Edit Recipe')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'regenerate_image',
                enabled: !isOffline,
                child: Row(
                  children: [
                    Icon(Icons.image,
                        color: isOffline ? Colors.grey : Colors.black),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Regenerate Image',
                        style: TextStyle(
                          color: isOffline ? Colors.grey : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_favorite',
                child: Row(
                  children: [
                    Icon(
                      _recipe.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(
                            _recipe.isFavorite ? 'Unfavorite' : 'Favorite')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                enabled: !isOffline,
                child: Row(
                  children: [
                    Icon(Icons.share,
                        color: isOffline ? Colors.grey : Colors.black),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Share Recipe',
                        style: TextStyle(
                          color: isOffline ? Colors.grey : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.black),
                    SizedBox(width: 8),
                    Flexible(child: Text('Delete Recipe')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DisplayRecipeWidget(
          recipeObject: _recipe,
          imageUrl: ImageUtil().getFullImageUrl(_recipe.imageURL),
          cookbookId: widget.cookbookId,
          imageBuilder: widget.imageBuilder,
        ),
      ),
    );
  }
}
