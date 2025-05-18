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
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/fridge_viewmodel.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/cookbook_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/main_screen.dart';
import 'views/animated_splash_screen.dart';

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
  FirebaseMessaging.onBackgroundMessage(
      FirebaseMessagingUtil.firebaseMessagingBackgroundHandler);

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    log("Environment variables loaded successfully.");
  } catch (e) {
    log("Error loading .env file: $e");
  }

  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // Retrieve the access and refresh tokens from SharedPreferences
  final accessToken = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');

  // Initialize the AuthViewModel
  final authViewModel = AuthViewModel();
  final userViewModel = UserViewModel();
  final fridgeViewModel = FridgeViewModel();
  final cookbookViewModel = CookbookViewModel();

  bool isLoggedIn = false;

  // Handle token validation and user profile fetching
  if (accessToken != null && refreshToken != null) {
    try {
      await userViewModel.fetchUserProfile();
      isLoggedIn = userViewModel.user != null;

      // Fetch fridge and cookbook data if user is loaded
      if (isLoggedIn) {
        final fridgeId = userViewModel.fridgeId;
        final cookbookId = userViewModel.cookbookId;
        if (fridgeId != null) {
          await fridgeViewModel.fetchFridgeIngredients(fridgeId);
        }
        if (cookbookId != null) {
          await cookbookViewModel.fetchCookbookRecipes(cookbookId);
        }
      }
    } catch (e) {
      try {
        await authViewModel.refreshTokens();
        await userViewModel.fetchUserProfile();
        isLoggedIn = userViewModel.user != null;
        if (isLoggedIn) {
          final fridgeId = userViewModel.fridgeId;
          final cookbookId = userViewModel.cookbookId;
          if (fridgeId != null) {
            await fridgeViewModel.fetchFridgeIngredients(fridgeId);
          }
          if (cookbookId != null) {
            await cookbookViewModel.fetchCookbookRecipes(cookbookId);
          }
        }
      } catch (e) {
        isLoggedIn = false;
      }
    }
  } else {
    isLoggedIn = false;
  }

  // Run the app with the login status and viewmodels
  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    authViewModel: authViewModel,
    userViewModel: userViewModel,
    fridgeViewModel: fridgeViewModel,
    cookbookViewModel: cookbookViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final AuthViewModel authViewModel;
  final UserViewModel userViewModel;
  final FridgeViewModel fridgeViewModel;
  final CookbookViewModel cookbookViewModel;

  const MyApp({
    required this.isLoggedIn,
    required this.authViewModel,
    required this.userViewModel,
    required this.fridgeViewModel,
    required this.cookbookViewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => authViewModel),
        ChangeNotifierProvider(create: (_) => userViewModel),
        ChangeNotifierProvider(create: (_) => fridgeViewModel),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => cookbookViewModel),
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
        home: AnimatedSplashScreen(isLoggedIn: isLoggedIn),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}