import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/edit_recipe_screen.dart';
import 'package:snapchef/views/cookbook/view_recipe_screen.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:snapchef/widgets/display_recipe_widget.dart';
import 'package:snapchef/widgets/tts_widget.dart';

import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'IMAGE_BASE_URL=https://example.com/');
  });

  final recipe = Recipe(
    id: '1',
    title: 'Test Recipe',
    description: 'A test recipe',
    mealType: 'Dinner',
    cuisineType: 'Italian',
    difficulty: 'Easy',
    prepTime: 10,
    cookingTime: 20,
    ingredients: [
      Ingredient(
        id: 'ing1',
        name: 'Tomato',
        category: 'Vegetable',
        imageURL: 'assets/images/placeholder_image.png',
        count: 2,
      ),
      Ingredient(
        id: 'ing2',
        name: 'Olive Oil',
        category: 'Oil',
        imageURL: 'assets/images/placeholder_image.png',
        count: 1,
      ),
    ],
    instructions: ['Chop tomatoes', 'Cook for 10 minutes'],
    imageURL: null,
    rating: 4.5,
    isFavorite: false,
    source: RecipeSource.user,
  );

  Widget buildTestWidget({bool isOffline = false, Recipe? overrideRecipe}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CookbookViewModel>(
            create: (_) => MockCookbookViewModel()),
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => MockUserViewModel()),
        ChangeNotifierProvider<NotificationsViewModel>(
            create: (_) => MockNotificationsViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider(isOffline: isOffline)),
      ],
      child: MaterialApp(
        home: ViewRecipeScreen(
            recipe: overrideRecipe ?? recipe, cookbookId: 'cb1'),
      ),
    );
  }

  Future<void> safePumpAndSettle(WidgetTester tester,
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      await tester.pumpAndSettle(timeout);
    } catch (_) {
      // fallback: try a few pumps to avoid infinite hang
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }

  testWidgets('renders and displays recipe details', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget());
      await safePumpAndSettle(tester);

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('Chop tomatoes Cook for 10 minutes'), findsOneWidget);
      expect(find.text('Recipe Details'), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });

  testWidgets('Popup menu actions: Edit, Favorite, Share, Delete (online)',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget());
      await safePumpAndSettle(tester);

      // Open popup menu and tap Edit
      await tester.tap(find.byType(PopupMenuButton<String>));
      await safePumpAndSettle(tester);
      expect(find.text('Edit Recipe'), findsOneWidget);
      await tester.tap(find.text('Edit Recipe'));
      await safePumpAndSettle(tester);

      // Should navigate to EditRecipeScreen
      expect(find.byType(EditRecipeScreen), findsOneWidget);

      // Simulate back navigation (pop the screen)
      await tester.pageBack();
      await safePumpAndSettle(tester);
      expect(find.byType(ViewRecipeScreen), findsOneWidget);

      // Open popup menu and tap Favorite
      await tester.tap(find.byType(PopupMenuButton<String>));
      await safePumpAndSettle(tester);
      expect(find.text('Favorite'), findsOneWidget);
      await tester.tap(find.text('Favorite'));
      await safePumpAndSettle(tester);

      // Open popup menu and tap Share Recipe
      await tester.tap(find.byType(PopupMenuButton<String>));
      await safePumpAndSettle(tester);
      expect(find.text('Share Recipe'), findsOneWidget);
      await tester.tap(find.text('Share Recipe'));
      await safePumpAndSettle(tester);
      expect(find.byType(BottomSheet), findsOneWidget);

      // Dismiss bottom sheet
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pump();

      // Open popup menu and tap Delete Recipe
      await tester.tap(find.byType(PopupMenuButton<String>));
      await safePumpAndSettle(tester);
      expect(find.text('Delete Recipe'), findsOneWidget);
      await tester.tap(find.text('Delete Recipe'));
      await safePumpAndSettle(tester);
      expect(find.text('Are you sure you want to delete this recipe?'),
          findsOneWidget);

      // Cancel delete
      await tester.tap(find.text('Cancel'));
      await safePumpAndSettle(tester);
      expect(find.text('Are you sure you want to delete this recipe?'),
          findsNothing);

      // Open popup menu and tap Delete Recipe again, then confirm
      await tester.tap(find.byType(PopupMenuButton<String>));
      await safePumpAndSettle(tester);
      await tester.tap(find.text('Delete Recipe'));
      await safePumpAndSettle(tester);
      await tester.tap(find.text('Delete'));
      await safePumpAndSettle(tester);
    });
  });

  testWidgets('Popup menu disables and greys out items when offline',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget(isOffline: true));
      await safePumpAndSettle(tester);

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await safePumpAndSettle(tester);

      // Regenerate Image and Share Recipe should be present
      expect(find.text('Regenerate Image'), findsOneWidget);
      expect(find.text('Share Recipe'), findsOneWidget);

      // Their text should be grey
      final Text regenText = tester.widget(find.text('Regenerate Image'));
      expect(regenText.style?.color, Colors.grey);

      final Text shareText = tester.widget(find.text('Share Recipe'));
      expect(shareText.style?.color, Colors.grey);

      // Their icons should be grey
      final regenIconFinder = find.descendant(
        of: find.widgetWithText(Row, 'Regenerate Image'),
        matching: find.byIcon(Icons.image),
      );
      expect(regenIconFinder, findsOneWidget);
      final Icon regenIcon = tester.widget(regenIconFinder);
      expect(regenIcon.color, Colors.grey);

      final shareIconFinder = find.descendant(
        of: find.widgetWithText(Row, 'Share Recipe'),
        matching: find.byIcon(Icons.share),
      );
      expect(shareIconFinder, findsOneWidget);
      final Icon shareIcon = tester.widget(shareIconFinder);
      expect(shareIcon.color, Colors.grey);

      // Try tapping (should not throw, but nothing happens)
      await tester.tap(find.text('Regenerate Image'));
      await tester.pump();
      await tester.tap(find.text('Share Recipe'));
      await tester.pump();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  testWidgets('Popup menu enables and shows items when online', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget(isOffline: false));
      await safePumpAndSettle(tester);

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await safePumpAndSettle(tester);

      // Regenerate Image and Share Recipe should be present
      expect(find.text('Regenerate Image'), findsOneWidget);
      expect(find.text('Share Recipe'), findsOneWidget);

      // Their text should be black
      final Text regenText = tester.widget(find.text('Regenerate Image'));
      expect(regenText.style?.color, Colors.black);

      final Text shareText = tester.widget(find.text('Share Recipe'));
      expect(shareText.style?.color, Colors.black);

      // Their icons should be black
      final regenIconFinder = find.descendant(
        of: find.widgetWithText(Row, 'Regenerate Image'),
        matching: find.byIcon(Icons.image),
      );
      expect(regenIconFinder, findsOneWidget);
      final Icon regenIcon = tester.widget(regenIconFinder);
      expect(regenIcon.color, Colors.black);

      final shareIconFinder = find.descendant(
        of: find.widgetWithText(Row, 'Share Recipe'),
        matching: find.byIcon(Icons.share),
      );
      expect(shareIconFinder, findsOneWidget);
      final Icon shareIcon = tester.widget(shareIconFinder);
      expect(shareIcon.color, Colors.black);
    });
  });

  group('DisplayRecipeWidget', () {
    Widget buildDisplayRecipeWidget(
        {Recipe? overrideRecipe, String? recipeString}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<CookbookViewModel>(
              create: (_) => MockCookbookViewModel()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: DisplayRecipeWidget(
              recipeObject: overrideRecipe,
              recipeString: recipeString,
              cookbookId: 'cb1',
            ),
          ),
        ),
      );
    }

    testWidgets('renders rating, instructions, and TTS button', (tester) async {
      final testRecipe = Recipe(
        id: '2',
        title: 'Widget Recipe',
        description: 'Widget description',
        mealType: 'Breakfast',
        cuisineType: 'American',
        difficulty: 'Easy',
        prepTime: 5,
        cookingTime: 10,
        ingredients: [
          Ingredient(
            id: 'ing1',
            name: 'Bread',
            category: 'Grain',
            imageURL: '',
            count: 2,
          ),
        ],
        instructions: ['Toast bread', 'Spread butter'],
        imageURL: null,
        rating: 2.5,
        isFavorite: false,
        source: RecipeSource.user,
      );

      await tester
          .pumpWidget(buildDisplayRecipeWidget(overrideRecipe: testRecipe));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText && widget.text.toPlainText().contains('2.5')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Toast bread')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Spread butter')),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders markdown from recipeString', (tester) async {
      const String myMarkdown = '''
# Pancakes

- 2 eggs
- 1 cup flour
- 1 cup milk

**Instructions:**
1. Mix all ingredients.
2. Cook on a hot griddle.
''';

      await tester.pumpWidget(buildDisplayRecipeWidget(
        overrideRecipe: null,
        recipeString: myMarkdown,
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Pancakes')),
        findsOneWidget,
      );
    });

    testWidgets('does not render TTS button if recipe is empty',
        (tester) async {
      await tester.pumpWidget(buildDisplayRecipeWidget(
        overrideRecipe: null,
        recipeString: '',
      ));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('TTSWidget', () {
    testWidgets('renders and shows SpeedDial actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: TTSWidget(text: 'Hello world'),
          ),
        ),
      );

      // Main TTS button should be present
      expect(find.byType(TTSWidget), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      // Tap to open SpeedDial (the main FAB)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show Previous, Next, Play, Pause, and Stop buttons
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);

      // Tap Play
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Tap Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // Tap Stop
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump();
    });

    testWidgets('TTSWidget Play, Pause, and Stop update state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: TTSWidget(text: 'Hello\nWorld'),
          ),
        ),
      );

      // Open SpeedDial and Play
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // Stop
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump();
    });

    testWidgets('TTSWidget does not play when text is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: TTSWidget(text: ''),
          ),
        ),
      );

      // Main FAB should be present
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      // Open SpeedDial
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Play (should not crash or change state)
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // After tapping Play, SpeedDial closes, so only main FAB is visible
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });
  });  
}
