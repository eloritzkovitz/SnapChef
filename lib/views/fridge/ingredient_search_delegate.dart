import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ingredient_service.dart';
import '../../theme/colors.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';

class IngredientSearchDelegate extends SearchDelegate {
  final IngredientService ingredientService;

  IngredientSearchDelegate({required this.ingredientService});

  // Cache the list of all ingredients
  List<dynamic>? allIngredients;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search bar
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Please enter a search term'),
      );
    }

    // Filter the cached list of ingredients based on the query
    final filteredResults = allIngredients?.where((ingredient) {
      final name = ingredient['name'].toString().toLowerCase();
      final category = ingredient['category'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || category.contains(searchQuery);
    }).toList();

    if (filteredResults == null || filteredResults.isEmpty) {
      return const Center(
        child: Text('No ingredients found'),
      );
    }

    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final ingredient = filteredResults[index];
        return ListTile(
          leading: (ingredient['imageURL'] != null &&
                  ingredient['imageURL'].toString().isNotEmpty)
              ? Image.network(
                  ingredient['imageURL'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.image_not_supported, size: 32),
                  ),
                )
              : SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.image_not_supported, size: 32),
                ),
          title: Text(ingredient['name']),
          subtitle: Text('Category: ${ingredient['category']}'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddToFridgeDialog(context, ingredient);
            },
          ),
          onTap: () {
            _showAddToFridgeDialog(context, ingredient);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (allIngredients == null) {
      // Fetch all ingredients if not already loaded
      return FutureBuilder<List<dynamic>>(
        future: ingredientService.getAllIngredients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No ingredients available'),
            );
          }

          // Cache the fetched ingredients
          allIngredients = snapshot.data!;
          return const Center(
            child: Text('Start typing to search for ingredients'),
          );
        },
      );
    }

    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search for ingredients'),
      );
    }

    // Filter the cached list of ingredients based on the query
    final filteredSuggestions = allIngredients?.where((ingredient) {
      final name = ingredient['name'].toString().toLowerCase();
      final category = ingredient['category'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || category.contains(searchQuery);
    }).toList();

    if (filteredSuggestions == null || filteredSuggestions.isEmpty) {
      return const Center(
        child: Text('No suggestions available'),
      );
    }

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final ingredient = filteredSuggestions[index];
        return ListTile(
          leading: (ingredient['imageURL'] != null &&
                  ingredient['imageURL'].toString().isNotEmpty)
              ? Image.network(
                  ingredient['imageURL'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.image_not_supported, size: 32),
                  ),
                )
              : SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.image_not_supported, size: 32),
                ),
          title: Text(ingredient['name']),
          subtitle: Text('Category: ${ingredient['category']}'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddToFridgeDialog(context, ingredient);
            },
          ),
          onTap: () {
            query = ingredient['name'];
            showResults(context);
          },
        );
      },
    );
  }

  // Show dialog to add ingredient to fridge or groceries
  void _showAddToFridgeDialog(BuildContext context, dynamic ingredient) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            title: Text(
              'Add ${ingredient['name']}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ingredient['imageURL'] != null &&
                      ingredient['imageURL'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ingredient['imageURL'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  Text(
                    ingredient['category'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: primaryColor),
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                      ),
                      Container(
                        width: 48,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: primaryColor),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add to Groceries button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Groceries'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final userViewModel =
                            Provider.of<UserViewModel>(context, listen: false);
                        final fridgeViewModel = Provider.of<FridgeViewModel>(
                            context,
                            listen: false);
                        final fridgeId = userViewModel.fridgeId;

                        if (fridgeId != null && fridgeId.isNotEmpty) {
                          final success = await fridgeViewModel.addGroceryItem(
                            fridgeId,
                            ingredient['id'],
                            ingredient['name'],
                            ingredient['category'],
                            ingredient['imageURL'],
                            quantity,
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${ingredient['name']} added to groceries')),
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Failed to add ingredient to groceries')),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Fridge ID is missing. Please log in again.')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Add to Fridge button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.kitchen),
                      label: const Text('Add to Fridge'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final userViewModel =
                            Provider.of<UserViewModel>(context, listen: false);
                        final fridgeViewModel = Provider.of<FridgeViewModel>(
                            context,
                            listen: false);
                        final fridgeId = userViewModel.fridgeId;

                        if (fridgeId != null && fridgeId.isNotEmpty) {
                          final success = await fridgeViewModel.addFridgeItem(
                            fridgeId,
                            ingredient['id'],
                            ingredient['name'],
                            ingredient['category'],
                            ingredient['imageURL'],
                            quantity,
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${ingredient['name']} added to fridge')),
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Failed to add ingredient to fridge')),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Fridge ID is missing. Please log in again.')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child:
                          Text('Cancel', style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
