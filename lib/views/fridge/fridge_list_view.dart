import 'package:flutter/material.dart';
import '../../viewmodels/fridge_viewmodel.dart';

class FridgeListView extends StatelessWidget {
  final List<dynamic> ingredients;
  final String fridgeId;
  final FridgeViewModel viewModel;
  final Function(dynamic ingredient) onDelete;
  final Function(dynamic ingredient) onSetExpiryAlert;

  const FridgeListView({
    super.key,
    required this.ingredients,
    required this.fridgeId,
    required this.viewModel,
    required this.onDelete,
    required this.onSetExpiryAlert,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          leading:
              (ingredient.imageURL != null && ingredient.imageURL.isNotEmpty)
                  ? Image.network(
                      ingredient.imageURL,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.image_not_supported, size: 36),
                      ),
                    )
                  : SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.image_not_supported, size: 36),
                    ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  '${ingredient.category}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () {
                  if (ingredient.count > 1) {
                    viewModel.decreaseCount(index, fridgeId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Quantity cannot be less than 1')),
                    );
                  }
                },
              ),
              Text(
                '${ingredient.count}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () {
                  viewModel.increaseCount(index, fridgeId);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  onDelete(ingredient);
                },
              ),
              IconButton(
                icon: const Icon(Icons.alarm, color: Colors.blue),
                onPressed: () => onSetExpiryAlert(ingredient),
              ),
            ],
          ),
        );
      },
    );
  }
}
