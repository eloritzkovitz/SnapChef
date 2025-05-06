import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'theme/colors.dart';
import 'utils/firebase_messaging_util.dart';
import 'viewmodels/main_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/fridge_viewmodel.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/cookbook_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/main_screen.dart';

// Initialize Flutter Local Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Notification Service
  await NotificationService().initNotification();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Request notification permissions
  await FirebaseMessagingUtil.requestNotificationPermissions(); 

  // Set up Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(FirebaseMessagingUtil.firebaseMessagingBackgroundHandler);

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    log("Environment variables loaded successfully.");
  } catch (e) {
    log("Error loading .env file: $e");
  }

  // Check if the user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final authViewModel = AuthViewModel();

  bool isLoggedIn = false;

  if (accessToken != null) {
    try {
      await authViewModel.fetchUserProfile();
      isLoggedIn = true;
    } catch (e) {
      log('Error during auto-login: $e');
      // Tokens might have been cleared inside refreshTokens()
      isLoggedIn = false;
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn, authViewModel: authViewModel));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final AuthViewModel authViewModel;

  const MyApp({required this.isLoggedIn, required this.authViewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => authViewModel),
        ChangeNotifierProvider(create: (_) => FridgeViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => CookbookViewModel()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: primaryColor,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            foregroundColor: secondaryColor,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            showSelectedLabels: false,
          ),
        ),
        initialRoute: isLoggedIn ? '/main' : '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}