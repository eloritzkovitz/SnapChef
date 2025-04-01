import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ingredient_viewmodel.dart';
import './widgets/ingredient_card.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FridgeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Fridge'),
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: Column(
            children: [              
              Flexible( // Use Flexible instead of Expanded
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
                      itemCount: viewModel.ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = viewModel.ingredients[index];
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