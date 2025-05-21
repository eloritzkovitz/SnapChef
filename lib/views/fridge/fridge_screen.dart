import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../services/ingredient_service.dart';
import './fridge_list_view.dart';
import './fridge_grid_view.dart';
import './ingredient_search_delegate.dart';
import './widgets/action_button.dart';
import './widgets/expiry_alert.dart';
import 'groceries_list.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  bool isListView = false; // State variable to toggle between views

  void _openGroceriesList(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header with Close Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Groceries',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // The groceries list
                  Expanded(
                    child: GroceriesList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final fridgeId = userViewModel.fridgeId;
    final ingredientService = IngredientService();

    // Check if the user is null
    if (userViewModel.user == null) {
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
          // Search Button
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
          // Grocery List Button
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            tooltip: 'Manage Groceries',
            onPressed: () {
              _openGroceriesList(context);
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
                ? FridgeListView(
                    ingredients: viewModel.filteredIngredients,
                    fridgeId: fridgeId!,
                    viewModel: viewModel,
                    onDelete: (ingredient) {
                      _showDeleteConfirmationDialog(
                          context, ingredient, fridgeId, viewModel);
                    },
                    onSetExpiryAlert: (ingredient) {
                      _showExpiryAlertDialog(context, ingredient);
                    },
                  )
                : FridgeGridView(
                    ingredients: viewModel.filteredIngredients,
                    fridgeId: fridgeId!,
                    viewModel: viewModel,
                    onDelete: (ingredient) {
                      _showDeleteConfirmationDialog(
                          context, ingredient, fridgeId, viewModel);
                    },
                    onSetExpiryAlert: (ingredient) {
                      _showExpiryAlertDialog(context, ingredient);
                    },
                  );
          },
        ),
      ),
      floatingActionButton: ActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, dynamic ingredient,
      String fridgeId, FridgeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Ingredient'),
          content:
              const Text('Are you sure you want to delete this ingredient?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteFridgeItem(fridgeId, ingredient.id);
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

  // Show expiry alert dialog
  void _showExpiryAlertDialog(BuildContext context, dynamic ingredient) {
    showDialog(
      context: context,
      builder: (context) {
        return ExpiryAlertDialog(
          ingredientName: ingredient.name,
          onSetAlert: (DateTime alertDateTime) {
            // Handle the expiry alert logic here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Expiry alert set for ${ingredient.name}')),
            );
          },
        );
      },
    );
  }
}