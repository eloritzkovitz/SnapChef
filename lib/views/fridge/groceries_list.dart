import 'package:flutter/material.dart';
import '../../models/ingredient.dart';

class GroceriesList extends StatelessWidget {
  final List<Ingredient> groceries;
  final VoidCallback? onAdd;
  final void Function(int)? onDelete;

  const GroceriesList({
    super.key,
    required this.groceries,
    this.onAdd,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Groceries',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: groceries.isEmpty
                ? const Center(
                    child: Text(
                      'No groceries in your list.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: groceries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ingredient = groceries[index];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: (ingredient.imageURL.isNotEmpty)
                              ? Image.network(
                                  ingredient.imageURL,
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
                          title: Text(ingredient.name),
                          subtitle: Text('Category: ${ingredient.category}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: onDelete != null ? () => onDelete!(index) : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Grocery Item'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}