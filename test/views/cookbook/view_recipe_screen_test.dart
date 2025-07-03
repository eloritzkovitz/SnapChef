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
import 'package:snapchef/views/cookbook/widgets/edit_recipe_modal.dart';

import 'package:get_it/get_it.dart';
import 'package:snapchef/database/app_database.dart';
import '../../mocks/mock_app_database.dart';
import '../../mocks/mock_cookbook_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';

void main() {
  // Ensure Flutter binding is initialized for all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppDatabase db;

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'IMAGE_BASE_URL=https://example.com/');
    db = MockAppDatabase();
    GetIt.I.registerSingleton<AppDatabase>(db);
  });

  tearDownAll(() async {
    await db.close();
    GetIt.I.unregister<AppDatabase>();
  });

  Widget buildTestWidget(MockCookbookViewModel mockViewModel) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CookbookViewModel>(create: (_) => mockViewModel),
        ChangeNotifierProvider<UserViewModel>(
            create: (_) => MockUserViewModel()),
        ChangeNotifierProvider<NotificationsViewModel>(
            create: (_) => MockNotificationsViewModel()),
        ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider()),
      ],
      child: MaterialApp(
        home: ViewRecipeScreen(
            recipe: mockViewModel.recipes.first, cookbookId: 'cb1'),
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

  testWidgets('Popup menu actions work and dialogs behave correctly',
      (tester) async {
    final mockViewModel = MockCookbookViewModel();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget(mockViewModel));
      await tester.pumpAndSettle();

      // --- Edit Recipe ---
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Edit Recipe'), findsOneWidget);
      await tester.tap(find.text('Edit Recipe'));
      await tester.pumpAndSettle();
      expect(find.byType(EditRecipeModal), findsOneWidget);
      // Close modal
      await tester.tap(find.byIcon(Icons.close).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(EditRecipeModal), findsNothing);

      // --- Regenerate Image (should be enabled if not offline) ---
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Regenerate Image'), findsOneWidget);
      final regenItem = find.widgetWithText(PopupMenuItem, 'Regenerate Image');
      expect(tester.widget<PopupMenuItem>(regenItem).enabled, isTrue);

      // --- Favorite/Unfavorite ---
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Favorite'), findsOneWidget);
      await tester.tap(find.text('Favorite'));
      await tester.pumpAndSettle();
      // Should now show "Unfavorite"
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Unfavorite'), findsOneWidget);

      // --- Share Recipe (should be enabled if not offline) ---
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Share Recipe'), findsOneWidget);
      final shareItem = find.widgetWithText(PopupMenuItem, 'Share Recipe');
      expect(tester.widget<PopupMenuItem>(shareItem).enabled, isTrue);
      // Tap Share Recipe to open the bottom sheet
      await tester.tap(find.text('Share Recipe'));
      await tester.pumpAndSettle();
      // Close the bottom sheet (assuming there's a close icon)
      final closeIconFinder = find.byIcon(Icons.close);
      if (closeIconFinder.evaluate().isNotEmpty) {
        await tester.tap(closeIconFinder.first);
        await tester.pumpAndSettle();
      } else {
        // If no close icon, try to pop the bottom sheet
        Navigator.of(tester.element(find.byType(ViewRecipeScreen))).pop();
        await tester.pumpAndSettle();
      }

      // --- Delete Recipe (dialog: Cancel) ---
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Delete Recipe'), findsOneWidget);
      await tester.tap(find.text('Delete Recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to delete this recipe?'),
          findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to delete this recipe?'),
          findsNothing);

      // --- Delete Recipe (dialog: Confirm) ---
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete Recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to delete this recipe?'),
          findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(find.text('Recipe deleted successfully'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));

// Add this to ensure overlays are gone before rebuilding
      await tester.pumpAndSettle(const Duration(seconds: 2));

// --- Offline state disables Regenerate Image and Share Recipe ---
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CookbookViewModel>(
                create: (_) => mockViewModel),
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
            ChangeNotifierProvider<NotificationsViewModel>(
                create: (_) => MockNotificationsViewModel()),
            ChangeNotifierProvider<ConnectivityProvider>(
                create: (_) => MockConnectivityProvider(isOffline: true)),
          ],
          child: MaterialApp(
            home: ViewRecipeScreen(
                recipe: mockViewModel.recipes.first, cookbookId: 'cb1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      final regenItemOffline =
          find.widgetWithText(PopupMenuItem, 'Regenerate Image');
      final shareItemOffline =
          find.widgetWithText(PopupMenuItem, 'Share Recipe');
      expect(tester.widget<PopupMenuItem>(regenItemOffline).enabled, isFalse);
      expect(tester.widget<PopupMenuItem>(shareItemOffline).enabled, isFalse);
    });
  });
}
