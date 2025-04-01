import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/fridge_viewmodel.dart';

class IngredientSearchDelegate extends SearchDelegate {
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
    final viewModel = Provider.of<FridgeViewModel>(context, listen: false);
    final results = viewModel.ingredients
        .where((ingredient) => ingredient.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final ingredient = results[index];
        return ListTile(
          title: Text(ingredient.name),
          subtitle: Text('Category: ${ingredient.category}'),
          onTap: () {
            close(context, ingredient); // Close the search and return the selected ingredient
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final viewModel = Provider.of<FridgeViewModel>(context, listen: false);
    final suggestions = viewModel.ingredients
        .where((ingredient) => ingredient.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final ingredient = suggestions[index];
        return ListTile(
          title: Text(ingredient.name),
          onTap: () {
            query = ingredient.name; // Update the search query
            showResults(context); // Show the filtered results
          },
        );
      },
    );
  }
}