import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/fridge_viewmodel.dart';

class RecognitionResultsWidget extends StatelessWidget {
  final Map<String, Map<String, dynamic>> groupedIngredients;
  final String fridgeId;

  const RecognitionResultsWidget({
    Key? key,
    required this.groupedIngredients,
    required this.fridgeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fridgeViewModel = Provider.of<FridgeViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Recognized Ingredients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (groupedIngredients.isEmpty)
            const Text(
              'All ingredients have been processed.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ...groupedIngredients.values.map((ingredient) {
            final name = ingredient['name'];
            final category = ingredient['category'];
            final id = ingredient['id'];
            final quantity = ingredient['quantity'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('$name x $quantity'),
                subtitle: Text('Category: $category'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final success = await fridgeViewModel.addIngredientToFridge(
                          fridgeId,
                          id,
                          name,
                          category,
                          quantity,
                        );
                        if (success) {
                          groupedIngredients.remove(name); // Remove the ingredient group
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name added to fridge successfully')),
                          );
                          if (groupedIngredients.isEmpty) {
                            Navigator.pop(context); // Close the bottom sheet if all are processed
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add $name to fridge')),
                          );
                        }
                      },
                      child: const Text('Add to Fridge'),
                    ),
                    TextButton(
                      onPressed: () {
                        groupedIngredients.remove(name); // Remove the ingredient from the list
                        if (groupedIngredients.isEmpty) {
                          Navigator.pop(context); // Close the bottom sheet if all are discarded
                        }
                      },
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}