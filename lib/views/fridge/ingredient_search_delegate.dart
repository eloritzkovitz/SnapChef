import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ingredient_service.dart';
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
          title: Text(ingredient['name']),
          subtitle: Text('Category: ${ingredient['category']}'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddToFridgeDialog(context, ingredient);
            },
          ),
          onTap: () {
            close(context, ingredient); // Close the search and return the selected ingredient
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
          title: Text(ingredient['name']),
          subtitle: Text('Category: ${ingredient['category']}'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddToFridgeDialog(context, ingredient);
            },
          ),
          onTap: () {
            query = ingredient['name']; // Update the search query
            showResults(context); // Show the filtered results
          },
        );
      },
    );
  }

  void _showAddToFridgeDialog(BuildContext context, dynamic ingredient) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add ${ingredient['name']} to Fridge'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              hintText: 'Enter quantity',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {                  
                  final userViewModel = Provider.of<UserViewModel>(context, listen: false);
                  final fridgeViewModel = Provider.of<FridgeViewModel>(context, listen: false);
                  final fridgeId = userViewModel.fridgeId;

                  if (fridgeId != null && fridgeId.isNotEmpty) {
                    final success = await fridgeViewModel.addIngredientToFridge(
                      fridgeId,
                      ingredient['id'],
                      ingredient['name'],
                      ingredient['category'],
                      quantity,
                    );

                    if (success) {
                      Navigator.pop(context); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${ingredient['name']} added to fridge')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add ingredient to fridge')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fridge ID is missing. Please log in again.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid quantity')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}