import 'package:flutter/material.dart';
import '../../../models/ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;
  final VoidCallback onSetExpiryAlert;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
    required this.onSetExpiryAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.white,
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ingredient Image
            (ingredient.imageURL.isNotEmpty &&
                    ingredient.imageURL.startsWith('http'))
                ? Image.network(
                    ingredient.imageURL,
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/placeholder_image.png',
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    'assets/images/placeholder_image.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
            // Ingredient Name
            Text(
              ingredient.name,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              ingredient.category,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Quantity Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle),
                  color: Colors.red,
                  iconSize: 24,
                  tooltip: 'Decrease quantity',
                ),
                Text(
                  '${ingredient.count}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle),
                  color: Colors.green,
                  iconSize: 24,
                  tooltip: 'Increase quantity',
                ),
              ],
            ),
            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: onDelete,
                  iconSize: 24,
                  tooltip: 'Delete ingredient',
                ),
                IconButton(
                  icon: const Icon(Icons.alarm_add, color: Colors.blue),
                  onPressed: onSetExpiryAlert,
                  iconSize: 24,
                  tooltip: 'Set expiry alert',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
