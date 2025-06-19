import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/views/cookbook/shared_recipes_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_shared_recipe_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';

Widget buildTestWidget() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SharedRecipeViewModel>(create: (_) => MockSharedRecipeViewModel()),
      ChangeNotifierProvider<CookbookViewModel>(create: (_) => MockCookbookViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(create: (_) => MockConnectivityProvider()),
    ],
    child: const MaterialApp(
      home: SharedRecipesScreen(),
    ),
  );
}

void main() {
  testWidgets('SharedRecipesScreen shows chips', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Shared with me'), findsOneWidget);
    expect(find.text('Shared by me'), findsOneWidget);
  });

  testWidgets('SharedRecipesScreen shows empty state', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.textContaining('No recipes'), findsOneWidget);
  });
}