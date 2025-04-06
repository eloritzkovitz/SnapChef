import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../services/ingredient_service.dart';
import './widgets/ingredient_card.dart';
import './ingredient_search_delegate.dart';
import './widgets/action_button.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final fridgeId =
        Provider.of<AuthViewModel>(context, listen: false).fridgeId;
    final ingredientService = IngredientService();

    // Check if the user is null
    if (authViewModel.user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Failed to load user data',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Fridge', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [          
          // Sorting Dropdown
          PopupMenuButton<String>(
            onSelected: (value) {
              Provider.of<FridgeViewModel>(context, listen: false)
                  .sortIngredients(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Name', child: Text('Sort by Name')),
              const PopupMenuItem(
                  value: 'Quantity', child: Text('Sort by Quantity')),
            ],
            icon: const Icon(Icons.sort, color: Colors.black),
          ),
          // Filtering Dropdown
          PopupMenuButton<String>(
            onSelected: (value) {
              Provider.of<FridgeViewModel>(context, listen: false)
                  .filterByCategory(value == 'All' ? null : value);
            },
            itemBuilder: (context) {
              final categories =
                  Provider.of<FridgeViewModel>(context, listen: false)
                      .getCategories();
              return [
                const PopupMenuItem(
                    value: 'All', child: Text('All Categories')),
                ...categories.map((category) =>
                    PopupMenuItem(value: category, child: Text(category))),
              ];
            },
            icon: const Icon(Icons.filter_list, color: Colors.black),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: IngredientSearchDelegate(
                    ingredientService: ingredientService),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<FridgeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              // Show loading indicator while fetching ingredients
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.ingredients.isEmpty) {
              // Show "No available ingredients" message if the fridge is empty
              return const Center(
                child: Text(
                  'No available ingredients',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // Show the grid of ingredients
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: viewModel.filteredIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = viewModel.filteredIngredients[index];
                return IngredientCard(
                  ingredient: ingredient,
                  onIncrease: () => viewModel.increaseCount(index, fridgeId!),
                  onDecrease: () => viewModel.decreaseCount(index, fridgeId!),
                  onDelete: () =>
                      viewModel.deleteItem(fridgeId!, ingredient.id),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: ActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
