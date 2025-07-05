import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snapchef/services/image_service.dart';

class MockImageService extends ImageService {
  bool throwOnPick = false;
  bool returnImage = true;
  bool throwOnProcess = false;
  bool barcodeMode = false;

  @override
  Future<File?> pickImage(BuildContext context) async {
    if (throwOnPick) throw Exception('Pick error');
    return returnImage ? File('dummy.jpg') : null;
  }

  @override
  Future<List<dynamic>> processImage(dynamic image, String endpoint, {String? barcode}) async {
    if (throwOnProcess) throw Exception('Process error');
    if (barcodeMode && barcode == null) return [];
    return [
      {'name': 'Egg', 'category': 'Dairy', 'id': '1', 'imageURL': ''}
    ];
  }
}