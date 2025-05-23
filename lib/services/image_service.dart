import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../utils/token_util.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick an image for source selection
  Future<File?> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Take a Photo Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 80, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 8),
                          Text('Choose from Camera',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              )),
                        ],
                      ),
                    ),
                  ),
                  // Choose from Gallery Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library,
                              size: 80, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 8),
                          Text('Choose from Gallery',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    }
    return null;
  }

  // Process image using the specified endpoint
  Future<List<dynamic>> processImage(File image, String endpoint,
      {String? barcode}) async {
    String? serverIp = dotenv.env['SERVER_IP'];
    final token = await TokenUtil.getAccessToken();

    // If endpoint is barcode and barcode is provided, send only the barcode (no file)
    if (endpoint == 'barcode' && barcode != null) {
      var uri = Uri.parse('$serverIp/api/ingredients/recognition/barcode');
      var response = await http.post(
        uri,
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
        body: {'barcode': barcode},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          return jsonResponse;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to recognize barcode: ${response.statusCode}');
      }
    }

    // Otherwise, send the image as before
    final mimeType = lookupMimeType(image.path);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw Exception('Invalid file type. Only images are allowed.');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$serverIp/api/ingredients/recognition/$endpoint'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType.parse(mimeType),
      ));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      if (jsonResponse is List) {
        return jsonResponse;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
