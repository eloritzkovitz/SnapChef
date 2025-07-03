import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/database/app_database.dart' hide User;
import 'package:snapchef/models/user.dart';
import 'package:snapchef/repositories/user_repository.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/views/profile/public_profile_screen.dart';
import 'package:snapchef/views/profile/widgets/profile_details.dart';

import '../../mocks/mock_app_database.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_ingredient_viewmodel.dart';
import '../../mocks/mock_services.dart';
import '../../mocks/mock_user_repository.dart';
import '../../mocks/mock_user_viewmodel.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final getIt = GetIt.instance;
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerSingleton<AppDatabase>(MockAppDatabase());
  }
  if (!getIt.isRegistered<ConnectivityProvider>()) {
    getIt.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
  }
  if (!getIt.isRegistered<SocketService>()) {
    getIt.registerSingleton<SocketService>(MockSocketService());
  }
  if (!getIt.isRegistered<UserRepository>()) {
    getIt.registerSingleton<UserRepository>(MockUserRepository());
  }
  if (!getIt.isRegistered<FriendService>()) {
    getIt.registerSingleton<FriendService>(MockFriendService());
  }

  group('PublicProfileScreen', () {
    testWidgets('renders PublicProfileScreen and ProfileDetails', (tester) async {
      final user = User(
        id: 'u2',
        firstName: 'Public',
        lastName: 'User',
        email: 'public@example.com',
        fridgeId: 'fridge2',
        cookbookId: 'cb2',
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>(
              create: (_) => MockUserViewModel()..setUser(user),
            ),
            ChangeNotifierProvider<IngredientViewModel>(
              create: (_) => MockIngredientViewModel(),
            ),
            ChangeNotifierProvider<ConnectivityProvider>(
              create: (_) => MockConnectivityProvider(),
            ),
          ],
          child: MaterialApp(
            home: PublicProfileScreen(user: user),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PublicProfileScreen), findsOneWidget);
      expect(find.byType(ProfileDetails), findsOneWidget);
      expect(find.text('View Profile'), findsOneWidget);
    });
  });
}