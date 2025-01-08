import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class UploadPhoto {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadImage(BuildContext context) async {
    // Pick image from camera
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      print('No image selected.');
      return;
    }

    // Convert to File
    File file = File(image.path);

    // Prepare the HTTP request
    String? serverIp = dotenv.env['SERVER_IP'];
    print('Server IP: $serverIp');
    final mimeType = 'image/${file.path.split('.').last}';
    
    var request = http.MultipartRequest('POST', Uri.parse('$serverIp/recognize'))
    ..headers['Content-Type'] = mimeType
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('image', mimeType),
    ));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }
}