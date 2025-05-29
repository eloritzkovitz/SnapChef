import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'services/ingredient_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/firebase_messaging_util.dart';
import 'viewmodels/main_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/fridge_viewmodel.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/cookbook_viewmodel.dart';
import 'viewmodels/notifications_viewmodel.dart';
import 'viewmodels/friend_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/main_screen.dart';
import 'views/splash/animated_splash_screen.dart';

// RouteObserver for navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Initialize Flutter Local Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set navigation bar to orange before app starts
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFF47851),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

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

  // Initialize the AuthViewModel
  final authViewModel = AuthViewModel();
  final userViewModel = UserViewModel();
  userViewModel.listenForFcmTokenRefresh();
  final fridgeViewModel = FridgeViewModel();
  final cookbookViewModel = CookbookViewModel();
  final friendViewModel = FriendViewModel();

  // Run the app with the login status and viewmodels
  runApp(MyApp(
    authViewModel: authViewModel,
    userViewModel: userViewModel,
    fridgeViewModel: fridgeViewModel,
    cookbookViewModel: cookbookViewModel,
    friendViewModel: friendViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final UserViewModel userViewModel;
  final FridgeViewModel fridgeViewModel;
  final CookbookViewModel cookbookViewModel;
  final FriendViewModel friendViewModel;

  const MyApp({
    required this.authViewModel,
    required this.userViewModel,
    required this.fridgeViewModel,
    required this.cookbookViewModel,
    required this.friendViewModel,
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
        ChangeNotifierProvider(create: (_) => friendViewModel),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        Provider<IngredientService>(create: (_) => IngredientService()),
      ],
      child: MaterialApp(
        theme: appTheme,
        navigatorObservers: [routeObserver],
        home: AnimatedSplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}
