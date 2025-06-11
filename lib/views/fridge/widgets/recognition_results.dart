import 'package:cached_network_image/cached_network_image.dart';
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
  State<RecognitionResultsWidget> createState() =>
      _RecognitionResultsWidgetState();
}

class _RecognitionResultsWidgetState extends State<RecognitionResultsWidget> {
  late Map<String, Map<String, dynamic>> localIngredients;

  @override
  void initState() {
    super.initState();
    localIngredients = Map.from(widget.groupedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxPopupHeight = constraints.maxHeight * 0.9;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxPopupHeight,
                minWidth: 300,
                maxWidth: 500,
              ),
              child: Material(
                color: Colors.transparent,
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
                    if (localIngredients.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: localIngredients.length,
                          itemBuilder: (context, index) {
                            final ingredient =
                                localIngredients.values.elementAt(index);
                            final name = ingredient['name'];
                            final category = ingredient['category'];
                            final id = ingredient['id'];
                            final quantity = ingredient['quantity'];
                            final imageUrl = ingredient['imageURL'];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  children: [                                    
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imageUrl != null &&
                                              imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                              errorWidget: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('$name',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                          Text('Category: $category',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          if (ingredient['quantity'] > 1) {
                                            ingredient['quantity'] -= 1;
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline,
                                          color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          ingredient['quantity'] += 1;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check_circle,
                                          color: Colors.blue),
                                      tooltip: 'Add to Fridge',
                                      onPressed: () async {
                                        final success = await fridgeViewModel
                                            .addFridgeItem(
                                          widget.fridgeId,
                                          id,
                                          name,
                                          category,
                                          imageUrl,
                                          ingredient['quantity'],
                                        );
                                        if (success && context.mounted) {
                                          setState(() {
                                            localIngredients.remove(name);
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    '$name added to fridge successfully')),
                                          );
                                          if (localIngredients.isEmpty) {
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to add $name to fridge')),
                                          );
                                          }
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.grey),
                                      tooltip: 'Discard',
                                      onPressed: () {
                                        setState(() {
                                          localIngredients.remove(name);
                                        });
                                        if (localIngredients.isEmpty) {
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}