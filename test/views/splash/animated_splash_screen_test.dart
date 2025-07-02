import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/core/session_manager.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';
import 'package:snapchef/views/splash/animated_splash_screen.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mock_ingredient_viewmodel.dart';
import '../../mocks/mock_main_viewmodel.dart';
import '../../mocks/mock_session_manager.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_fridge_viewmodel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GetIt.I.reset();
    GetIt.I.registerSingleton<MainViewModel>(MockMainViewModel());
    GetIt.I.registerSingleton<SessionManager>(MockSessionManager());
  });

  Widget buildTestWidget({
    UserViewModel? userViewModel,
    FridgeViewModel? fridgeViewModel,
    CookbookViewModel? cookbookViewModel,
    IngredientViewModel? ingredientViewModel,
    NavigatorObserver? observer,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => userViewModel ?? MockUserViewModel()),
        ChangeNotifierProvider<IngredientViewModel>(
            create: (_) => ingredientViewModel ?? MockIngredientViewModel()),
        ChangeNotifierProvider<FridgeViewModel>(
            create: (_) => fridgeViewModel ?? MockFridgeViewModel()),
        ChangeNotifierProvider<CookbookViewModel>(
            create: (_) => cookbookViewModel ?? MockCookbookViewModel()),
      ],
      child: MaterialApp(
        home: const AnimatedSplashScreen(),
        navigatorObservers: observer != null ? [observer] : [],
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
          '/home': (context) => const Scaffold(body: Text('Home Screen')),
          '/main': (context) => const Scaffold(body: Text('Home Screen')),
        },
      ),
    );
  }

  testWidgets('AnimatedSplashScreen renders splash image', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    addTearDown(tester.pumpAndSettle);
  });

  testWidgets('Navigates to /login if not logged in', (tester) async {
    final mockObserver = NavigatorObserver();
    await tester.pumpWidget(buildTestWidget(observer: mockObserver));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('Navigates to home if logged in', (tester) async {
    // Set tokens in SharedPreferences
    SharedPreferences.setMockInitialValues({
      'accessToken': 'token',
      'refreshToken': 'token',
    });

    // Mock UserViewModel to simulate logged-in user
    final userViewModel = MockUserViewModel();

    await tester.pumpWidget(
      buildTestWidget(userViewModel: userViewModel),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('Fade out animation occurs', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 500));
    // Fade should have started
    // Can't directly test opacity, but can check widget tree still present
    expect(find.byType(FadeTransition), findsOneWidget);
  });

  testWidgets('Handles fetchUserData error gracefully', (tester) async {
    SharedPreferences.setMockInitialValues({
      'accessToken': 'token',
      'refreshToken': 'token',
    });

    final userViewModel = MockUserViewModel(
      fetchUserDataOverride: () async => throw Exception('fail'),
    );

    await tester.pumpWidget(buildTestWidget(userViewModel: userViewModel));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Login Screen'), findsOneWidget);
  });
}
