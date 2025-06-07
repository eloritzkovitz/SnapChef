import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'providers/connectivity_provider.dart';
import 'repositories/fridge_repository.dart';
import 'services/fridge_service.dart';
import 'services/ingredient_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';
import 'utils/firebase_messaging_util.dart';
import 'utils/navigation_observer.dart';
import 'viewmodels/main_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/ingredient_viewmodel.dart';
import 'viewmodels/fridge_viewmodel.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/cookbook_viewmodel.dart';
import 'viewmodels/notifications_viewmodel.dart';
import 'viewmodels/friend_viewmodel.dart';
import 'views/auth/login_screen.dart';
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

  // Run the app
  runApp(MyApp(
    db: db,
  ));
}

class MyApp extends StatelessWidget {
  final AppDatabase db;

  const MyApp({
    required this.db,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Singletons/services
    final connectivityProvider = ConnectivityProvider();
    final syncManager = SyncManager(connectivityProvider);
    final ingredientService = IngredientService();
    final fridgeService = FridgeService();
    final fridgeRepository = FridgeRepository(
      database: db,
      fridgeService: fridgeService,
    );

    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<SyncManager>.value(value: syncManager),
        Provider<IngredientService>.value(value: ingredientService),
        ChangeNotifierProvider<ConnectivityProvider>.value(
            value: connectivityProvider),

        // ViewModels
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(
            database: db,
            connectivityProvider: connectivityProvider,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FridgeViewModel(
            connectivityProvider: connectivityProvider,
            syncManager: syncManager,
            fridgeRepository: fridgeRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(
          create: (_) => CookbookViewModel(
            database: db,
            connectivityProvider: connectivityProvider,
          ),
        ),
        ChangeNotifierProvider(create: (_) => FriendViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(
          create: (_) => IngredientViewModel(
            ingredientService,
            db.ingredientDao,
          ),
        ),
      ],
      child: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, child) {
          return MaterialApp(
            theme: appTheme,
            navigatorObservers: [StatusBarObserver(context), routeObserver],
            home: AnimatedSplashScreen(),
            routes: {
              '/login': (context) => LoginScreen(),
              '/signup': (context) => SignupScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/confirm-reset': (context) => const ConfirmResetScreen(),
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}
