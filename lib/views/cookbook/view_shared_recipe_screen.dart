import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/shared_recipe.dart';
import '../../models/recipe.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/shared_recipe_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/display_recipe_widget.dart';
import '../../widgets/snapchef_appbar.dart';

class ViewSharedRecipeScreen extends StatefulWidget {
  final dynamic sharedRecipe;
  final bool isSharedByMe;

  const ViewSharedRecipeScreen({
    super.key,
    required this.sharedRecipe,
    this.isSharedByMe = false,
  });

  @override
  State<ViewSharedRecipeScreen> createState() => _ViewSharedRecipeScreenState();
}

class _ViewSharedRecipeScreenState extends State<ViewSharedRecipeScreen> {
  late final Recipe recipe;
  late final List<String> sharedWithUserIds;
  late String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.isSharedByMe) {
      final grouped = widget.sharedRecipe as GroupedSharedRecipe;
      recipe = grouped.recipe;
      sharedWithUserIds = grouped.sharedWithUserIds;
      _currentImageUrl = recipe.imageURL;
    } else {
      final shared = widget.sharedRecipe as SharedRecipe;
      recipe = shared.recipe;
      sharedWithUserIds = [shared.fromUser];
      _currentImageUrl = recipe.imageURL;
    }

    // Fetch user info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      String userId;
      if (widget.isSharedByMe) {
        // Use the first user in the list for initial fetch, or fetch all if you want
        userId = sharedWithUserIds.isNotEmpty ? sharedWithUserIds.first : '';
      } else {
        userId = (widget.sharedRecipe as SharedRecipe).fromUser;
      }
      final currentUserId = userViewModel.user?.id ?? '';
      if (userId.isNotEmpty) {
        userViewModel.fetchUserInfo(
          userId: userId,
          currentUserId: currentUserId,
        );
      }
    });
  }

  // Add this helper to get user names from IDs (replace with your actual logic)
  Future<String> _getUserName(BuildContext context, String userId) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    // If you have a cache/map, use it; otherwise, fetch
    await userViewModel.fetchUserInfo(
        userId: userId, currentUserId: userViewModel.user?.id ?? '');
    return userViewModel.sharedUserName ?? userId;
  }

