import 'package:flutter/material.dart';
import '../../../models/ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}