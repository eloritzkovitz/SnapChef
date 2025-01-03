import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/viewmodels/ingredient_viewmodel.dart';

class IngredientListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<IngredientViewModel>(context);

    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: viewModel.ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = viewModel.ingredients[index];
        return ListTile(
          title: Text(ingredient.name),
          subtitle: Text(ingredient.category),
        );
      },
    );
  }
}