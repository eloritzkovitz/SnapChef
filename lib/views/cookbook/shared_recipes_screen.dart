import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_shared_recipe_screen.dart';
import './widgets/recipe_card.dart';
import '../../viewmodels/cookbook_viewmodel.dart';

class SharedRecipesScreen extends StatefulWidget {
  const SharedRecipesScreen({super.key});

  @override
  State<SharedRecipesScreen> createState() => _SharedRecipesScreenState();
}

class _SharedRecipesScreenState extends State<SharedRecipesScreen> {
  bool showSharedByMe = false;

  @override
  void initState() {
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    final cookbookViewModel = Provider.of<CookbookViewModel>(context);
    
    final sharedWithMe = cookbookViewModel.sharedWithMeRecipes ?? [];
    final sharedByMe = cookbookViewModel.sharedByMeRecipes ?? [];

    final recipesToShow = showSharedByMe ? sharedByMe : sharedWithMe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Shared with me'),
                  selected: !showSharedByMe,
                  onSelected: (selected) {
                    if (showSharedByMe) setState(() => showSharedByMe = false);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Shared by me'),
                  selected: showSharedByMe,
                  onSelected: (selected) {
                    if (!showSharedByMe) setState(() => showSharedByMe = true);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (cookbookViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (recipesToShow.isEmpty) {
                  return Center(
                    child: Text(
                      showSharedByMe
                          ? 'You have not shared any recipes with others.'
                          : 'No recipes have been shared with you.',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: recipesToShow.length,
                  itemBuilder: (context, index) {
                    final sharedRecipe = recipesToShow[index];
                    return RecipeCard(
                      key: ValueKey(sharedRecipe.recipe.id),
                      recipe: sharedRecipe.recipe,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewSharedRecipeScreen(
                              sharedRecipe: sharedRecipe,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}