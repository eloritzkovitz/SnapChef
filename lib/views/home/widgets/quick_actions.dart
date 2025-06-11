import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../providers/connectivity_provider.dart';
import '../../fridge/ingredient_search_delegate.dart';
import '../../cookbook/generate_recipe_screen.dart';
import '../../cookbook/add_recipe_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Add ingredients action
          ActionChip(
            avatar: const Icon(Icons.search, color: primaryColor, size: 20),
            label: const Text('Add Ingredients'),
            onPressed: () {
              showSearch(
                context: context,
                delegate: IngredientSearchDelegate(),
              );
            },
            backgroundColor: Colors.grey[100],
            labelStyle: const TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 12),
          // Generate recipe action
          ActionChip(
            avatar:
                const Icon(Icons.auto_awesome, color: primaryColor, size: 20),
            label: const Text('Generate Recipe'),
            onPressed: isOffline
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenerateRecipeScreen(),
                      ),
                    );
                  },
            backgroundColor: Colors.grey[100],
            labelStyle: const TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 12),
          // Add recipe action
          ActionChip(
            avatar: const Icon(Icons.create_outlined, color: primaryColor, size: 20),
            label: const Text('Add Recipe'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRecipeScreen(
                    cookbookId: userViewModel.cookbookId ?? '',
                  ),
                ),
              );
            },
            backgroundColor: Colors.grey[100],
            labelStyle: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
