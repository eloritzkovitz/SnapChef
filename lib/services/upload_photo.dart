import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class UploadPhoto {
  // Process image using the specified endpoint
  Future<List<dynamic>> processImage(File image, String endpoint) async {
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
      // Parse the JSON response
      var jsonResponse = jsonDecode(responseBody);

      // Check if the response contains an array of ingredients
      if (jsonResponse is List) {
        return jsonResponse; // Return the list of recognized ingredients
      } else {
        return []; // Return an empty list if no ingredients are recognized
      }
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}