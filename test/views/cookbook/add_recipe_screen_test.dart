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
      ChangeNotifierProvider<CookbookViewModel>(
          create: (_) => MockCookbookViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => MockConnectivityProvider()),
    ],
    child: const MaterialApp(
      home: AddRecipeScreen(),
    ),
  );
}

// Helper function to repeatedly pump until a widget is found or a timeout occurs
Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 2)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw Exception('Widget not found: $finder');
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

  testWidgets('AddRecipeScreen validates empty title', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Save without entering a title
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title.'), findsOneWidget);
  });

  testWidgets('AddRecipeScreen validates empty recipe', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter a title
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'My Recipe');
    // Clear the recipe field
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your recipe.'), findsOneWidget);
  });

  testWidgets('AddRecipeScreen can select meal type, cuisine, and difficulty',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Open and select meal type
    final mealTypeDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Meal Type');
    await tester.tap(mealTypeDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('Breakfast'));
    await tester.tap(find.text('Breakfast').last);
    await tester.pumpAndSettle();
    expect(find.text('Breakfast'), findsOneWidget);

    // Open and select cuisine
    final cuisineDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Cuisine');
    await tester.tap(cuisineDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('French'));
    await tester.tap(find.text('French').last);
    await tester.pumpAndSettle();
    expect(find.text('French'), findsOneWidget);

    // Open and select difficulty
    final difficultyDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Difficulty');
    await tester.tap(difficultyDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('Easy'));
    await tester.tap(find.text('Easy').last);
    await tester.pumpAndSettle();
    expect(find.text('Easy'), findsOneWidget);
  });

  testWidgets('AddRecipeScreen saves recipe', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Fill all required fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'My Recipe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'), 'A test');

    // Meal Type
    final mealTypeDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Meal Type');
    await tester.tap(mealTypeDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('Breakfast'));
    await tester.tap(find.text('Breakfast').last);
    await tester.pumpAndSettle();

    // Cuisine
    final cuisineDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Cuisine');
    await tester.tap(cuisineDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('French'));
    await tester.tap(find.text('French').last);
    await tester.pumpAndSettle();

    // Difficulty
    final difficultyDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Difficulty');
    await tester.tap(difficultyDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('Easy'));
    await tester.tap(find.text('Easy').last);
    await tester.pumpAndSettle();

    // Enter recipe text
    await tester.enterText(
      find.byType(TextFormField).last,
      '# My Recipe\n\n**Ingredients:**\n* 1 cup Flour\n\n**Instructions:**\n* Mix ingredients.',
    );

    // Tap Save
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();
  });

  testWidgets('AddRecipeScreen disables Save button while saving',
      (tester) async {
    Widget buildSlowTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>(
              create: (_) => MockUserViewModel()),
          ChangeNotifierProvider<CookbookViewModel>(
              create: (_) => MockCookbookViewModel()),
          ChangeNotifierProvider<ConnectivityProvider>(
              create: (_) => MockConnectivityProvider()),
        ],
        child: const MaterialApp(
          home: AddRecipeScreen(),
        ),
      );
    }

    await tester.pumpWidget(buildSlowTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'My Recipe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'), 'A test');

    // Meal Type
    final mealTypeDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Meal Type');
    await tester.tap(mealTypeDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('Breakfast'));
    await tester.tap(find.text('Breakfast').last);
    await tester.pumpAndSettle();

    // Cuisine
    final cuisineDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Cuisine');
    await tester.tap(cuisineDropdown);
    await tester.pumpAndSettle();

    await pumpUntilFound(tester, find.text('French'));
    await tester.tap(find.text('French').last);
    await tester.pumpAndSettle();

    // Difficulty
    final difficultyDropdown = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.decoration.labelText == 'Difficulty');
    await tester.tap(difficultyDropdown);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('Easy'));
    await tester.tap(find.text('Easy').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).last,
      '# My Recipe\n\n**Ingredients:**\n* 1 cup Flour\n\n**Instructions:**\n* Mix ingredients.',
    );

    // Tap Save
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();   
  });
}
