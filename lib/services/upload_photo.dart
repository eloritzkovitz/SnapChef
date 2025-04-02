import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class UploadPhoto {
  final BuildContext context;

  UploadPhoto(this.context);

  // Process image using the specified endpoint
  Future<Map<String, String>> processImage(File image, String endpoint) async {
    // Prepare the HTTP request
    String? serverIp = dotenv.env['SERVER_IP'];
    final mimeType = lookupMimeType(image.path);

    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw Exception('Invalid file type. Only images are allowed.');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$serverIp/api/ingredients/recognize/$endpoint'),
    )
      ..headers['Content-Type'] = mimeType
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType.parse(mimeType),
      ));

    // Send the request and handle response
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    log('Response status: ${response.statusCode}');
    log('Response body: $responseBody');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );

      // Parse the JSON response
      var jsonResponse = jsonDecode(responseBody);

      // Check if the response contains an ingredient object directly
      if (jsonResponse is Map && jsonResponse['name'] != null && jsonResponse['category'] != null) {
        var name = jsonResponse['name'];
        var category = jsonResponse['category'];
        var id = jsonResponse['id'];

        // Return the recognition result
        return {
          'id': id,
          'name': name,
          'category': category,
        };
    } else {
      throw Exception('No recognition results found.');
    }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${response.statusCode}')),
      );
      throw Exception('Failed to upload image.');
    }
  }
}