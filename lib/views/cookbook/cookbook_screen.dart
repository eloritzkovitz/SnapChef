import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'add_recipe_screen.dart';
import 'recipe_search_delegate.dart';
import 'shared_recipes_screen.dart';
import 'view_recipe_screen.dart';
import './widgets/cookbook_filter_sort_sheet.dart';
import './widgets/recipe_card.dart';
import '../../widgets/snapchef_appbar.dart';
import '../../main.dart';
import '../../theme/colors.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/cookbook_viewmodel.dart';

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> with RouteAware {
  final String serverUrl = dotenv.env['SERVER_IP'] ?? '';
    bool showOnlyFavorites = false;

  String getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) return imageUrl;
    return '$serverUrl$imageUrl';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    // Schedule fetch after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecipes();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Called when returning to this screen
    _fetchRecipes();
  }

  void _fetchRecipes() {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);
    final cookbookId = userViewModel.cookbookId;
    if (cookbookId != null &&
        cookbookId.isNotEmpty &&
        cookbookId != 'No Cookbook ID') {
      cookbookViewModel.fetchCookbookRecipes(cookbookId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SnapChefAppBar(
        title: const Text('Cookbook',
            style: TextStyle(fontWeight: FontWeight.bold)),           
        actions: [
          // Filter & Sort button
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            tooltip: 'Filter & Sort',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                isScrollControlled: true,
                builder: (context) => CookbookFilterSortSheet(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: showOnlyFavorites ? Colors.black : Colors.black,
            ),
            tooltip: showOnlyFavorites ? 'Show All Recipes' : 'Show Favorites Only',
            onPressed: () {
              setState(() {
                showOnlyFavorites = !showOnlyFavorites;
              });
            },
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(),
              );
            },
          ),
          // Shared recipes button
          IconButton(
            icon: const Icon(Icons.people_alt_outlined, color: Colors.black),
            tooltip: 'Shared Recipes',
            onPressed: () async {
              final user =
                  Provider.of<UserViewModel>(context, listen: false).user;
              await Provider.of<CookbookViewModel>(context, listen: false)
                  .fetchSharedRecipes(user?.cookbookId ?? '');
              if (context.mounted) {
                Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SharedRecipesScreen()),
              );
              }
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<CookbookViewModel>(
        builder: (context, cookbookViewModel, child) {
          final recipes = showOnlyFavorites
              ? cookbookViewModel.filteredRecipes
                  .where((r) => r.isFavorite)
                  .toList()
              : cookbookViewModel.filteredRecipes;

          if (cookbookViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (recipes.isEmpty) {
            return Center(
              child: Text(
                showOnlyFavorites
                    ? 'No favorite recipes.'
                    : 'No recipes in your cookbook.',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: recipes.length,
            onReorder: (oldIndex, newIndex) async {
              await cookbookViewModel.reorderRecipe(
                oldIndex,
                newIndex,
                Provider.of<UserViewModel>(context, listen: false).cookbookId ??
                    '',
              );
            },
            proxyDecorator: (child, index, animation) {
              return Material(
                color: Colors.transparent,
                elevation: 0,
                type: MaterialType.transparency,
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                key: ValueKey(recipe.id),
                recipe: recipe,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewRecipeScreen(
                        recipe: recipe,
                        cookbookId:
                            Provider.of<UserViewModel>(context, listen: false)
                                    .cookbookId ??
                                '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          final cookbookId =
              Provider.of<UserViewModel>(context, listen: false).cookbookId ??
                  '';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipeScreen(cookbookId: cookbookId),
            ),
          );
        },
        tooltip: 'Add Manual Recipe',
        child: const Icon(Icons.add),
      ),
    );
  }
}
