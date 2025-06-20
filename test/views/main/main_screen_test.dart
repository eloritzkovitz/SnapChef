import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/views/main/main_screen.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_main_viewmodel.dart';
import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_recipe_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel_test.mocks.dart'
    hide MockConnectivityProvider;

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'IMAGE_BASE_URL=https://example.com/');
  });
  
  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
      ChangeNotifierProvider<MainViewModel>(
          create: (_) => MockMainViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => MockConnectivityProvider()),
      ChangeNotifierProvider<UserViewModel>(
          create: (_) => MockUserViewModel()),
      ChangeNotifierProvider<IngredientViewModel>(
          create: (_) => MockIngredientViewModel()),
      ChangeNotifierProvider<FridgeViewModel>(
          create: (_) => MockFridgeViewModel()),
      ChangeNotifierProvider<RecipeViewModel>(
          create: (_) => MockRecipeViewModel()),
      ChangeNotifierProvider<CookbookViewModel>(
          create: (_) => MockCookbookViewModel()),
      ChangeNotifierProvider<NotificationsViewModel>(
          create: (_) => MockNotificationsViewModel()),              
    ],
      child: const MaterialApp(
        home: MainScreen(),
      ),
    );
  }

  testWidgets('MainScreen renders and shows bottom navigation', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Check for BottomNavigationBar and its items
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Fridge'), findsOneWidget);
    expect(find.text('Cookbook'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('MainScreen switches tabs when tapped', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap on "Fridge" tab
    await tester.tap(find.text('Fridge'));
    await tester.pumpAndSettle();

    // Tap on "Cookbook" tab
    await tester.tap(find.text('Cookbook'));
    await tester.pumpAndSettle();

    // Tap on "Profile" tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Tap on "Notifications" tab
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    // No exceptions = pass
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
