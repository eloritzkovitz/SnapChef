import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../widgets/display_recipe_widget.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import './widgets/edit_recipe_modal.dart';
import '../../utils/image_util.dart';

class ViewRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  final String cookbookId;

  const ViewRecipeScreen({
    super.key,
    required this.recipe,
    required this.cookbookId,
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

  // Show the edit recipe modal
  Future<void> _showEditRecipeDialog(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => EditRecipeModal(
        recipeObj: _recipe,
        onSave: ({
          required String title,
          required String description,
          required String mealType,
          required String cuisineType,
          required String difficulty,
          required int prepTime,
          required int cookingTime,
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
            ingredients: _recipe.ingredients,
            instructions: _recipe.instructions,
            imageURL: _recipe.imageURL,
            rating: _recipe.rating,
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
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recipe updated successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update recipe')),
            );
          }
        },
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
      final updatedRecipe = cookbookViewModel.filteredRecipes
          .firstWhere((r) => r.id == _recipe.id, orElse: () => _recipe);
      setState(() {
        _recipe = updatedRecipe;
      });
    }

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

    if (confirm == true) {
      _deleteRecipe(context);
    }
  }

  // Delete a recipe from the cookbook
  Future<void> _deleteRecipe(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    final bool success =
        await cookbookViewModel.deleteRecipe(widget.cookbookId, _recipe.id);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditRecipeDialog(context);
              }
              if (value == 'regenerate_image') {
                _regenerateRecipeImage(context);
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
                    Text('Edit Recipe'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'regenerate_image',
                child: Row(
                  children: const [
                    Icon(Icons.image, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Regenerate Image'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Delete Recipe'),
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
        ),
      ),
    );
  }
}
