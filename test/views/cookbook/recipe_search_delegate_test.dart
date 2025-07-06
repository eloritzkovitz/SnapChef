import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/recipe_search_delegate.dart';
import 'package:snapchef/views/cookbook/widgets/recipe_card.dart';

import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

void main() {
  late MockCookbookViewModel mockCookbookViewModel;
  late MockUserViewModel mockUserViewModel;

  setUp(() {
    mockCookbookViewModel = MockCookbookViewModel();
    mockUserViewModel = MockUserViewModel();
  });

  Widget buildTestApp({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CookbookViewModel>.value(
            value: mockCookbookViewModel),
        ChangeNotifierProvider<UserViewModel>.value(value: mockUserViewModel),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
        onGenerateRoute: (settings) {          
          return null;
        },
      ),
    );
  }

  Future<void> pumpSearchDelegate(
    WidgetTester tester, {
    required String query,
    List<Recipe>? recipes,
    bool suggestions = false,
  }) async {
    mockCookbookViewModel.filteredItems = recipes ?? [];    
    mockCookbookViewModel.searchRecipesOverride = (q) {
      if (q.isEmpty) return recipes ?? [];
      return (recipes ?? [])
          .where((r) => r.title.toLowerCase().contains(q.toLowerCase()))
          .toList();
    };
    await tester.pumpWidget(buildTestApp(
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: RecipeSearchDelegate(),
            );
          },
          child: const Text('Search'),
        ),
      ),
    ));
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), query);
    if (!suggestions) {
      await tester.testTextInput.receiveAction(TextInputAction.search);
    }
    await tester.pumpAndSettle();
  }

  testWidgets('shows no recipes found when search yields nothing',
      (tester) async {
    await pumpSearchDelegate(tester, query: 'anything', recipes: []);
    expect(find.text('No recipes found.'), findsOneWidget);
  });

  testWidgets('shows recipe cards when search yields results', (tester) async {
    await pumpSearchDelegate(
      tester,
      query: 'Pasta',
      recipes: [
        Recipe(
          id: '1',
          title: 'Pasta',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
        ),
      ],
    );
    expect(find.widgetWithText(RecipeCard, 'Pasta'), findsOneWidget);
  });  

  testWidgets('shows no matching recipes in suggestions when none match',
      (tester) async {
    await pumpSearchDelegate(tester,
        query: 'none', recipes: [], suggestions: true);
    expect(find.text('No matching recipes.'), findsOneWidget);
  });

  testWidgets('shows suggestions when recipes match', (tester) async {
    await pumpSearchDelegate(
      tester,
      query: 'Soup',
      recipes: [
        Recipe(
          id: '2',
          title: 'Soup',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
        ),
      ],
      suggestions: true,
    );
    expect(find.widgetWithText(RecipeCard, 'Soup'), findsOneWidget);
  });  

  testWidgets('shows suggestions when query is empty', (tester) async {
    await pumpSearchDelegate(
      tester,
      query: '',
      recipes: [
        Recipe(
          id: '4',
          title: 'Bread',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
        ),
      ],
      suggestions: true,
    );
    expect(find.widgetWithText(RecipeCard, 'Bread'), findsOneWidget);
  });

  testWidgets('shows results when query is empty', (tester) async {
    await pumpSearchDelegate(
      tester,
      query: '',
      recipes: [
        Recipe(
          id: '5',
          title: 'Cake',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
        ),
      ],
      suggestions: false,
    );
    expect(find.widgetWithText(RecipeCard, 'Cake'), findsOneWidget);
  });

  testWidgets('handles special characters in query', (tester) async {
    await pumpSearchDelegate(
      tester,
      query: '@#\$%',
      recipes: [
        Recipe(
          id: '6',
          title: '@#\$% Special',
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 1,
          cookingTime: 1,
          ingredients: [],
          instructions: [],
          source: RecipeSource.ai,
        ),
      ],
      suggestions: false,
    );
    expect(find.widgetWithText(RecipeCard, '@#\$% Special'), findsOneWidget);
  });

  testWidgets('buildActions returns actions', (tester) async {
    final delegate = RecipeSearchDelegate();
    await tester.pumpWidget(buildTestApp(
      child: Builder(
        builder: (context) {
          final actions = delegate.buildActions(context);
          expect(actions, isNotNull);
          return Container();
        },
      ),
    ));
  });

  group('buildResults', () {
    testWidgets('shows no recipes found when search yields nothing',
        (tester) async {
      await pumpSearchDelegate(tester, query: 'anything', recipes: []);
      expect(find.text('No recipes found.'), findsOneWidget);
    });

    testWidgets('shows recipe cards when search yields results',
        (tester) async {
      await pumpSearchDelegate(
        tester,
        query: 'Pasta',
        recipes: [
          Recipe(
            id: '1',
            title: 'Pasta',
            description: '',
            mealType: '',
            cuisineType: '',
            difficulty: '',
            prepTime: 1,
            cookingTime: 1,
            ingredients: [],
            instructions: [],
            source: RecipeSource.ai,
          ),
        ],
      );
      expect(find.widgetWithText(RecipeCard, 'Pasta'), findsOneWidget);
    });    
  });

  group('buildSuggestions', () {
    testWidgets('shows no matching recipes in suggestions when none match',
        (tester) async {
      await pumpSearchDelegate(tester,
          query: 'none', recipes: [], suggestions: true);
      expect(find.text('No matching recipes.'), findsOneWidget);
    });

    testWidgets('shows suggestions when recipes match', (tester) async {
      await pumpSearchDelegate(
        tester,
        query: 'Soup',
        recipes: [
          Recipe(
            id: '2',
            title: 'Soup',
            description: '',
            mealType: '',
            cuisineType: '',
            difficulty: '',
            prepTime: 1,
            cookingTime: 1,
            ingredients: [],
            instructions: [],
            source: RecipeSource.ai,
          ),
        ],
        suggestions: true,
      );
      expect(find.widgetWithText(RecipeCard, 'Soup'), findsOneWidget);
    });    
  });
}