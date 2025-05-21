import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ingredient_search_delegate.dart';
import '../../services/ingredient_service.dart';
import '../../theme/colors.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';

class GroceriesList extends StatelessWidget {
  final VoidCallback? onAdd;

  const GroceriesList({
    super.key,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<FridgeViewModel>(
        builder: (context, fridgeViewModel, _) {
          final groceries = fridgeViewModel.groceries;
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
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: groceries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final ingredient = groceries[index];
                          return Card(
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
                              subtitle: Text(ingredient.category),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: IngredientSearchDelegate(
                        ingredientService: IngredientService(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Grocery Item'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
