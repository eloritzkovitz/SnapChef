import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../widgets/display_recipe_widget.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import './widgets/edit_recipe_modal.dart';

class ViewRecipeScreen extends StatelessWidget {
  final Recipe recipe;
  final String cookbookId;

  const ViewRecipeScreen({
    super.key,
    required this.recipe,
    required this.cookbookId,
  });

  // Show the edit recipe modal
  Future<void> _showEditRecipeDialog(BuildContext context) async {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => EditRecipeModal(
        recipeObj: recipe,
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
            cookbookId: cookbookId,
            recipeId: recipe.id,
            title: title,
            description: description,
            mealType: mealType,
            cuisineType: cuisineType,
            difficulty: difficulty,
            prepTime: prepTime,
            cookingTime: cookingTime,           
            ingredients: recipe.ingredients,
            instructions: recipe.instructions,
            imageURL: recipe.imageURL,
            rating: recipe.rating,
          );
          if (success) {
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

    final bool success = await cookbookViewModel.deleteRecipe(cookbookId, recipe.id);

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
          recipeObject: recipe,
          imageUrl: recipe.imageURL ?? '',
          cookbookId: cookbookId,
        ),
      ),
    );
  }
}