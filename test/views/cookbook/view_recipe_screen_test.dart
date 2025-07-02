import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/cookbook_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/views/cookbook/view_recipe_screen.dart';
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

  Widget buildTestWidget(MockCookbookViewModel mockViewModel) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CookbookViewModel>(
            create: (_) => mockViewModel),
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => MockUserViewModel()),
        ChangeNotifierProvider<NotificationsViewModel>(
            create: (_) => MockNotificationsViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider()),
      ],
      child: MaterialApp(
        home: ViewRecipeScreen(recipe: mockViewModel.recipes.first, cookbookId: 'cb1'),
      ),
    );
  }

  testWidgets('ViewRecipeScreen renders and displays recipe details',
      (tester) async {
    final mockViewModel = MockCookbookViewModel();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget(mockViewModel));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Recipe Details'), findsOneWidget);     
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });

  testWidgets('Popup menu actions work', (tester) async {
    final mockViewModel = MockCookbookViewModel();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget(mockViewModel));
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
