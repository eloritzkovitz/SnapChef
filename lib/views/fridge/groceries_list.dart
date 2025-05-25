import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../views/fridge/widgets/ingredient_reminder_dialog.dart';
import '../../models/notifications/ingredient_reminder.dart';

class GroceriesList extends StatelessWidget {
  final VoidCallback? onAdd;

  const GroceriesList({
    super.key,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FridgeViewModel>(
      builder: (context, fridgeViewModel, _) {
        final groceries = fridgeViewModel.filteredGroceries;

        return Column(
          children: [
            Expanded(
              child: groceries.isEmpty
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
                        final userViewModel =
                            Provider.of<UserViewModel>(context, listen: false);
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
                                  ? Image.network(
                                      ingredient.imageURL,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.contain,
                                      errorBuilder:
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
                                    icon: const Icon(Icons.kitchen,
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
                                        await fridgeViewModel.deleteGroceryItem(
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
                    ),
            ),
          ],
        );
      },
    );
  }
}
