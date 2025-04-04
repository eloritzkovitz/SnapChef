import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/image_service.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'recognition_results.dart';
import '../generate_recipe_screen.dart';
import '../../../theme/colors.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({super.key});

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  final ImageService _imageService = ImageService();
  bool _isExpanded = false;

  // Pick an image and process it
  Future<void> _pickImage(String endpoint) async {
    // Use ImageService to pick an image
    final image = await _imageService.pickImage('camera');
    if (image != null) {
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

      try {
        // Use ImageService to upload and process the image
        final recognizedIngredients = await _imageService.processImage(image, endpoint);

        Navigator.of(context).pop(); // Close the loading indicator

        // Show the recognition results
        if (recognizedIngredients.isNotEmpty) {
          _showRecognitionResults(recognizedIngredients);
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
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final fridgeId = authViewModel.fridgeId;

    if (fridgeId == null || fridgeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fridge ID is missing. Please log in again.')),
      );
      return;
    }

    // Group ingredients by name and calculate their quantities
    final Map<String, Map<String, dynamic>> groupedIngredients = {};
    for (var ingredient in ingredients) {
      final name = ingredient['name'];
      if (groupedIngredients.containsKey(name)) {
        groupedIngredients[name]!['quantity'] += 1; // Increment quantity
      } else {
        groupedIngredients[name] = {
          'name': name,
          'category': ingredient['category'],
          'id': ingredient['id'],
          'quantity': 1, // Initialize quantity
        };
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return RecognitionResultsWidget(
          groupedIngredients: groupedIngredients,
          fridgeId: fridgeId,
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
    return Stack(
      children: [
        Positioned(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isExpanded) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Capture Photo',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          backgroundColor: primarySwatch[500],
                          onPressed: () => _pickImage('photo'),
                          tooltip: 'Capture Photo',
                          child: const Icon(Icons.photo_camera, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Scan Receipt',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          backgroundColor: primarySwatch[400],
                          onPressed: () => _pickImage('receipt'),
                          tooltip: 'Scan Receipt',
                          child: const Icon(Icons.receipt_long, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Scan Barcode',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          backgroundColor: primarySwatch[300],
                          onPressed: () => _pickImage('barcode'),
                          tooltip: 'Scan Barcode',
                          child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Generate Recipe',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          backgroundColor: primarySwatch[200],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GenerateRecipeScreen()),
                            );
                          },
                          tooltip: 'Generate Recipe',
                          child: const Icon(Icons.restaurant_menu, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
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
          ),
        ),
      ],
    );
  }
}