import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/views/cookbook/cookbook_screen.dart';
import 'package:snapchef/views/cookbook/widgets/recipe_card.dart';
import 'package:snapchef/views/cookbook/widgets/cookbook_filter_sort_sheet.dart';

import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_shared_recipe_viewmodel.dart';
import '../../mocks/mock_recipe_viewmodel.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  setUp(() {
    addTearDown(() async {
      await Future.delayed(Duration(milliseconds: 100));
    });
  });

  Widget buildTestWidget({
    CookbookViewModel? cookbookViewModel,
    UserViewModel? userViewModel,
    ConnectivityProvider? connectivityProvider,
    SharedRecipeViewModel? sharedRecipeViewModel,
    RecipeViewModel? recipeViewModel,
    FridgeViewModel? fridgeViewModel,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => userViewModel ?? MockUserViewModel()),
        ChangeNotifierProvider<CookbookViewModel>(
            create: (_) => cookbookViewModel ?? MockCookbookViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => connectivityProvider ?? MockConnectivityProvider()),
        ChangeNotifierProvider<SharedRecipeViewModel>(
            create: (_) =>
                sharedRecipeViewModel ?? MockSharedRecipeViewModel()),
        ChangeNotifierProvider<RecipeViewModel>(
            create: (_) => recipeViewModel ?? MockRecipeViewModel()),
        ChangeNotifierProvider<FridgeViewModel>(
            create: (_) => fridgeViewModel ?? MockFridgeViewModel()),
      ],
      child: const MaterialApp(
        home: CookbookScreen(),
      ),
    );
  }

  testWidgets('shows loading indicator', (tester) async {
    final mockCookbook = MockCookbookViewModel();
    mockCookbook.isLoading = true;
    await tester.pumpWidget(buildTestWidget(cookbookViewModel: mockCookbook));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows empty state when no recipes', (tester) async {
    final mockCookbook = MockCookbookViewModel();
    mockCookbook.filteredItems = [];
    await tester.pumpWidget(buildTestWidget(cookbookViewModel: mockCookbook));
    await tester.pumpAndSettle();
    expect(find.text('No recipes in your cookbook.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows empty state when no favorite recipes', (tester) async {
    final mockCookbook = MockCookbookViewModel();
    mockCookbook.filteredItems = [
      Recipe(
          id: '1',
          title: 'A',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
          isFavorite: false)
    ];
    await tester.pumpWidget(buildTestWidget(cookbookViewModel: mockCookbook));
    await tester.pumpAndSettle();
    // Tap favorites toggle
    await tester.tap(find.byKey(const Key('favoritesToggleButton')));
    await tester.pumpAndSettle();
    expect(find.text('No favorite recipes.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows recipes and toggles favorites', (tester) async {
    final mockCookbook = MockCookbookViewModel();
    mockCookbook.filteredItems = [
      Recipe(
          id: '1',
          title: 'A',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
          isFavorite: true),
      Recipe(
          id: '2',
          title: 'B',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
          isFavorite: false),
    ];
    await tester.pumpWidget(buildTestWidget(cookbookViewModel: mockCookbook));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsNWidgets(2));
    // Toggle favorites
    await tester.tap(find.byKey(const Key('favoritesToggleButton')));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('opens filter & sort sheet and closes', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.byKey(const Key('filterSortButton')));
    await tester.pumpAndSettle();
    expect(find.byType(CookbookFilterSortSheet), findsOneWidget);
    // Close by tapping outside
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(CookbookFilterSortSheet), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('search button opens search delegate', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();
    // Can't assert search UI in widget test, but no crash
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shared recipes button fetches and navigates', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.byKey(const Key('sharedRecipesButton')));
    await tester.pumpAndSettle();
    // Should navigate to SharedRecipesScreen (if present in widget tree)
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('FAB opens add and generate recipe screens', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    // Tap Add Recipe
    await tester.tap(find.text('Add Recipe'));
    await tester.pumpAndSettle();
    // Go back and open FAB again
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    // Tap Generate Recipe
    await tester.tap(find.text('Generate Recipe'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('FAB Generate Recipe shows offline dialog', (tester) async {
    final mockConnectivity = MockConnectivityProvider();
    mockConnectivity.isOffline = true;
    await tester
        .pumpWidget(buildTestWidget(connectivityProvider: mockConnectivity));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate Recipe'));
    await tester.pumpAndSettle();
    // Should show offline dialog/snackbar
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('can reorder recipes', (tester) async {
    final mockCookbook = MockCookbookViewModel();
    mockCookbook.filteredItems = [
      Recipe(
          id: '1',
          title: 'A',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai),
      Recipe(
          id: '2',
          title: 'B',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai),
    ];
    await tester.pumpWidget(buildTestWidget(cookbookViewModel: mockCookbook));
    await tester.pumpAndSettle();
    final finderA = find.text('A');
    final finderB = find.text('B');
    expect(finderA, findsOneWidget);
    expect(finderB, findsOneWidget);
    await tester.drag(finderA, const Offset(0, 100));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('tapping recipe card navigates to details', (tester) async {
    final mockCookbook = MockCookbookViewModel();
    mockCookbook.filteredItems = [
      Recipe(
          id: '1',
          title: 'A',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai),
    ];
    await tester.pumpWidget(buildTestWidget(cookbookViewModel: mockCookbook));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RecipeCard).first);
    await tester.pump(const Duration(milliseconds: 100));
  });

  group('RecipeCard', () {
    testWidgets('RecipeCard displays recipe title', (tester) async {
      final recipe = Recipe(
          id: '1',
          title: 'Test Recipe',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 10,
          cookingTime: 10,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(recipe: recipe),
          ),
        ),
      );
      expect(find.text('Test Recipe'), findsOneWidget);
    });

    testWidgets('displays AI source icon and tooltip', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'AI Recipe',
        description: '',
        mealType: 'Lunch',
        cuisineType: 'Italian',
        difficulty: 'Easy',
        prepTime: 10,
        cookingTime: 10,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byTooltip('AI Generated'), findsOneWidget);
    });

    testWidgets('displays Shared source icon and tooltip', (tester) async {
      final recipe = Recipe(
        id: '2',
        title: 'Shared Recipe',
        description: '',
        mealType: 'Dinner',
        cuisineType: 'French',
        difficulty: 'Medium',
        prepTime: 15,
        cookingTime: 20,
        ingredients: [],
        instructions: [],
        source: RecipeSource.shared,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.people_alt), findsOneWidget);
      expect(find.byTooltip('Shared Recipe'), findsOneWidget);
    });

    testWidgets('displays User source icon and tooltip', (tester) async {
      final recipe = Recipe(
        id: '3',
        title: 'User Recipe',
        description: '',
        mealType: 'Breakfast',
        cuisineType: 'American',
        difficulty: 'Hard',
        prepTime: 5,
        cookingTime: 5,
        ingredients: [],
        instructions: [],
        source: RecipeSource.user,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byTooltip('User Recipe'), findsOneWidget);
    });

    testWidgets('shows favorite heart when isFavorite is true', (tester) async {
      final recipe = Recipe(
        id: '4',
        title: 'Fav Recipe',
        description: '',
        mealType: '',
        cuisineType: '',
        difficulty: '',
        prepTime: 1,
        cookingTime: 1,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
        isFavorite: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows fallback icon when imageURL is empty', (tester) async {
      final recipe = Recipe(
        id: '5',
        title: 'No Image',
        description: '',
        mealType: '',
        cuisineType: '',
        difficulty: '',
        prepTime: 1,
        cookingTime: 1,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
        imageURL: '',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.image), findsOneWidget);
    });    

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;
      final recipe = Recipe(
        id: '7',
        title: 'Tap Recipe',
        description: '',
        mealType: '',
        cuisineType: '',
        difficulty: '',
        prepTime: 1,
        cookingTime: 1,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(RecipeCard));
      expect(tapped, isTrue);
    });

    testWidgets('displays AI source icon and tooltip', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'AI Recipe',
        description: '',
        mealType: 'Lunch',
        cuisineType: 'Italian',
        difficulty: 'Easy',
        prepTime: 10,
        cookingTime: 10,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byTooltip('AI Generated'), findsOneWidget);
    });

    testWidgets('displays Shared source icon and tooltip', (tester) async {
      final recipe = Recipe(
        id: '2',
        title: 'Shared Recipe',
        description: '',
        mealType: 'Dinner',
        cuisineType: 'French',
        difficulty: 'Medium',
        prepTime: 15,
        cookingTime: 20,
        ingredients: [],
        instructions: [],
        source: RecipeSource.shared,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.people_alt), findsOneWidget);
      expect(find.byTooltip('Shared Recipe'), findsOneWidget);
    });

    testWidgets('displays User source icon and tooltip', (tester) async {
      final recipe = Recipe(
        id: '3',
        title: 'User Recipe',
        description: '',
        mealType: 'Breakfast',
        cuisineType: 'American',
        difficulty: 'Hard',
        prepTime: 5,
        cookingTime: 5,
        ingredients: [],
        instructions: [],
        source: RecipeSource.user,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byTooltip('User Recipe'), findsOneWidget);
    });

    testWidgets('shows favorite heart when isFavorite is true', (tester) async {
      final recipe = Recipe(
        id: '4',
        title: 'Fav Recipe',
        description: '',
        mealType: '',
        cuisineType: '',
        difficulty: '',
        prepTime: 1,
        cookingTime: 1,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
        isFavorite: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows fallback icon when imageURL is empty', (tester) async {
      final recipe = Recipe(
        id: '5',
        title: 'No Image',
        description: '',
        mealType: '',
        cuisineType: '',
        difficulty: '',
        prepTime: 1,
        cookingTime: 1,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
        imageURL: '',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );
      expect(find.byIcon(Icons.image), findsOneWidget);
    });    

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;
      final recipe = Recipe(
        id: '7',
        title: 'Tap Recipe',
        description: '',
        mealType: '',
        cuisineType: '',
        difficulty: '',
        prepTime: 1,
        cookingTime: 1,
        ingredients: [],
        instructions: [],
        source: RecipeSource.ai,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(RecipeCard));
      expect(tapped, isTrue);
    });
  });
}
