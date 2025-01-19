import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'services/upload_photo.dart';
import 'services/generate_recipe.dart';

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

const primaryColor = Color(0xffff794e);

// Add a new MyApp widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
        ),
      ),
      home: MainScreen(),
    );
  }
}

// Add a new MainScreen widget
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SnapChef')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenerateRecipe()),
                );
              },
              child: Text('Generate Recipe'),
            ),
          ],
        ),
      ),
      floatingActionButton: CaptureButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CaptureButton extends StatefulWidget {
  @override
  _CaptureButtonState createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isExpanded = false;

  Future<void> _pickImage(String endpoint) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      print('Picked image path: ${pickedFile.path}');
      final result = await UploadPhoto(context).processImage(image, endpoint);
      _showResultDialog(result);
    } else {
      print('No image selected.');
    }
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recognition Result'),
          content: Text(result),
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          FloatingActionButton(
            onPressed: () => _pickImage('photo'),
            tooltip: 'Capture Photo',
            child: Icon(Icons.photo_camera),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _pickImage('receipt'),
            tooltip: 'Scan Receipt',
            child: Icon(Icons.receipt_long),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _pickImage('barcode'),
            tooltip: 'Scan Barcode',
            child: Icon(Icons.qr_code_scanner),
          ),
          SizedBox(height: 10),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Icon(_isExpanded ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}