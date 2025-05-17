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
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/placeholder_image.png',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/placeholder_image.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 8.0),
            // Ingredient Name
            Text(
              ingredient.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            // Quantity Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrease Quantity Button
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle),
                  color: Colors.red,
                ),
                // Quantity Display
                Text(
                  '${ingredient.count}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                // Increase Quantity Button
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle),
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(),
            // Action Buttons (Delete and Expiry Alert)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: onDelete,
                ),
                const SizedBox(),
                // Expiry Alert Button
                IconButton(
                  icon: const Icon(Icons.alarm_add, color: Colors.blue),
                  onPressed: onSetExpiryAlert,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
