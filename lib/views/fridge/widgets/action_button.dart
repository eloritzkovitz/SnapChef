import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/fridge_viewmodel.dart';
import '../generate_recipe_screen.dart';
import '../../../theme/colors.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({super.key});

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  final ImagePicker _picker = ImagePicker();
  bool _isExpanded = false;

  // Pick an image and process it
  Future<void> _pickImage(String endpoint) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File image = File(pickedFile.path);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final fridgeViewModel = Provider.of<FridgeViewModel>(context, listen: false);

      try {
        // Recognize ingredients
        await fridgeViewModel.recognizeIngredients(image, endpoint);

        Navigator.of(context).pop(); // Close the loading indicator

        // Show the recognition results
        if (fridgeViewModel.recognizedIngredients.isNotEmpty) {
          _showRecognitionResults(fridgeViewModel.recognizedIngredients);
        } else {
          _showNoIngredientsPopup();
        }
      } catch (e) {
        Navigator.of(context).pop(); // Close the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Show recognition results dialog
  void _showRecognitionResults(List<dynamic> ingredients) {
    final fridgeViewModel = Provider.of<FridgeViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final fridgeId = authViewModel.fridgeId;

    if (fridgeId == null || fridgeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fridge ID is missing. Please log in again.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                  if (ingredients.isEmpty)
                    const Text(
                      'All ingredients have been processed.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ...ingredients.map((ingredient) {
                    final name = ingredient['name'];
                    final category = ingredient['category'];
                    final id = ingredient['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(name),
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
                                  1, // Default quantity
                                );
                                if (success) {
                                  setState(() {
                                    ingredients.remove(ingredient); // Remove the ingredient from the list
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$name added to fridge successfully')),
                                  );
                                  if (ingredients.isEmpty) {
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
                                setState(() {
                                  ingredients.remove(ingredient); // Remove the ingredient from the list
                                });
                                if (ingredients.isEmpty) {
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
          },
        );
      },
    );
  }

  // Show a popup if no ingredients are recognized
  void _showNoIngredientsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Ingredients Recognized'),
          content: const Text('No ingredients were recognized in the uploaded image.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          FloatingActionButton(
            backgroundColor: primarySwatch[300],
            onPressed: () => _pickImage('photo'),
            tooltip: 'Capture Photo',
            child: const Icon(Icons.photo_camera, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: primarySwatch[200],
            onPressed: () => _pickImage('receipt'),
            tooltip: 'Scan Receipt',
            child: const Icon(Icons.receipt_long, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _pickImage('barcode'),
            tooltip: 'Scan Barcode',
            child: const Icon(Icons.qr_code_scanner, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: primarySwatch[100],
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenerateRecipeScreen()),
              );
            },
            tooltip: 'Generate Recipe',
            child: const Icon(Icons.restaurant_menu, color: Colors.white),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: primaryColor),
            borderRadius: BorderRadius.circular(100),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Icon(_isExpanded ? Icons.close : Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}