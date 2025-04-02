import 'package:flutter/material.dart';
import '../../../models/ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/placeholder_image.png',
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8.0),
            Text(
              ingredient.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle),
                  color: Colors.red,
                ),
                Text(
                  '${ingredient.count}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle),
                  color: Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () async {
                    final shouldDelete = await _showDeleteConfirmationDialog(context);
                    if (shouldDelete) {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Ingredient'),
              content: const Text('Are you sure you want to delete this ingredient?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}