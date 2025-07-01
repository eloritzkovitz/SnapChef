import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ingredient_viewmodel.dart';
import 'groceries_screen.dart';
import 'widgets/fridge_list_view.dart';
import 'widgets/fridge_grid_view.dart';
import './ingredient_search_delegate.dart';
import './widgets/action_button.dart';
import './widgets/fridge_filter_sort_sheet.dart';
import './widgets/ingredient_reminder_dialog.dart';
import '../../models/notifications/ingredient_reminder.dart';
import '../../providers/connectivity_provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../widgets/snapchef_appbar.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  bool isListView = false; // State variable to toggle between views

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);
    final ingredientViewModel =
        Provider.of<IngredientViewModel>(context, listen: false);
    if (userViewModel.fridgeId != null) {
      fridgeViewModel.fetchData(
        fridgeId: userViewModel.fridgeId!,
        ingredientViewModel: ingredientViewModel,
      );
    }
  }

  // Open the groceries list in a sliding panel
  void _openGroceriesList(BuildContext rootContext) {
    showGeneralDialog(
      context: rootContext,
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
              ),
              child: const GroceriesScreen(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
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
        return IngredientReminderDialog(
          ingredient: ingredient,
          type: ReminderType.expiry,
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

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final fridgeId = userViewModel.fridgeId;

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

    // Check if the device or the server are offline
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    return Scaffold(
      appBar: SnapChefAppBar(
        title:
            const Text('Fridge', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Sorting and filtering button
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            tooltip: 'Filter & Sort',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) {
                  final vm =
                      Provider.of<FridgeViewModel>(context, listen: false);
                  return FridgeFilterSortSheet(
                    selectedCategory:
                        vm.fridgeController.selectedCategory ?? '',
                    selectedSort: vm.fridgeController.selectedSortOption ?? '',
                    categories: vm.fridgeController.getCategories(),
                    onClear: vm.fridgeController.clearFilters,
                    onApply: (cat, sort) {
                      vm.fridgeController
                          .filterByCategoryValue(cat.isEmpty ? null : cat);
                      vm.fridgeController
                          .sortByOption(sort.isEmpty ? null : sort);
                    },
                    categoryLabel: 'Category',
                    sortLabel: 'Sort By',
                  );
                },
              );
            },
          ),
          // Toggle Button for View Mode
          IconButton(
            color: Colors.black,
            icon: Icon(isListView ? Icons.grid_view : Icons.view_list),
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
                delegate: IngredientSearchDelegate(),
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

            if (viewModel.fridgeController.filteredItems.isEmpty) {
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
                    ingredients: viewModel.fridgeController.filteredItems,
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
                    ingredients: viewModel.fridgeController.filteredItems,
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
      floatingActionButton: ActionButton(isDisabled: isOffline),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
