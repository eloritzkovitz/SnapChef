import 'package:flutter/material.dart';
import 'services/upload_photo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Main application entry point
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try loading the .env file  
  try {    
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully.");
    runApp(MyApp());
  } catch (e) {
    print("Error loading .env file: $e");
  }  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SnapChef')),
        body: Center(child: CaptureButton()),
      ),
    );
  }
}

class CaptureButton extends StatefulWidget {
  @override
  _CaptureButtonState createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      UploadPhoto(context).processImage(image);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _pickImage,
      child: Text('Capture photo'),
    );
  }
}