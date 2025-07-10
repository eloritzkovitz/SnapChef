import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/models/shared_recipe.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/views/cookbook/view_shared_recipe_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_shared_recipe_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';

Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration step = const Duration(milliseconds: 50),
    int maxTries = 20}) async {
  int tries = 0;
  while (!tester.any(finder) && tries < maxTries) {
    await tester.pump(step);
    tries++;
  }
}

Widget buildTestWidget({
  required dynamic sharedRecipe,
  required bool isSharedByMe,
  UserViewModel? userViewModel,
  SharedRecipeViewModel? sharedRecipeViewModel,
  CookbookViewModel? cookbookViewModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserViewModel>(
          create: (_) => userViewModel ?? MockUserViewModel()),
      ChangeNotifierProvider<SharedRecipeViewModel>(
          create: (_) => sharedRecipeViewModel ?? MockSharedRecipeViewModel()),
      ChangeNotifierProvider<CookbookViewModel>(
          create: (_) => cookbookViewModel ?? MockCookbookViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => MockConnectivityProvider()),
    ],
    child: MaterialApp(
      home: ViewSharedRecipeScreen(
        sharedRecipe: sharedRecipe,
        isSharedByMe: isSharedByMe,
      ),
    ),
  );
}

void main() {
  testWidgets('ViewSharedRecipeScreen shows recipe details (shared with me)',
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
      ingredients: [
        Ingredient(
          id: '1',
          name: 'Eggs',
          category: 'Cooking',
          imageURL: '',
          count: 2,
        ),
        Ingredient(
          id: '2',
          name: 'Milk',
          category: 'Dairy',
          imageURL: '',
          count: 2,
        ),
      ],
      instructions: ['Mix', 'Cook'],
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

    final mockSharedRecipeViewModel = MockSharedRecipeViewModel();
    mockSharedRecipeViewModel.sharedWithMeRecipes = [sharedRecipe];
    mockSharedRecipeViewModel.setSharedRecipe(sharedRecipe);

    final mockUserViewModel = MockUserViewModel();
    mockUserViewModel.sharedUserName = 'Alice';

    await tester.pumpWidget(buildTestWidget(
      sharedRecipe: sharedRecipe,
      isSharedByMe: false,
      sharedRecipeViewModel: mockSharedRecipeViewModel,
      userViewModel: mockUserViewModel,
    ));    

    await tester.pump(const Duration(seconds: 1));
    
    expect(find.textContaining('Mix'), findsOneWidget);
    expect(find.textContaining('Cook'), findsOneWidget);
    // The summary should match the UI: "Shared by: Alice"
    expect(find.text('Shared by: Alice'), findsOneWidget);
    // The settings icon should NOT be present
    expect(find.byIcon(Icons.settings), findsNothing);
  });

  testWidgets('ViewSharedRecipeScreen shows recipe details (shared by me)',
      (tester) async {
    final recipe = Recipe(
      id: 'r2',
      title: 'Shared By Me',
      description: 'desc2',
      mealType: 'Dinner',
      cuisineType: 'French',
      difficulty: 'Medium',
      cookingTime: 20,
      prepTime: 10,
      ingredients: [
        Ingredient(
          id: '3',
          name: 'Butter',
          category: 'Dairy',
          imageURL: '',
          count: 2,
        ),
      ],
      instructions: ['Melt'],
      imageURL: '',
      rating: 0,
      source: RecipeSource.ai,
    );
    final groupedRecipe = GroupedSharedRecipe(
      recipe: recipe,
      sharedWithUserIds: ['userB', 'userC'],
    );

    final mockSharedRecipeViewModel = MockSharedRecipeViewModel();
    mockSharedRecipeViewModel.groupedSharedByMeRecipes = [groupedRecipe];
    mockSharedRecipeViewModel.setSharedRecipe(
      SharedRecipe(
        id: 's2',
        recipe: recipe,
        fromUser: 'me',
        toUser: 'userB',
        sharedAt: DateTime.now(),
        status: 'active',
      ),
    );

    final mockUserViewModel = MockUserViewModel();
    mockUserViewModel.sharedUserName = 'Bob';

    await tester.pumpWidget(buildTestWidget(
      sharedRecipe: groupedRecipe,
      isSharedByMe: true,
      sharedRecipeViewModel: mockSharedRecipeViewModel,
      userViewModel: mockUserViewModel,
    ));

    await tester.pump(const Duration(seconds: 1));
    
    expect(find.textContaining('Melt'), findsOneWidget);
    // The summary should match the UI: "Shared with: Bob and 1 other(s)"
    expect(find.text('Shared with: Bob and 1 other(s)'), findsOneWidget);
    // The settings icon should be present
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('ViewSharedRecipeScreen settings icon opens shared with dialog',
      (tester) async {
    final recipe = Recipe(
      id: 'r3',
      title: 'Dialog Test',
      description: 'desc3',
      mealType: 'Snack',
      cuisineType: 'Mexican',
      difficulty: 'Easy',
      cookingTime: 5,
      prepTime: 2,
      ingredients: [],
      instructions: [],
      imageURL: '',
      rating: 0,
      source: RecipeSource.ai,
    );
    final groupedRecipe = GroupedSharedRecipe(
      recipe: recipe,
      sharedWithUserIds: ['userB', 'userC'],
    );

    await tester.pumpWidget(buildTestWidget(
      sharedRecipe: groupedRecipe,
      isSharedByMe: true,
    ));
    await pumpUntilFound(tester, find.byIcon(Icons.settings));

    // Tap the settings icon to open the dialog
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Shared With'));

    expect(find.text('Shared With'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('ViewSharedRecipeScreen shared with dialog closes',
      (tester) async {
    final recipe = Recipe(
      id: 'r4',
      title: 'Dialog Close',
      description: 'desc4',
      mealType: 'Snack',
      cuisineType: 'Mexican',
      difficulty: 'Easy',
      cookingTime: 5,
      prepTime: 2,
      ingredients: [],
      instructions: [],
      imageURL: '',
      rating: 0,
      source: RecipeSource.ai,
    );
    final groupedRecipe = GroupedSharedRecipe(
      recipe: recipe,
      sharedWithUserIds: ['userB'],
    );

    await tester.pumpWidget(buildTestWidget(
      sharedRecipe: groupedRecipe,
      isSharedByMe: true,
    ));
    await pumpUntilFound(tester, find.byIcon(Icons.settings));

    // Open dialog
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Shared With'));

    // Tap close
    await tester.tap(find.text('Close'));
    await tester.pump();
    // Wait for dialog to close
    int tries = 0;
    while (find.text('Shared With').evaluate().isNotEmpty && tries < 10) {
      await tester.pump(const Duration(milliseconds: 50));
      tries++;
    }

    expect(find.text('Shared With'), findsNothing);
  });
}
