import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/view_recipe_screen.dart';
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';

void main() {
  // Ensure Flutter binding is initialized for all tests
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

  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CookbookViewModel>(
            create: (_) => MockCookbookViewModel()),
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => MockUserViewModel()),
        ChangeNotifierProvider<NotificationsViewModel>(
            create: (_) => MockNotificationsViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider()),
      ],
      child: MaterialApp(
        home: ViewRecipeScreen(recipe: recipe, cookbookId: 'cb1'),
      ),
    );
  }

  testWidgets('ViewRecipeScreen renders and displays recipe details',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget());
      // Use a limited settle to avoid infinite animation issues
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('A test recipe'), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });

  testWidgets('Popup menu actions work', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap Edit
      expect(find.text('Edit Recipe'), findsOneWidget);
      await tester.tap(find.text('Edit Recipe'));
      await tester.pump(const Duration(milliseconds: 100));

      // Open popup menu again
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap Favorite/Unfavorite
      expect(find.text('Favorite'), findsOneWidget);
      await tester.tap(find.text('Favorite'));
      await tester.pump(const Duration(milliseconds: 100));

      // Open popup menu again
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap Share Recipe
      expect(find.text('Share Recipe'), findsOneWidget);
      await tester.tap(find.text('Share Recipe'));
      await tester.pump(const Duration(milliseconds: 100));

      // Open popup menu again
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap Delete Recipe
      expect(find.text('Delete Recipe'), findsOneWidget);
      await tester.tap(find.text('Delete Recipe'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Confirm delete dialog appears
      expect(find.text('Delete Recipe'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this recipe?'),
          findsOneWidget);
    });
  });
}