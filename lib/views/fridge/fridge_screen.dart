import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../services/ingredient_service.dart';
import './widgets/ingredient_card.dart';
import './ingredient_search_delegate.dart';
import './widgets/action_button.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  bool isListView = false; // State variable to toggle between views

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final fridgeId = authViewModel.fridgeId;
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
          // Toggle Button for View Mode
          IconButton(
            color: Colors.black,
            icon: Icon(isListView ? Icons.view_list : Icons.grid_view),
            tooltip: isListView ? 'Switch to Grid View' : 'Switch to List View',
            onPressed: () {
              setState(() {
                isListView = !isListView; // Toggle the view mode
              });
            },
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

            if (viewModel.filteredIngredients.isEmpty) {
              // Show "No available ingredients" message if the fridge is empty
              return const Center(
                child: Text(
                  'No available ingredients',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // Render GridView or ListView based on the selected view mode
            return isListView
                ? ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: viewModel.filteredIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = viewModel.filteredIngredients[index];
                      return ListTile(
                        leading: ingredient.imageURL.isNotEmpty
                            ? Image.network(
                                ingredient.imageURL,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(ingredient.name),
                        subtitle: Text('Category: ${ingredient.category}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrease Quantity Button
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () {
                                if (ingredient.count > 1) {
                                  viewModel.decreaseCount(index, fridgeId!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Quantity cannot be less than 1')),
                                  );
                                }
                              },
                            ),
                            // Quantity Display
                            Text(
                              '${ingredient.count}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            // Increase Quantity Button
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.green),
                              onPressed: () {
                                viewModel.increaseCount(index, fridgeId!);
                              },
                            ),
                            // Delete Button
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, ingredient, fridgeId!, viewModel);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        onIncrease: () =>
                            viewModel.increaseCount(index, fridgeId!),
                        onDecrease: () =>
                            viewModel.decreaseCount(index, fridgeId!),
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

  void _showDeleteConfirmationDialog(BuildContext context, dynamic ingredient,
      String fridgeId, FridgeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Ingredient'),
          content: const Text('Are you sure you want to delete this ingredient?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteItem(fridgeId, ingredient.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${ingredient.name} has been deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
