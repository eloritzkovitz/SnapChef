import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '/view_models/main_view_model.dart';
import '/views/main_screen.dart';

// Main application entry point
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try loading the .env file  
  try {    
    await dotenv.load(fileName: ".env");
    log("Environment variables loaded successfully.");
    runApp(const MyApp());
  } catch (e) {
    log("Error loading .env file: $e");
  }  
}

const primaryColor = Color(0xffff794e);
const secondaryColor = Color(0xffff5722);

// Add a new MyApp widget
class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: primaryColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,            
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            showSelectedLabels: false
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}