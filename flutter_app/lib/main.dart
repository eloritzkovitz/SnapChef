import 'package:flutter/material.dart';
import 'services/upload_photo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Main application entry point
Future main() async {
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
  final UploadPhoto _uploadPhoto = UploadPhoto();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _uploadPhoto.pickAndUploadImage(context),
      child: Text('Capture Image'),
    );
  }
}