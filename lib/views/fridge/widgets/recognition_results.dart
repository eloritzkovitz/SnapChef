import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/fridge_viewmodel.dart';

class RecognitionResultsWidget extends StatefulWidget {
  final Map<String, Map<String, dynamic>> groupedIngredients;
  final String fridgeId;

  const RecognitionResultsWidget({
    super.key,
    required this.groupedIngredients,
    required this.fridgeId,
  });

  @override
  State<RecognitionResultsWidget> createState() => _RecognitionResultsWidgetState();
}

class _RecognitionResultsWidgetState extends State<RecognitionResultsWidget> {
  late Map<String, Map<String, dynamic>> localIngredients;

  @override
  void initState() {
    super.initState();
    // Clone the original map so we can modify it locally
    localIngredients = Map.from(widget.groupedIngredients);
  }

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
          if (localIngredients.isEmpty)
            const Text(
              'All ingredients have been processed.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ...localIngredients.values.map((ingredient) {
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
                          widget.fridgeId,
                          id,
                          name,
                          category,
                          quantity,
                        );
                        if (success) {
                          setState(() {
                            localIngredients.remove(name);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name added to fridge successfully')),
                          );
                          if (localIngredients.isEmpty) {
                            Navigator.pop(context);
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
                        setState(() {
                          localIngredients.remove(name);
                        });
                        if (localIngredients.isEmpty) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
