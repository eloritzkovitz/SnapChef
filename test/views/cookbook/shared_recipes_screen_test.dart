import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/models/shared_recipe.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/shared_recipes_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_shared_recipe_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

Widget buildTestWidget({
  SharedRecipeViewModel? sharedRecipeViewModel,
  CookbookViewModel? cookbookViewModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserViewModel>(create: (_) => MockUserViewModel()),
      ChangeNotifierProvider<SharedRecipeViewModel>(
          create: (_) => sharedRecipeViewModel ?? MockSharedRecipeViewModel()),
      ChangeNotifierProvider<CookbookViewModel>(
          create: (_) => cookbookViewModel ?? MockCookbookViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => MockConnectivityProvider()),
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

  testWidgets('SharedRecipesScreen shows empty state for "Shared with me"',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.textContaining('No recipes'), findsOneWidget);
  });

  testWidgets('SharedRecipesScreen shows empty state for "Shared by me"',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap the "Shared by me" chip
    await tester.tap(find.text('Shared by me'));
    await tester.pumpAndSettle();

    expect(find.textContaining('not shared any recipes'), findsOneWidget);
  });

  testWidgets('SharedRecipesScreen shows loading indicator', (tester) async {
    final loadingCookbookViewModel = MockCookbookViewModel()..isLoading = true;
    await tester.pumpWidget(
        buildTestWidget(cookbookViewModel: loadingCookbookViewModel));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('SharedRecipesScreen shows sharedWithMe recipe and navigates',
      (tester) async {
    final recipe = Recipe(
      id: 'r1',
      title: 'Test Recipe',
      description: 'desc',
      mealType: 'Lunch',
      cuisineType: 'Italian',
      difficulty: 'Easy',
      cookingTime: 10,
      prepTime: 5,
      ingredients: [],
      instructions: [],
      imageURL: '',
      rating: 0,
      source: RecipeSource.ai,
    );
    final sharedRecipe = SharedRecipe(
      id: 's1',
      recipe: recipe,
      fromUser: 'userA',
      toUser: 'userB',
      sharedAt: DateTime.now(),
      status: 'active',
    );
    final sharedRecipeViewModel = MockSharedRecipeViewModel();
    sharedRecipeViewModel.sharedWithMeRecipes!.add(sharedRecipe);

    await tester.pumpWidget(
        buildTestWidget(sharedRecipeViewModel: sharedRecipeViewModel));
    await tester.pumpAndSettle();    

    // Tap the recipe card to navigate
    await tester.tap(find.text('Test Recipe'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Test Recipe'), findsWidgets);
  });

  testWidgets('SharedRecipesScreen shows sharedByMe recipe and navigates',
      (tester) async {
    final recipe = Recipe(
      id: 'r2',
      title: 'Shared By Me Recipe',
      description: 'desc',
      mealType: 'Dinner',
      cuisineType: 'French',
      difficulty: 'Medium',
      cookingTime: 20,
      prepTime: 10,
      ingredients: [],
      instructions: [],
      imageURL: '',
      rating: 0,
      source: RecipeSource.ai,
    );
    final sharedRecipe = SharedRecipe(
      id: 's2',
      recipe: recipe,
      fromUser: 'userA',
      toUser: 'userB',
      sharedAt: DateTime.now(),
      status: 'active',
    );
    final sharedRecipeViewModel = MockSharedRecipeViewModel();
    sharedRecipeViewModel.sharedByMeRecipes!.add(sharedRecipe);

    await tester.pumpWidget(
        buildTestWidget(sharedRecipeViewModel: sharedRecipeViewModel));
    await tester.pumpAndSettle();

    // Tap the "Shared by me" chip
    await tester.tap(find.text('Shared by me'));
    await tester.pumpAndSettle();

    // Tap the recipe card to navigate
    await tester.tap(find.text('Shared By Me Recipe'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Shared By Me Recipe'), findsWidgets);
  });
}
