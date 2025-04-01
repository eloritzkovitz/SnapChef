import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import './widgets/ingredient_card.dart';
import './ingredient_search_delegate.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FridgeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Fridge', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: Column(
            children: [
              Flexible(
                child: Consumer<FridgeViewModel>(
                  builder: (context, viewModel, child) {
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
                          onIncrease: () => viewModel.increaseCount(index),
                          onDecrease: () => viewModel.decreaseCount(index),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}