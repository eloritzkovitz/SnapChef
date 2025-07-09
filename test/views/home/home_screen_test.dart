import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/database/app_database.dart' hide Recipe;
import 'package:snapchef/models/recipe.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/services/recipe_service.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/views/home/home_screen.dart';
import 'package:snapchef/views/home/widgets/favorites_gallery.dart';
import 'package:snapchef/views/home/widgets/quick_actions.dart';

import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../mocks/mock_app_database.dart';
import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_ingredient_service.dart';
import '../../mocks/mock_recipe_service.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';

class TestRecipe extends Recipe {
  TestRecipe(String title, {super.isFavorite, super.imageURL, int? rating})
      : super(
          id: title,
          title: title,
          description: '',
          mealType: '',
          cuisineType: '',
          difficulty: '',
          prepTime: 0,
          cookingTime: 0,
          ingredients: [],
          instructions: [],
          rating: rating?.toDouble() ?? 0,
          source: RecipeSource.user,
        );
}

void main() {
  setUp(() async {
    await dotenv.load();
    GetIt.I.reset();
    GetIt.I.registerSingleton<IngredientService>(MockIngredientService());
    GetIt.I.registerSingleton<RecipeService>(MockRecipeService());
    final db = MockAppDatabase();
    GetIt.I.registerSingleton<AppDatabase>(db);
    addTearDown(() async => await db.close());
  });

  Widget buildTestWidget({
    ConnectivityProvider? connectivity,
    UserViewModel? user,
    IngredientViewModel? ingredientViewModel,
    FridgeViewModel? fridgeViewModel,
    RecipeViewModel? recipeViewModel,
    CookbookViewModel? cookbook,
    CarouselSliderController? carouselController,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => user ?? MockUserViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => connectivity ?? MockConnectivityProvider()),
        ChangeNotifierProvider<IngredientViewModel>(
            create: (_) => ingredientViewModel ?? IngredientViewModel()),
        ChangeNotifierProvider<FridgeViewModel>(
            create: (_) => fridgeViewModel ?? MockFridgeViewModel()),
        ChangeNotifierProvider<RecipeViewModel>(
            create: (_) => recipeViewModel ?? RecipeViewModel()),
        ChangeNotifierProvider<CookbookViewModel>(
            create: (_) => cookbook ?? MockCookbookViewModel()),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) =>
              HomeScreen(carouselController: carouselController),
        ),
      ),
    );
  }

  testWidgets('HomeScreen displays greeting, title, welcome, and widgets',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('SnapChef'), findsOneWidget);
    expect(find.textContaining('Test'), findsOneWidget);
    expect(find.text('Welcome back to SnapChef! Let’s get cooking.'),
        findsOneWidget);
    expect(find.byType(QuickActions), findsOneWidget);
    expect(find.byType(FavoritesGallery), findsOneWidget);
  });

  testWidgets('HomeScreen shows offline UI', (tester) async {
    final offlineProvider = MockConnectivityProvider()..isOffline = true;
    await tester.pumpWidget(buildTestWidget(connectivity: offlineProvider));
    await tester.pumpAndSettle();

    expect(find.textContaining('offline', findRichText: true), findsWidgets);
    expect(find.byType(QuickActions), findsOneWidget);
    expect(find.byType(FavoritesGallery), findsOneWidget);
  });

  testWidgets('QuickActions: Add Ingredients opens search', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ActionChip, 'Add Ingredients'));
    await tester.pumpAndSettle();
    // Should show a search bar
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('QuickActions: Generate Recipe navigates when online',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ActionChip, 'Generate Recipe'));
    await tester.pumpAndSettle();
    expect(find.text('Generate'), findsOneWidget);
  });

  testWidgets('QuickActions: Add Recipe navigates', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ActionChip, 'Add Recipe'));
    await tester.pumpAndSettle();
    expect(find.text('Add Recipe'), findsOneWidget);
  });

  testWidgets('QuickActions: Generate Recipe is disabled when offline',
      (tester) async {
    final offlineProvider = MockConnectivityProvider()..isOffline = true;
    await tester.pumpWidget(buildTestWidget(connectivity: offlineProvider));
    await tester.pumpAndSettle();

    final chip = tester
        .widget<ActionChip>(find.widgetWithText(ActionChip, 'Generate Recipe'));
    expect(chip.onPressed, isNull);
  });

  testWidgets('FavoritesGallery shows offline state', (tester) async {
    final offlineProvider = MockConnectivityProvider()..isOffline = true;
    await tester.pumpWidget(buildTestWidget(connectivity: offlineProvider));
    await tester.pumpAndSettle();

    expect(find.textContaining('offline', findRichText: true), findsWidgets);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('FavoritesGallery shows empty state', (tester) async {
    final cookbook = MockCookbookViewModel()..filteredItems = [];
    await tester.pumpWidget(buildTestWidget(cookbook: cookbook));
    await tester.pumpAndSettle();

    expect(find.textContaining('no favorite recipes'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('FavoritesGallery shows single favorite', (tester) async {
    final recipe = TestRecipe('Favorite 1', isFavorite: true);
    final cookbook = MockCookbookViewModel()..filteredItems = [recipe];
    await tester.pumpWidget(buildTestWidget(cookbook: cookbook));
    await tester.pumpAndSettle();

    expect(find.text('Favorite 1'), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets);
  });

  testWidgets('FavoritesGallery shows carousel for multiple favorites',
      (tester) async {
    final recipes = [
      TestRecipe('Favorite 1', isFavorite: true),
      TestRecipe('Favorite 2', isFavorite: true),
    ];
    final controller = CarouselSliderController();
    final cookbook = MockCookbookViewModel()..filteredItems = recipes;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(800, 600)),
        child: SizedBox(
          width: 800,
          height: 600,
          child: buildTestWidget(
            cookbook: cookbook,
            carouselController: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ensure the first favorite is visible
    expect(find.text('Favorite 1'), findsOneWidget);

    // Use the controller to go to the next page
    controller.nextPage();
    await tester.pumpAndSettle();

    // Now the second favorite should be visible
    expect(find.text('Favorite 2'), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets);
  });

  testWidgets(
      'FavoritesGallery single favorite with no imageURL shows default icon',
      (tester) async {
    final recipe = TestRecipe('No Image', isFavorite: true, imageURL: '');
    final cookbook = MockCookbookViewModel()..filteredItems = [recipe];
    await tester.pumpWidget(buildTestWidget(cookbook: cookbook));
    await tester.pumpAndSettle();

    // Should show the default image icon
    expect(find.byIcon(Icons.image), findsOneWidget);
    expect(find.text('No Image'), findsOneWidget);
  });

  testWidgets(
      'FavoritesGallery single favorite with invalid imageURL shows not supported icon',
      (tester) async {
    final recipe = TestRecipe('Broken Image',
        isFavorite: true, imageURL: 'http://invalid.url/image.png');
    final cookbook = MockCookbookViewModel()..filteredItems = [recipe];
    await tester.pumpWidget(buildTestWidget(cookbook: cookbook));
    await tester.pumpAndSettle();

    // Simulate image load failure
    final image = find.byType(Image).first;
    final element = tester.element(image);
    final widget = element.widget as Image;
    widget.errorBuilder?.call(element, Exception(), StackTrace.current);

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    expect(find.text('Broken Image'), findsOneWidget);
  });  
}
