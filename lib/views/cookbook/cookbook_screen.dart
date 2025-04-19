import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import 'view_recipe_screen.dart';

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final cookbookViewModel = Provider.of<CookbookViewModel>(context, listen: false);

      // Ensure the cookbookId is not null
      final cookbookId = authViewModel.cookbookId;
      if (cookbookId != null && cookbookId.isNotEmpty) {
        cookbookViewModel.fetchCookbookRecipes(cookbookId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookbook', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<CookbookViewModel>(
        builder: (context, cookbookViewModel, child) {
          if (cookbookViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cookbookViewModel.recipes.isEmpty) {
            return const Center(
              child: Text(
                'No recipes in your cookbook.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: cookbookViewModel.recipes.length,
            itemBuilder: (context, index) {
              final recipe = cookbookViewModel.recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: recipe.imageURL != null && recipe.imageURL!.isNotEmpty
                      ? Image.network(
                          recipe.imageURL!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        )
                      : const Icon(Icons.image),
                  title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(recipe.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewRecipeScreen(
                          recipe: recipe.instructions.join('\n'),
                          imageUrl: recipe.imageURL ?? '',
                          usedIngredients: recipe.ingredients,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}