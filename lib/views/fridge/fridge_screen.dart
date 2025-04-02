import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import './widgets/ingredient_card.dart';
import './ingredient_search_delegate.dart';
import './widgets/action_button.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fridgeId = Provider.of<AuthViewModel>(context, listen: false).fridgeId;

    return ChangeNotifierProvider(
      create: (_) => FridgeViewModel()..fetchFridgeIngredients(fridgeId!),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fridge', style: TextStyle(fontWeight: FontWeight.bold)),
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: IngredientSearchDelegate(),
                );
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

              if (viewModel.ingredients.isEmpty) {
                // Show "No available ingredients" message if the fridge is empty
                return const Center(
                  child: Text(
                    'No available ingredients',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              // Show the grid of ingredients
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: viewModel.filteredIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = viewModel.filteredIngredients[index];
                  return IngredientCard(
                    ingredient: ingredient,
                    onIncrease: () => viewModel.increaseCount(index, fridgeId!),
                    onDecrease: () => viewModel.decreaseCount(index, fridgeId!),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: const ActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}