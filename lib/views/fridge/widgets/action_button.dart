import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'recognition_results.dart';
import '../../cookbook/generate_recipe_screen.dart';
import '../../../services/image_service.dart';
import '../../../theme/colors.dart';
import '../../../utils/ui_util.dart';
import '../../../viewmodels/user_viewmodel.dart';

class ActionButton extends StatelessWidget {
  final bool isDisabled;
  ActionButton({super.key, this.isDisabled = false});

  final ImageService _imageService = ImageService();

  Future<void> _pickImage(BuildContext context, String endpoint) async {
    final image = await _imageService.pickImage(context);
    if (image != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        List<dynamic> recognizedIngredients = [];
        if (endpoint == 'barcode') {
          // 1. Use ML Kit to scan barcode from the image
          final barcode = await scanBarcodeWithMLKit(image);
          if (barcode != null && barcode.isNotEmpty) {
            recognizedIngredients = await _imageService.processImage(
              image, // or dummyImage if needed
              endpoint,
              barcode: barcode,
            );
          } else {
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No barcode found in the image.')),
              );
            }
            return;
          }
        } else {
          recognizedIngredients =
              await _imageService.processImage(image, endpoint);
        }

        if (context.mounted) Navigator.of(context).pop(); // Close loading

        if (recognizedIngredients.isNotEmpty && context.mounted) {
          _showRecognitionResults(context, recognizedIngredients);
        } else {
          if (context.mounted) _showNoIngredientsPopup(context);
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  // Use ML Kit to scan barcode from the image
  Future<String?> scanBarcodeWithMLKit(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final barcodeScanner = BarcodeScanner();
    final barcodes = await barcodeScanner.processImage(inputImage);
    await barcodeScanner.close();

    if (barcodes.isNotEmpty) {
      return barcodes.first.rawValue;
    }
    return null;
  }

  // Show recognition results
  void _showRecognitionResults(
      BuildContext context, List<dynamic> ingredients) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final fridgeId = userViewModel.fridgeId;

    if (fridgeId == null || fridgeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fridge ID is missing. Please log in again.')),
      );
      return;
    }

    final Map<String, Map<String, dynamic>> groupedIngredients = {};
    for (var ingredient in ingredients) {
      final name = ingredient['name'];
      if (groupedIngredients.containsKey(name)) {
        groupedIngredients[name]!['quantity'] += 1;
      } else {
        groupedIngredients[name] = {
          'name': name,
          'category': ingredient['category'],
          'id': ingredient['id'],
          'imageURL': ingredient['imageURL'] ?? '',
          'quantity': 1,
        };
      }
    }

    // Show the results in a bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecognitionResultsWidget(
        groupedIngredients: groupedIngredients,
        fridgeId: fridgeId,
      ),
    );
  }

  // Show no ingredients popup
  void _showNoIngredientsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No Ingredients Recognized'),
        content:
            const Text('No ingredients were recognized in the uploaded image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: isDisabled ? disabledColor : primaryColor,
      foregroundColor: Colors.white,
      spacing: 10,
      spaceBetweenChildren: 8,
      childPadding: const EdgeInsets.all(4),
      animatedIconTheme: const IconThemeData(size: 22.0),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.auto_awesome, color: Colors.white),
          backgroundColor:
              isDisabled ? disabledSecondaryColor : primarySwatch[300],
          label: 'Generate Recipe',
          labelStyle: const TextStyle(fontSize: 12),
          onTap: isDisabled
              ? () => UIUtil.showUnavailableOffline(context)
              : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => GenerateRecipeScreen()));
                },
        ),
        SpeedDialChild(
          child: const Icon(Icons.qr_code_scanner, color: Colors.white),
          backgroundColor:
              isDisabled ? disabledSecondaryColor : primarySwatch[300],
          label: 'Scan Barcode',
          labelStyle: const TextStyle(fontSize: 12),
          onTap: isDisabled ? () => UIUtil.showUnavailableOffline(context) : () => _pickImage(context, 'barcode'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.receipt_long, color: Colors.white),
          backgroundColor:
              isDisabled ? disabledSecondaryColor : primarySwatch[300],
          label: 'Scan Receipt',
          labelStyle: const TextStyle(fontSize: 12),
          onTap: isDisabled ? () => UIUtil.showUnavailableOffline(context) : () => _pickImage(context, 'receipt'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.photo_camera, color: Colors.white),
          backgroundColor:
              isDisabled ? disabledSecondaryColor : primarySwatch[300],
          label: 'Capture Photo',
          labelStyle: const TextStyle(fontSize: 12),
          onTap: isDisabled ? () => UIUtil.showUnavailableOffline(context) : () => _pickImage(context, 'photo'),
        ),
      ],
    );
  }
}
