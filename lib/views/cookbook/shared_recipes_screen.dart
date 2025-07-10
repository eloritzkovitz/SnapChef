import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/shared_recipe.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import '../../viewmodels/shared_recipe_viewmodel.dart';
import '../../widgets/base_screen.dart';
import 'view_shared_recipe_screen.dart';
import './widgets/recipe_card.dart';
import '../../widgets/snapchef_appbar.dart';
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
    final sharedRecipeViewModel = Provider.of<SharedRecipeViewModel>(context);

    final sharedWithMe = sharedRecipeViewModel.sharedWithMeRecipes ?? [];
    //final sharedByMe = sharedRecipeViewModel.sharedByMeRecipes ?? [];
    final groupedSharedByMe = sharedRecipeViewModel.groupedSharedByMeRecipes;

    final recipesToShow = showSharedByMe ? groupedSharedByMe : sharedWithMe;

    return BaseScreen(
      appBar: SnapChefAppBar(
        title: const Text('Shared Recipes',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
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
                    if (showSharedByMe) {
                      final grouped =
                          recipesToShow[index] as GroupedSharedRecipe;
                      return RecipeCard(
                        key: ValueKey(grouped.recipe.id),
                        recipe: grouped.recipe,
                        onTap: () {
                          final result = Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewSharedRecipeScreen(
                                sharedRecipe: grouped,
                                isSharedByMe: true,
                              ),
                            ),
                          );
                          // ignore: unrelated_type_equality_checks
                          if (result == true) {
                            final userViewModel = Provider.of<UserViewModel>(
                                context,
                                listen: false);
                            final cookbookId = userViewModel.cookbookId ?? '';
                            final userId = userViewModel.user?.id ?? '';
                            setState(() {
                              sharedRecipeViewModel.fetchSharedRecipes(
                                cookbookId,
                                userId,
                              );
                            });
                          }
                        },
                      );
                    } else {
                      final sharedRecipe = recipesToShow[index] as SharedRecipe;
                      return RecipeCard(
                        key: ValueKey(sharedRecipe.recipe.id),
                        recipe: sharedRecipe.recipe,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewSharedRecipeScreen(
                                sharedRecipe: sharedRecipe,
                                isSharedByMe: false,
                              ),
                            ),
                          );
                        },
                      );
                    }
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
