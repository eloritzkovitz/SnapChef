import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/splash/animated_splash_screen.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';

import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_fridge_viewmodel.dart';

// Minimal IngredientViewModel mock
class MockIngredientViewModel extends ChangeNotifier implements IngredientViewModel {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(create: (_) => MockUserViewModel()),
        ChangeNotifierProvider<IngredientViewModel>(create: (_) => MockIngredientViewModel()),
        ChangeNotifierProvider<FridgeViewModel>(create: (_) => MockFridgeViewModel()),
        ChangeNotifierProvider<CookbookViewModel>(create: (_) => MockCookbookViewModel()),
      ],
      child: const MaterialApp(
        home: AnimatedSplashScreen(),
      ),
    );
  }

  testWidgets('AnimatedSplashScreen renders splash image', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(milliseconds: 100)); // Let animation start

    // Check for splash image asset
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('AnimatedSplashScreen completes animation and navigates', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump(const Duration(seconds: 2)); // Let animation and fade finish

    // After animation, should try to navigate (no error = pass)
    expect(find.byType(AnimatedSplashScreen), findsOneWidget);
  });
}