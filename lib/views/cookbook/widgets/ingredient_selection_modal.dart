import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/recipe_viewmodel.dart';
import '../../../viewmodels/fridge_viewmodel.dart';
import '../../../models/ingredient.dart';

class IngredientSelectionModal extends StatefulWidget {
  const IngredientSelectionModal({super.key});

  @override
  State<IngredientSelectionModal> createState() =>
      _IngredientSelectionModalState();
}

class _IngredientSelectionModalState extends State<IngredientSelectionModal> {
  late TextEditingController _searchController;
  List<Ingredient> _filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);
    _filteredIngredients = List.from(fridgeViewModel.ingredients);
    _searchController.addListener(_filterIngredients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterIngredients() {
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredIngredients = fridgeViewModel.ingredients
          .where((ingredient) => ingredient.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar and Close Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Ingredients',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ingredient List
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.builder(
                itemCount: _filteredIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _filteredIngredients[index];
                  final isSelected =
                      recipeViewModel.isIngredientSelected(ingredient);

                  return ListTile(
                    leading: (ingredient.imageURL.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              ingredient.imageURL,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                    title: Text(ingredient.name),
                    subtitle: Text('Quantity: ${ingredient.count}'),
                    trailing: Checkbox(
                      value: isSelected,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            recipeViewModel.addIngredient(ingredient);
                          } else {
                            recipeViewModel.removeIngredient(ingredient);
                          }
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        if (!isSelected) {
                          recipeViewModel.addIngredient(ingredient);
                        } else {
                          recipeViewModel.removeIngredient(ingredient);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
