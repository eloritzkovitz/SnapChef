import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ingredient.dart';
import '../../widgets/display_recipe_widget.dart';
import '../../viewmodels/cookbook_viewmodel.dart';

class ViewRecipeScreen extends StatelessWidget {
  final String recipeId;
  final String cookbookId;
  final String recipe;
  final String imageUrl;
  final List<Ingredient> usedIngredients;

  const ViewRecipeScreen({
    super.key,
    required this.recipeId,
    required this.cookbookId,
    required this.recipe,
    required this.imageUrl,
    required this.usedIngredients,
  });

  Future<void> _deleteRecipe(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    final bool success = await cookbookViewModel.deleteRecipe(cookbookId, recipeId);

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
              if (value == 'delete') {
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (context) => [
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
          recipe: recipe,
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}