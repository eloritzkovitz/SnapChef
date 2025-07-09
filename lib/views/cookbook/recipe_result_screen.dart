import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../utils/image_util.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../widgets/display_recipe_widget.dart';

class RecipeResultScreen extends StatefulWidget {
  final String recipe;
  final String imageUrl;
  final List<Ingredient> usedIngredients;
  final String? mealType;
  final String? cuisineType;
  final String? difficulty;
  final int? cookingTime;
  final int? prepTime;
  final Widget Function(String imageUrl)? imageBuilder;

  const RecipeResultScreen({
    super.key,
    required this.recipe,
    required this.imageUrl,
    required this.usedIngredients,
    this.mealType,
    this.cuisineType,
    this.difficulty,
    this.cookingTime,
    this.prepTime,
    this.imageBuilder,
  });

  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen> {
  late String _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate Image',
            onPressed: () => _regenerateImage(context),
          ),
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
                recipeString: widget.recipe,
                imageUrl: ImageUtil().getFullImageUrl(_currentImageUrl),
                imageBuilder: widget.imageBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _regenerateImage(BuildContext context) async {
    final recipeViewModel =
        Provider.of<RecipeViewModel>(context, listen: false);

    final previousImageUrl = _currentImageUrl;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await recipeViewModel.regenerateRecipeImage(
      mealType: widget.mealType,
      cuisine: widget.cuisineType,
      difficulty: widget.difficulty,
      cookingTime: widget.cookingTime,
      prepTime: widget.prepTime,
      preferences: null,
    );

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      // Update the image from the viewmodel
      setState(() {
        _currentImageUrl = recipeViewModel.imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recipe image regenerated!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _currentImageUrl = previousImageUrl;
                recipeViewModel.imageUrl = previousImageUrl;
              });
            },
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  // Save the recipe to the cookbook
  void _saveRecipeToCookbook(BuildContext context) {
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    // Get the cookbook ID dynamically from the user object
    final user = Provider.of<UserViewModel>(context, listen: false);
    final String cookbookId = user.cookbookId ?? '';

    // Create a Recipe object to save
    final newRecipe = Recipe(
      id: DateTime.now().toString(),
      title: 'Generated Recipe',
      description: 'A recipe generated based on your ingredients.',
      mealType: widget.mealType ?? '',
      cuisineType: widget.cuisineType ?? '',
      difficulty: widget.difficulty ?? '',
      cookingTime: widget.cookingTime ?? 0,
      prepTime: widget.prepTime ?? 0,
      ingredients: widget.usedIngredients,
      instructions: widget.recipe.split('\n'),
      imageURL: _currentImageUrl,
      rating: null,
      source: RecipeSource.ai,
    );

    // Save the recipe to the cookbook
    cookbookViewModel.addRecipeToCookbook(
      cookbookId: cookbookId,
      title: newRecipe.title,
      description: newRecipe.description,
      mealType: newRecipe.mealType,
      cuisineType: newRecipe.cuisineType,
      difficulty: newRecipe.difficulty,
      cookingTime: newRecipe.cookingTime,
      prepTime: newRecipe.prepTime,
      ingredients: newRecipe.ingredients,
      instructions: newRecipe.instructions,
      imageURL: newRecipe.imageURL,
      rating: newRecipe.rating,
      source: newRecipe.source,
      raw: newRecipe.instructions.join('\n'),
    );

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved to cookbook!')),
    );
  }
}
