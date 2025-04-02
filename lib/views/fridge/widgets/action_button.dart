import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/upload_photo.dart';
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

  // Pick an image and wait for the result
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
        final result = await UploadPhoto(context).processImage(image, endpoint);
        Navigator.of(context).pop(); // Close the loading indicator
        if (result.isNotEmpty) {
          _showResultDialog(result);
        } else {
          _showResultDialog('No ingredient recognized. Please try again.');
        }
      } catch (e) {
        Navigator.of(context).pop(); // Close the loading indicator
        _showResultDialog('An error occurred: $e');
      }
    } else {
      log('No image selected.');
    }
  }

  // Show recognition result dialog
  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recognition Result'),
          content: Text(
            result,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          actions: <Widget>[
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