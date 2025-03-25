import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadPhoto {
  
  final BuildContext context;

  UploadPhoto(this.context);

  // Process image using the specified endpoint
  Future<String> processImage(File image, String endpoint) async {

    // Prepare the HTTP request
    String? serverIp = dotenv.env['SERVER_IP'];
    final mimeType = 'image/${image.path.split('.').last}';

    var request = http.MultipartRequest('POST', Uri.parse('$serverIp/api/recognize/$endpoint'))
      ..headers['Content-Type'] = mimeType
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', mimeType),
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
      if (jsonResponse is List && jsonResponse.isNotEmpty) {      
        var firstResult = jsonResponse[0];
        var ingredient = firstResult['ingredient'];
        var category = firstResult['category'];

        // Return the recognition result        
        return 'Ingredient: $ingredient\nCategory: $category';        
      } else {
        return 'No recognition results found.';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${response.statusCode}')),
      );
      return 'Failed to upload image.';
    }
  }  
}