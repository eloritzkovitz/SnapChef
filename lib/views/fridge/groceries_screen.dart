import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './ingredient_search_delegate.dart';
import './widgets/fridge_filter_sort_sheet.dart';
import '../../theme/colors.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../views/fridge/widgets/ingredient_reminder_dialog.dart';
import '../../models/notifications/ingredient_reminder.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/snapchef_appbar.dart';

class GroceriesScreen extends StatelessWidget {
  final VoidCallback? onAdd;

  const GroceriesScreen({
    super.key,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: SnapChefAppBar(
        title: const Text(
          'Groceries',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.kitchen_outlined, color: Colors.black),
            tooltip: 'Add all to fridge',
            onPressed: () async {
              final fridgeViewModel =
                  Provider.of<FridgeViewModel>(context, listen: false);
              final userViewModel =
                  Provider.of<UserViewModel>(context, listen: false);
              final fridgeId = userViewModel.fridgeId;
              final groceries =
                  fridgeViewModel.groceriesController.filteredItems;
              if (fridgeId != null &&
                  fridgeId.isNotEmpty &&
                  groceries.isNotEmpty) {
                for (final ingredient in groceries) {
                  await fridgeViewModel.addGroceryToFridge(
                      fridgeId, ingredient);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('All groceries moved to fridge!')),
                  );
                }
              }
            },
          ),
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
                        vm.groceriesController.selectedCategory ?? '',
                    selectedSort:
                        vm.groceriesController.selectedSortOption ?? '',
                    categories: vm.groceriesController.getCategories(),
                    onClear: vm.groceriesController.clearFilters,
                    onApply: (cat, sort) {
                      vm.groceriesController
                          .filterByCategoryValue(cat.isEmpty ? null : cat);
                      vm.groceriesController
                          .sortByOption(sort.isEmpty ? null : sort);
                    },
                    categoryLabel: 'Category',
                    sortLabel: 'Sort By',
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: IngredientSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Consumer<FridgeViewModel>(
              builder: (context, fridgeViewModel, _) {
                final groceries =
                    fridgeViewModel.groceriesController.filteredItems;

                return groceries.isEmpty
                    ? const Center(
                        child: Text(
                          'No groceries in your list.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: groceries.length,
                        onReorder: (oldIndex, newIndex) {
                          final userViewModel = Provider.of<UserViewModel>(
                              context,
                              listen: false);
                          final fridgeId = userViewModel.fridgeId;
                          if (fridgeId != null && fridgeId.isNotEmpty) {
                            fridgeViewModel.reorderGroceryItem(
                                oldIndex, newIndex, fridgeId);
                          }
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
                          final ingredient = groceries[index];
                          return Padding(
                            key: ValueKey(ingredient.id),
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              child: ListTile(
                                leading: (ingredient.imageURL.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: ingredient.imageURL,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.contain,
                                        errorWidget:
                                            (context, error, stackTrace) =>
                                                SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Icon(Icons.image_not_supported,
                                              size: 32),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Icon(Icons.image_not_supported,
                                            size: 32),
                                      ),
                                title: Text(
                                  ingredient.count > 1
                                      ? '${ingredient.name} x ${ingredient.count}'
                                      : ingredient.name,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category: ${ingredient.category}'),
                                    Text('Quantity: ${ingredient.count}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.alarm,
                                          color: primaryColor),
                                      tooltip: 'Set Grocery Reminder',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              IngredientReminderDialog(
                                            ingredient: ingredient,
                                            type: ReminderType.grocery,
                                            onSetAlert: (_) {},
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.kitchen_outlined,
                                          color: primaryColor),
                                      tooltip: 'Move to Fridge',
                                      onPressed: () async {
                                        final userViewModel =
                                            Provider.of<UserViewModel>(context,
                                                listen: false);
                                        final fridgeId = userViewModel.fridgeId;
                                        if (fridgeId != null &&
                                            fridgeId.isNotEmpty) {
                                          await fridgeViewModel
                                              .addGroceryToFridge(
                                                  fridgeId, ingredient);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () async {
                                        final userViewModel =
                                            Provider.of<UserViewModel>(context,
                                                listen: false);
                                        final fridgeId = userViewModel.fridgeId;
                                        if (fridgeId != null &&
                                            fridgeId.isNotEmpty) {
                                          await fridgeViewModel
                                              .deleteGroceryItem(
                                                  fridgeId, ingredient.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