// Show dialog with users the recipe is shared with
  void _showSharedWithDialog(BuildContext context) async {
    final sharedRecipeViewModel =
        Provider.of<SharedRecipeViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final sharedByMeRecipes = sharedRecipeViewModel.sharedByMeRecipes ?? [];

    // Fetch all user names and profile pics in parallel
    final userInfos = await Future.wait(sharedWithUserIds.map((id) async {
      await userViewModel.fetchUserInfo(
          userId: id, currentUserId: userViewModel.user?.id ?? '');
      return {
        'name': userViewModel.sharedUserName ?? id,
        'profilePic': userViewModel.sharedUserProfilePic
      };
    }));

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Shared With'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sharedWithUserIds.length,
              itemBuilder: (context, index) {
                final userId = sharedWithUserIds[index];
                final userName = userInfos[index]['name'] as String;
                final profilePic = userInfos[index]['profilePic'];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (profilePic != null &&
                            profilePic.isNotEmpty)
                        ? NetworkImage(ImageUtil().getFullImageUrl(profilePic))
                        : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                  ),
                  title: Text(userName),
                  trailing: widget.isSharedByMe
                      ? TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            // Find the SharedRecipe for this user and recipe
                            final sharedRecipe = sharedByMeRecipes.firstWhere(
                              (r) =>
                                  r.recipe.id == recipe.id &&
                                  r.toUser == userId,
                            );
                            final user = Provider.of<UserViewModel>(context,
                                listen: false);
                            final String cookbookId = user.cookbookId ?? '';
                            await sharedRecipeViewModel.removeSharedRecipe(
                              cookbookId,
                              sharedRecipe.id,
                              isSharedByMe: true,
                            );
                            // Remove the user from the local list
                            sharedWithUserIds.remove(userId);
                            if (sharedWithUserIds.isEmpty && context.mounted) {
                              // No more users, pop back to the shared recipes screen and trigger refresh
                              Navigator.of(context).pop(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Stopped sharing with $userName')),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Stopped sharing with $userName')),
                              );
                              setState(() {});
                            }
                          },
                          child: const Text('Stop Sharing'),
                        )
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Save the shared recipe to the user's cookbook
  void _saveRecipeToCookbook(BuildContext context) {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    final user = Provider.of<UserViewModel>(context, listen: false);
    final String cookbookId = user.cookbookId ?? '';

    final recipe = widget.sharedRecipe.recipe;

    // Save the recipe to the cookbook with source "shared"
    cookbookViewModel.addRecipeToCookbook(
      cookbookId: cookbookId,
      title: recipe.title,
      description: recipe.description,
      mealType: recipe.mealType,
      cuisineType: recipe.cuisineType,
      difficulty: recipe.difficulty,
      cookingTime: recipe.cookingTime,
      prepTime: recipe.prepTime,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageURL: recipe.imageURL,
      rating: recipe.rating,
      source: RecipeSource.shared,
      raw: recipe.instructions.join('\n'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved to cookbook!')),
    );
  }

  // Remove the shared recipe
  Future<void> _removeSharedRecipe(BuildContext context) async {
    final user = Provider.of<UserViewModel>(context, listen: false);
    final String cookbookId = user.cookbookId ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            widget.isSharedByMe ? 'Stop Sharing?' : 'Remove Shared Recipe?'),
        content: Text(widget.isSharedByMe
            ? 'Do you want to stop sharing this recipe with this user?'
            : 'Do you want to remove this shared recipe from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(widget.isSharedByMe ? 'Stop Sharing' : 'Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (context.mounted) {
        await Provider.of<SharedRecipeViewModel>(context, listen: false)
            .removeSharedRecipe(cookbookId, widget.sharedRecipe.id,
                isSharedByMe: widget.isSharedByMe);
      }
      if (context.mounted) {
        Navigator.of(context).pop(true); // Go back after removal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isSharedByMe
                ? 'Stopped sharing recipe.'
                : 'Removed shared recipe.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove shared recipe')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.sharedRecipe.recipe;
    final userViewModel = Provider.of<UserViewModel>(context);

    // Widget for the summary text with the first user's name
    Widget sharedWithSummary() {
      if (widget.isSharedByMe && sharedWithUserIds.isNotEmpty) {
        final firstUserId = sharedWithUserIds.first;
        final others = sharedWithUserIds.length - 1;
        return FutureBuilder<String>(
          future: _getUserName(context, firstUserId),
          builder: (context, snapshot) {
            final firstName = snapshot.data ?? firstUserId;
            if (others > 0) {
              return Text(
                'Shared with: $firstName and $others other(s)',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              );
            } else {
              return Text(
                'Shared with: $firstName',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              );
            }
          },
        );
      } else {
        // Not shared by me, show who shared it
        final sharedBy = userViewModel.sharedUserName ??
            (widget.sharedRecipe as SharedRecipe).fromUser;
        return Text(
          'Shared by: $sharedBy',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        );
      }
    }

    return BaseScreen(
      appBar: SnapChefAppBar(
        title: const Text(
          'Shared Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (!widget.isSharedByMe)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'add') {
                  _saveRecipeToCookbook(context);
                } else if (value == 'remove') {
                  await _removeSharedRecipe(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'add',
                  child: ListTile(
                    leading: Icon(Icons.bookmark_add),
                    title: Text('Add to Cookbook'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'remove',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Remove'),
                  ),
                )
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: DisplayRecipeWidget(
                  recipeObject: recipe,
                  imageUrl: ImageUtil().getFullImageUrl(_currentImageUrl),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                (userViewModel.sharedUserProfilePic != null &&
                                        userViewModel
                                            .sharedUserProfilePic!.isNotEmpty)
                                    ? NetworkImage(ImageUtil().getFullImageUrl(
                                        userViewModel.sharedUserProfilePic!))
                                    : const AssetImage(
                                            'assets/images/default_profile.png')
                                        as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          sharedWithSummary(),
                        ],
                      ),
                      if (widget.isSharedByMe)
                        Positioned(
                          right: 16,
                          child: GestureDetector(
                            onTap: () => _showSharedWithDialog(context),
                            child: const Icon(Icons.settings,
                                size: 24, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
