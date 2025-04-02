import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../services/upload_photo.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/fridge_viewmodel.dart';
import '../../../theme/colors.dart';
import '../generate_recipe_screen.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({super.key});

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isExpanded = false;

  // Pick an image and process it
  Future<void> _pickImage(String endpoint) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      log('Picked image path: ${pickedFile.path}'); // Debug print

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
        // Process the image using UploadPhoto
        final uploadPhoto = UploadPhoto(context);
        final result = await uploadPhoto.processImage(image, endpoint);

        Navigator.of(context).pop(); // Close the loading indicator

        if (result.isNotEmpty) {
          // Extract the fields from the result
          final id = result['id'];
          final name = result['name'];
          final category = result['category'];

          // Show the recognition result dialog
          _showResultDialog(name, category, id);
        }
      } catch (e) {
        Navigator.of(context).pop(); // Close the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Show recognition result dialog
  void _showResultDialog(String? name, String? category, String? id) {
    final fridgeViewModel = Provider.of<FridgeViewModel>(context, listen: false);
    final userViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final fridgeId = userViewModel.fridgeId;

    if (fridgeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fridge ID not found. Please log in again.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recognition Result'),
          content: name != null && category != null
              ? Text(
                  'Ingredient: $name\nCategory: $category',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                )
              : const Text(
                  'No recognition results found.',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
          actions: <Widget>[
            if (name != null && category != null)
              TextButton(
                child: const Text('Add to Fridge'),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  final success = await fridgeViewModel.addIngredientToFridge(
                    fridgeId,
                    id ?? 'generated-id', // Pass the id or a default value
                    name,
                    category,
                    1, // Default quantity
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingredient added to fridge successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add ingredient to fridge')),
                    );
                  }
                },
              ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
            onPressed: () => _pickImage('photo'),
            tooltip: 'Capture Photo',
            child: const Icon(Icons.photo_camera, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
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
            backgroundColor: secondaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenerateRecipeScreen()),
              );
            },
            tooltip: 'Generate Recipe',
            child: const Icon(Icons.restaurant_menu, color: Colors.white),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
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