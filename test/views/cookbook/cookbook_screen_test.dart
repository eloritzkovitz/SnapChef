import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/shared_recipe_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/cookbook_screen.dart';
import 'package:snapchef/views/cookbook/widgets/recipe_card.dart';
import 'package:snapchef/views/cookbook/widgets/cookbook_filter_sort_sheet.dart';

import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_shared_recipe_viewmodel.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => MockUserViewModel()),
        ChangeNotifierProvider<CookbookViewModel>(
            create: (_) => MockCookbookViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider()),
        ChangeNotifierProvider<SharedRecipeViewModel>(
            create: (_) => MockSharedRecipeViewModel()),
      ],
      child: const MaterialApp(
        home: CookbookScreen(),
      ),
    );
  }

  testWidgets(
      'CookbookScreen displays title, filter, favorites, and recipe list',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // AppBar title
    expect(find.text('Cookbook'), findsOneWidget);

    // Filter & Sort button (by key)
    final filterButtonFinder = find.byKey(const Key('filterSortButton'));
    expect(filterButtonFinder, findsOneWidget);

    // Favorites toggle button (by key)
    final favoritesButtonFinder = find.byKey(const Key('favoritesToggleButton'));
    expect(favoritesButtonFinder, findsOneWidget);

    // Search button (by key)
    final searchButtonFinder = find.byKey(const Key('searchButton'));
    expect(searchButtonFinder, findsOneWidget);

    // Shared recipes button (by key)    
    final sharedRecipesButtonFinder = find.byKey(const Key('sharedRecipesButton'));
    expect(sharedRecipesButtonFinder, findsOneWidget);

    // Floating action button (SpeedDial)
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Recipe list (RecipeCard)
    expect(find.byType(RecipeCard), findsWidgets);

    // Tap the filter button and check for filter sheet
    await tester.tap(filterButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CookbookFilterSortSheet), findsOneWidget);

    // Close the filter sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Tap the favorites button to toggle
    await tester.tap(favoritesButtonFinder);
    await tester.pumpAndSettle();

    // Tap the search button
    await tester.tap(searchButtonFinder);
    await tester.pumpAndSettle();

    // Tap the shared recipes button
    //await tester.tap(sharedRecipesButtonFinder);
    await tester.pumpAndSettle();
  });
}