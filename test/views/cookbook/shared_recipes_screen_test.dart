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

Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration step = const Duration(milliseconds: 50),
    int maxTries = 20}) async {
  int tries = 0;
  while (!tester.any(finder) && tries < maxTries) {
    await tester.pump(step);
    tries++;
  }
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
    sharedRecipeViewModel.sharedWithMeRecipes.add(sharedRecipe);

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
    // Use a grouped recipe for "Shared by me"
    final groupedRecipe = GroupedSharedRecipe(
      recipe: recipe,
      sharedWithUserIds: ['userB'],
    );
    final sharedRecipeViewModel = MockSharedRecipeViewModel();
    // Make sure your mock supports this property!
    sharedRecipeViewModel.groupedSharedByMeRecipes = [groupedRecipe];

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

  testWidgets('SharedRecipesScreen switches tabs and preserves state', (tester) async {
  final recipe1 = Recipe(
    id: 'r1',
    title: 'Recipe One',
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
  final recipe2 = Recipe(
    id: 'r2',
    title: 'Recipe Two',
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
  final sharedRecipe1 = SharedRecipe(
    id: 's1',
    recipe: recipe1,
    fromUser: 'userA',
    toUser: 'userB',
    sharedAt: DateTime.now(),
    status: 'active',
  );
  final groupedRecipe2 = GroupedSharedRecipe(
    recipe: recipe2,
    sharedWithUserIds: ['userC'],
  );
  final sharedRecipeViewModel = MockSharedRecipeViewModel();
  sharedRecipeViewModel.sharedWithMeRecipes.add(sharedRecipe1);
  sharedRecipeViewModel.groupedSharedByMeRecipes = [groupedRecipe2];

  await tester.pumpWidget(buildTestWidget(sharedRecipeViewModel: sharedRecipeViewModel));
  await tester.pumpAndSettle();

  // Should show recipe1 in "Shared with me"
  expect(find.text('Recipe One'), findsOneWidget);
  expect(find.text('Recipe Two'), findsNothing);

  // Switch to "Shared by me"
  await tester.tap(find.text('Shared by me'));
  await tester.pumpAndSettle();

  // Should show recipe2 in "Shared by me"
  expect(find.text('Recipe Two'), findsOneWidget);
  expect(find.text('Recipe One'), findsNothing);

  // Switch back to "Shared with me"
  await tester.tap(find.text('Shared with me'));
  await tester.pumpAndSettle();

  expect(find.text('Recipe One'), findsOneWidget);
  expect(find.text('Recipe Two'), findsNothing);
});

testWidgets('SharedRecipesScreen shows multiple sharedWithMe recipes', (tester) async {
  final recipes = List.generate(3, (i) => Recipe(
    id: 'r$i',
    title: 'Recipe $i',
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
  ));
  final sharedRecipeViewModel = MockSharedRecipeViewModel();
  for (final recipe in recipes) {
    sharedRecipeViewModel.sharedWithMeRecipes.add(SharedRecipe(
      id: 's${recipe.id}',
      recipe: recipe,
      fromUser: 'userA',
      toUser: 'userB',
      sharedAt: DateTime.now(),
      status: 'active',
    ));
  }

  await tester.pumpWidget(buildTestWidget(sharedRecipeViewModel: sharedRecipeViewModel));
  await tester.pumpAndSettle();

  for (final recipe in recipes) {
    expect(find.text(recipe.title), findsOneWidget);
  }
});

testWidgets('SharedRecipesScreen shows multiple sharedByMe recipes', (tester) async {
  final recipes = List.generate(2, (i) => Recipe(
    id: 'r$i',
    title: 'SharedByMe $i',
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
  ));
  final sharedRecipeViewModel = MockSharedRecipeViewModel();
  sharedRecipeViewModel.groupedSharedByMeRecipes = recipes
      .map((r) => GroupedSharedRecipe(recipe: r, sharedWithUserIds: ['userX']))
      .toList();

  await tester.pumpWidget(buildTestWidget(sharedRecipeViewModel: sharedRecipeViewModel));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Shared by me'));
  await tester.pumpAndSettle();

  for (final recipe in recipes) {
    expect(find.text(recipe.title), findsOneWidget);
  }
});

testWidgets('SharedRecipesScreen shows correct empty state after removing all recipes', (tester) async {
  final sharedRecipeViewModel = MockSharedRecipeViewModel();
  sharedRecipeViewModel.sharedWithMeRecipes.clear();
  sharedRecipeViewModel.groupedSharedByMeRecipes = [];

  await tester.pumpWidget(buildTestWidget(sharedRecipeViewModel: sharedRecipeViewModel));
  await tester.pumpAndSettle();

  expect(find.textContaining('No recipes'), findsOneWidget);

  await tester.tap(find.text('Shared by me'));
  await tester.pumpAndSettle();

  expect(find.textContaining('not shared any recipes'), findsOneWidget);
});
}
