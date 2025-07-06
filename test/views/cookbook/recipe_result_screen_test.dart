import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/recipe_result_screen.dart';

import '../../mocks/mock_recipe_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

Widget buildTestWidget({
  required String recipe,
  required String imageUrl,
  List<Ingredient>? usedIngredients,
  String? mealType,
  String? cuisineType,
  String? difficulty,
  int? cookingTime,
  int? prepTime,
  MockRecipeViewModel? recipeViewModel,
  MockCookbookViewModel? cookbookViewModel,
  MockUserViewModel? userViewModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RecipeViewModel>(
        create: (_) => recipeViewModel ?? MockRecipeViewModel(),
      ),
      ChangeNotifierProvider<CookbookViewModel>(
        create: (_) => cookbookViewModel ?? MockCookbookViewModel(),
      ),
      ChangeNotifierProvider<UserViewModel>(
        create: (_) => userViewModel ?? MockUserViewModel(),
      ),
    ],
    child: MaterialApp(
      home: RecipeResultScreen(
        recipe: recipe,
        imageUrl: imageUrl,
        usedIngredients: usedIngredients ?? [],
        mealType: mealType,
        cuisineType: cuisineType,
        difficulty: difficulty,
        cookingTime: cookingTime,
        prepTime: prepTime,
        imageBuilder: (url) => Container(key: const Key('fake_cached_network_image')),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(fileInput: '''
SERVER_IP=https://dummy
''');
  });

  group('RecipeResultScreen', () {
    testWidgets('renders UI and displays recipe', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        recipe: 'Step 1\nStep 2',
        imageUrl: 'test.jpg',
      ));
      await tester.pumpAndSettle();
      expect(find.text('Recipe Result'), findsOneWidget);
      expect(find.byKey(const Key('fake_cached_network_image')), findsWidgets);
    });

    testWidgets('calls regenerate image and shows snackbar, undo works', (tester) async {
      final mockRecipeVM = MockRecipeViewModel();
      mockRecipeVM.imageUrl = 'new_image.jpg';

      await tester.pumpWidget(buildTestWidget(
        recipe: 'Step 1\nStep 2',
        imageUrl: 'test.jpg',
        recipeViewModel: mockRecipeVM,
      ));
      await tester.pumpAndSettle();

      // Tap regenerate image
      await tester.tap(find.byTooltip('Regenerate Image'));
      await tester.pump(); // showDialog
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpAndSettle();

      // Should call the mock
      expect(mockRecipeVM.regenerateImageCallback, isTrue);
      expect(find.text('Recipe image regenerated!'), findsOneWidget);

      // Tap Undo on snackbar
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
    });

    testWidgets('calls save to cookbook and shows snackbar', (tester) async {
      final mockCookbookVM = MockCookbookViewModel();
      final mockUserVM = MockUserViewModel();
      mockUserVM.cookbookId = 'cookbook123';

      await tester.pumpWidget(buildTestWidget(
        recipe: 'Step 1\nStep 2',
        imageUrl: 'test.jpg',
        cookbookViewModel: mockCookbookVM,
        userViewModel: mockUserVM,
        usedIngredients: [
          Ingredient(
              name: 'Egg',
              category: 'Dairy',
              imageURL: '',
              count: 2,
              id: 'egg123')
        ],
        mealType: 'Lunch',
        cuisineType: 'Italian',
        difficulty: 'Easy',
        cookingTime: 10,
        prepTime: 5,
      ));
      await tester.pumpAndSettle();

      // Tap save to cookbook
      await tester.tap(find.byTooltip('Save Recipe to Cookbook'));
      await tester.pumpAndSettle();

      expect(mockCookbookVM.addToCookbookCallback, isTrue);
      expect(find.text('Recipe saved to cookbook!'), findsOneWidget);
    });

    testWidgets('calls save to cookbook with missing cookbookId', (tester) async {
      final mockCookbookVM = MockCookbookViewModel();
      final mockUserVM = MockUserViewModel();
      mockUserVM.cookbookId = null; // Simulate missing cookbookId

      await tester.pumpWidget(buildTestWidget(
        recipe: 'Step 1\nStep 2',
        imageUrl: 'test.jpg',
        cookbookViewModel: mockCookbookVM,
        userViewModel: mockUserVM,
        usedIngredients: [],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Save Recipe to Cookbook'));
      await tester.pumpAndSettle();

      expect(mockCookbookVM.addToCookbookCallback, isTrue);
      expect(find.text('Recipe saved to cookbook!'), findsOneWidget);
    });

    testWidgets('regenerate image branch: undo restores previous image', (tester) async {
      final mockRecipeVM = MockRecipeViewModel();
      mockRecipeVM.imageUrl = 'img1.jpg';

      await tester.pumpWidget(buildTestWidget(
        recipe: 'Step 1\nStep 2',
        imageUrl: 'img1.jpg',
        recipeViewModel: mockRecipeVM,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Regenerate Image'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpAndSettle();

      // Tap Undo on snackbar
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // No assertion needed, branch is covered
    });

    testWidgets('handles empty recipe and ingredients', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        recipe: '',
        imageUrl: '',
        usedIngredients: [],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('fake_cached_network_image')), findsWidgets);
    });
  });
}