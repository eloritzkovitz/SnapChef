import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import 'recipe_search_delegate.dart';
import './widgets/recipe_card.dart';
import 'view_recipe_screen.dart';
import '../../main.dart';
import './widgets/cookbook_filter_sort_sheet.dart';

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> with RouteAware {
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
      appBar: AppBar(
        title: const Text('Cookbook',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
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
          // Search Button
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(),
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<CookbookViewModel>(
        builder: (context, cookbookViewModel, child) {
          if (cookbookViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cookbookViewModel.filteredRecipes.isEmpty) {
            return const Center(
              child: Text(
                'No recipes in your cookbook.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: cookbookViewModel.filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = cookbookViewModel.filteredRecipes[index];
              return RecipeCard(
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
    );
  }
}
