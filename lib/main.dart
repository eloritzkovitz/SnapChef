import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'core/service_locator.dart';
import 'database/app_database.dart';
import 'providers/connectivity_provider.dart';
import 'services/ingredient_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';
import 'utils/firebase_messaging_util.dart';
import 'utils/navigation_observer.dart';
import 'viewmodels/main_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/shared_recipe_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/ingredient_viewmodel.dart';
import 'viewmodels/fridge_viewmodel.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/cookbook_viewmodel.dart';
import 'viewmodels/notifications_viewmodel.dart';
import 'viewmodels/friend_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/otp_verification_screen.dart';
import 'views/auth/reset_password_screen.dart';
import 'views/auth/confirm_reset_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/main/main_screen.dart';
import 'views/splash/animated_splash_screen.dart';

// RouteObserver for navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Initialize Flutter Local Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// GetIt service locator instance
final GetIt getIt = GetIt.instance;

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

  // Initialize local database
  final db = AppDatabase();

  // Setup GetIt service locator
  setupLocator(db);

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final Widget? loginScreenGoogleButton;
  const MyApp({super.key, this.initialRoute, this.loginScreenGoogleButton});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Singletons/Providers
        Provider<AppDatabase>.value(value: getIt<AppDatabase>()),
        Provider<SyncManager>.value(value: getIt<SyncManager>()),
        Provider<IngredientService>.value(value: getIt<IngredientService>()),
        ChangeNotifierProvider<ConnectivityProvider>.value(
            value: getIt<ConnectivityProvider>()),

        // ViewModels
        ChangeNotifierProvider<MainViewModel>.value(value: getIt<MainViewModel>()),
        ChangeNotifierProvider<AuthViewModel>.value(value: getIt<AuthViewModel>()),
        ChangeNotifierProvider<UserViewModel>.value(value: getIt<UserViewModel>()),
        ChangeNotifierProvider<IngredientViewModel>.value(value: getIt<IngredientViewModel>()),
        ChangeNotifierProvider<FridgeViewModel>.value(value: getIt<FridgeViewModel>()),
        ChangeNotifierProvider<RecipeViewModel>.value(value: getIt<RecipeViewModel>()),
        ChangeNotifierProvider<CookbookViewModel>.value(value: getIt<CookbookViewModel>()),
        ChangeNotifierProvider<SharedRecipeViewModel>.value(value: getIt<SharedRecipeViewModel>()),        
        ChangeNotifierProvider<FriendViewModel>.value(value: getIt<FriendViewModel>()),
        ChangeNotifierProvider<NotificationsViewModel>.value(value: getIt<NotificationsViewModel>() ), 
      ],
      child: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, child) {
          return MaterialApp(
            initialRoute: initialRoute,
            theme: appTheme,
            navigatorObservers: [StatusBarObserver(context), routeObserver],
            home: AnimatedSplashScreen(),
            routes: {
              '/login': (context) => LoginScreen(googleButton: loginScreenGoogleButton),
              '/signup': (context) => SignupScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/confirm-reset': (context) => const ConfirmResetScreen(),
              '/main': (context) => const MainScreen(),             
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/verify') {
                final args = settings.arguments as Map<String, dynamic>?;
                final email = args?['email'] ?? '';
                return MaterialPageRoute(
                  builder: (context) => OtpVerificationScreen(email: email),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
