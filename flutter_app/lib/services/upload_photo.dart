import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadPhoto {
  final BuildContext context;

  UploadPhoto(this.context);  

  // Pick an image from the camera and upload it to the server for recognition
  Future<void> processImage(File image) async {
    if (image == null) {
      print('No image selected.');
      return;
    }

    // Prepare the HTTP request
    String? serverIp = dotenv.env['SERVER_IP'];    
    final mimeType = 'image/${image.path.split('.').last}';
    
    var request = http.MultipartRequest('POST', Uri.parse('$serverIp/recognize'))
    ..headers['Content-Type'] = mimeType
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      image.path,
      contentType: MediaType('image', mimeType),
    ));

        // Send the request and handle response
    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );

        // Parse the JSON response
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.containsKey('results') && jsonResponse['results'].isNotEmpty) {
          var results = jsonResponse['results'];
          var ingredient = results[0]['ingredient'];
          var category = results[0]['category'];

          // Show the recognition result
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Recognition Result'),
                content: Text('Ingredient: $ingredient\nCategory: $category'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No recognition results found.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}