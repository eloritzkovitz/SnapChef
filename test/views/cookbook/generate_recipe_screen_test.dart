import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/generate_recipe_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_recipe_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

Widget buildTestWidget() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserViewModel>(create: (_) => MockUserViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(create: (_) => MockConnectivityProvider()),
      ChangeNotifierProvider<RecipeViewModel>(create: (_) => MockRecipeViewModel()),
      ChangeNotifierProvider<FridgeViewModel>(create: (_) => MockFridgeViewModel()),
    ],
    child: const MaterialApp(
      home: GenerateRecipeScreen(),
    ),
  );
}

void main() {
  testWidgets('GenerateRecipeScreen shows Generate Recipe title', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Generate Recipe'), findsOneWidget);
  });
}