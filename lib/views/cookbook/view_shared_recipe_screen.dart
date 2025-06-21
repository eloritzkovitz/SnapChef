import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../models/shared_recipe.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/shared_recipe_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/display_recipe_widget.dart';
import '../../widgets/snapchef_appbar.dart';

class ViewSharedRecipeScreen extends StatefulWidget {
  final SharedRecipe sharedRecipe;
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
  late String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.sharedRecipe.recipe.imageURL;

    // Fetch user info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final userId = widget.isSharedByMe
          ? widget.sharedRecipe.toUser
          : widget.sharedRecipe.fromUser;
      final currentUserId = userViewModel.user?.id ?? '';
      userViewModel.fetchUserInfo(
        userId: userId,
        currentUserId: currentUserId,
      );
    });
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
    final sharedBy = userViewModel.sharedUserName ??
        (widget.isSharedByMe
            ? widget.sharedRecipe.toUser
            : widget.sharedRecipe.fromUser);
    final sharedByProfilePic = userViewModel.sharedUserProfilePic;

    return BaseScreen(
        appBar: SnapChefAppBar(
          title: const Text(
            'Shared Recipe',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'add') {
                  _saveRecipeToCookbook(context);
                } else if (value == 'remove') {
                  await _removeSharedRecipe(context);
                }
              },
              itemBuilder: (context) => [
                if (!widget.isSharedByMe)
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
                    title:
                        Text(widget.isSharedByMe ? 'Stop Sharing' : 'Remove'),
                  ),
                ),
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
                // Shadow separator styled like bottom navigation
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (sharedByProfilePic != null &&
                                  sharedByProfilePic.isNotEmpty)
                              ? NetworkImage(ImageUtil()
                                  .getFullImageUrl(sharedByProfilePic))
                              : const AssetImage(
                                      'assets/images/default_profile.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.isSharedByMe
                              ? 'Shared with: $sharedBy'
                              : 'Shared by: $sharedBy',
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
