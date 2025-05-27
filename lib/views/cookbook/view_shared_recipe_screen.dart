import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../models/shared_recipe.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/display_recipe_widget.dart';

class ViewSharedRecipeScreen extends StatefulWidget {
  final SharedRecipe sharedRecipe;

  const ViewSharedRecipeScreen({
    super.key,
    required this.sharedRecipe,
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
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.sharedRecipe.recipe;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shared Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            tooltip: 'Save Recipe to Cookbook',
            onPressed: () => _saveRecipeToCookbook(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: DisplayRecipeWidget(
                recipeObject: recipe,
                imageUrl: ImageUtil().getFullImageUrl(_currentImageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Shared by: ${widget.sharedRecipe.fromUser}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
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
}