import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/add_recipe_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';

Widget buildTestWidget() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserViewModel>(create: (_) => MockUserViewModel()),
      ChangeNotifierProvider<CookbookViewModel>(create: (_) => MockCookbookViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(create: (_) => MockConnectivityProvider()),
    ],
    child: const MaterialApp(
      home: AddRecipeScreen(),
    ),
  );
}

void main() {
  testWidgets('AddRecipeScreen shows title field', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget);
  });

  testWidgets('AddRecipeScreen shows meal type dropdown', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Meal Type'), findsOneWidget);
  });
}