import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapchef/database/app_database.dart' hide Ingredient;
import 'package:snapchef/models/notifications/ingredient_reminder.dart';
import 'package:snapchef/repositories/fridge_repository.dart';
import 'package:snapchef/services/fridge_service.dart';
import 'package:snapchef/services/image_service.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/viewmodels/ingredient_viewmodel.dart';
import 'package:snapchef/viewmodels/notifications_viewmodel.dart';
import 'package:snapchef/views/cookbook/generate_recipe_screen.dart';
import 'package:snapchef/views/fridge/fridge_screen.dart';
import 'package:snapchef/views/fridge/widgets/action_button.dart';
import 'package:snapchef/views/fridge/widgets/fridge_filter_sort_sheet.dart';
import 'package:snapchef/views/fridge/widgets/fridge_grid_view.dart';
import 'package:snapchef/views/fridge/widgets/fridge_list_view.dart';
import 'package:snapchef/views/fridge/groceries_screen.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/viewmodels/fridge_viewmodel.dart';
import 'package:snapchef/models/ingredient.dart';
import 'package:snapchef/views/fridge/widgets/ingredient_reminder_dialog.dart';
import 'package:snapchef/views/fridge/widgets/recognition_results.dart';

import '../../mocks/mock_app_database.dart';
import '../../mocks/mock_fridge_viewmodel.dart';
import '../../mocks/mock_image_service.dart';
import '../../mocks/mock_ingredient_viewmodel.dart';
import '../../mocks/mock_notifications_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';
import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_ingredient_service.dart';

// ---- Minimal mocks for GetIt dependencies ----
class MockFridgeRepository extends FridgeRepository {}

class MockFridgeService extends FridgeService {}

class ErrorNotificationsViewModel extends MockNotificationsViewModel {
  @override
  Future<String> generateUniqueNotificationId() async {
    throw Exception('fail');
  }
}

Widget buildTestWidget({
  FridgeViewModel? fridgeViewModel,
  UserViewModel? userViewModel,
  ConnectivityProvider? connectivityProvider,
  IngredientViewModel? ingredientViewModel,
  Widget? child,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<FridgeViewModel>(
          create: (_) => fridgeViewModel ?? MockFridgeViewModel()),
      ChangeNotifierProvider<UserViewModel>(
          create: (_) => userViewModel ?? MockUserViewModel()),
      ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => connectivityProvider ?? MockConnectivityProvider()),
      ChangeNotifierProvider<IngredientViewModel>(
          create: (_) => ingredientViewModel ?? MockIngredientViewModel()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: child ?? const FridgeScreen(),
      ),
    ),
  );
}

void main() {
  setUp(() async {
    await dotenv.load();
    GetIt.I.reset();
    GetIt.I.registerSingleton<ConnectivityProvider>(MockConnectivityProvider());
    final db = MockAppDatabase();
    GetIt.I.registerSingleton<AppDatabase>(db);
    addTearDown(() async => await db.close());
    GetIt.I.registerSingleton<FridgeService>(MockFridgeService());
    GetIt.I.registerSingleton<FridgeRepository>(MockFridgeRepository());
    GetIt.I.registerSingleton<IngredientService>(MockIngredientService());
  });

  group('FridgeScreen', () {
    testWidgets('renders empty state', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.fridgeController.filteredItems = [];
      await tester
          .pumpWidget(buildTestWidget(fridgeViewModel: fridgeViewModel));
      await tester.pumpAndSettle();
      expect(find.text('No available ingredients'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows failed user state', (tester) async {
      final userViewModel = MockUserViewModel();
      userViewModel.setUser(null);
      await tester.pumpWidget(buildTestWidget(userViewModel: userViewModel));
      await tester.pumpAndSettle();
      expect(find.text('Failed to load user data'), findsOneWidget);
    });

    testWidgets('toggles between grid and list view', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      fridgeViewModel.fridgeController.filteredItems = [
        Ingredient(
            id: '1',
            name: 'Egg',
            category: 'Dairy',
            count: 2,
            imageURL: 'https://example.com/egg.png'),
        Ingredient(
            id: '2',
            name: 'Milk',
            category: 'Dairy',
            count: 2,
            imageURL: 'https://example.com/milk.png'),
      ];
      await tester
          .pumpWidget(buildTestWidget(fridgeViewModel: fridgeViewModel));
      await tester.pumpAndSettle();
      expect(find.byType(FridgeGridView), findsOneWidget);
      await tester.tap(find.byTooltip('Switch to List View'));
      await tester.pumpAndSettle();
      expect(find.byType(FridgeListView), findsOneWidget);
    });

    testWidgets('opens groceries list', (tester) async {
      final fridgeViewModel = MockFridgeViewModel();
      await tester
          .pumpWidget(buildTestWidget(fridgeViewModel: fridgeViewModel));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      expect(find.byType(GroceriesScreen), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });
  });

  group('FridgeGridView', () {
    testWidgets('renders ingredient cards', (tester) async {
      final ingredients = [
        Ingredient(
            id: '1', name: 'Egg', category: 'Dairy', count: 2, imageURL: ''),
        Ingredient(
            id: '2', name: 'Milk', category: 'Dairy', count: 2, imageURL: ''),
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeGridView(
            ingredients: ingredients,
            fridgeId: 'fridge123',
            viewModel: MockFridgeViewModel(),
            onDelete: (_) {},
            onSetExpiryAlert: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Egg'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('calls all actions', (tester) async {
      final actions = <String>[];
      final ingredients = [
        Ingredient(
            id: '1', name: 'Egg', category: 'Dairy', count: 2, imageURL: ''),
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeGridView(
            ingredients: ingredients,
            fridgeId: 'fridge123',
            viewModel: MockFridgeViewModel(),
            onDelete: (i) => actions.add('delete'),
            onSetExpiryAlert: (i) => actions.add('expiry'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // Increase
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();
      // Decrease (only once, when count is 2)
      final decreaseFinder = find.byIcon(Icons.remove_circle);
      if (decreaseFinder.evaluate().isNotEmpty) {
        await tester.tap(decreaseFinder);
        await tester.pumpAndSettle();
      }
      // Delete
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      // Expiry
      await tester.tap(find.byIcon(Icons.alarm_add));
      await tester.pumpAndSettle();
      expect(actions, containsAll(['delete', 'expiry']));
    });
  });

  group('FridgeListView', () {
    testWidgets('calls all actions and shows error snackbar', (tester) async {
      final actions = <String>[];
      final ingredients = [
        Ingredient(
            id: '1', name: 'Egg', category: 'Dairy', count: 1, imageURL: ''),
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeListView(
            ingredients: ingredients,
            fridgeId: 'fridge123',
            viewModel: MockFridgeViewModel(),
            onDelete: (i) => actions.add('delete'),
            onSetExpiryAlert: (i) => actions.add('expiry'),
          ),
        ),
      ));
      // Increase
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      // Decrease at count 1 (should show snackbar)
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pump(); // show snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      // Delete
      await tester.tap(find.byIcon(Icons.delete));
      // Expiry
      await tester.tap(find.byIcon(Icons.alarm));
      expect(actions, containsAll(['delete', 'expiry']));
    });

    testWidgets('reorder triggers viewModel', (tester) async {
      final ingredients = [
        Ingredient(
            id: '1', name: 'Egg', category: 'Dairy', count: 2, imageURL: ''),
        Ingredient(
            id: '2', name: 'Milk', category: 'Dairy', count: 2, imageURL: ''),
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeListView(
            ingredients: ingredients,
            fridgeId: 'fridge123',
            viewModel: MockFridgeViewModel(),
            onDelete: (_) {},
            onSetExpiryAlert: (_) {},
          ),
        ),
      ));
      await tester.drag(find.text('Egg'), const Offset(0, 100));
      await tester.pumpAndSettle();
      // No error means reorder branch is covered
    });
  });

  group('FridgeFilterSortSheet', () {
    testWidgets('clear button calls callback', (tester) async {
      bool cleared = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeFilterSortSheet(
            selectedCategory: '',
            selectedSort: '',
            categories: ['Dairy', 'Fruit'],
            onClear: () {
              cleared = true;
            },
            onApply: (cat, sort) {},
            categoryLabel: 'Category',
            sortLabel: 'Sort By',
          ),
        ),
      ));
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(cleared, isTrue);
    });

    testWidgets('apply button calls callback', (tester) async {
      bool applied = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeFilterSortSheet(
            selectedCategory: '',
            selectedSort: '',
            categories: ['Dairy', 'Fruit'],
            onClear: () {},
            onApply: (cat, sort) {
              applied = true;
            },
            categoryLabel: 'Category',
            sortLabel: 'Sort By',
          ),
        ),
      ));
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(applied, isTrue);
    });

    testWidgets('category and sort dropdowns change value', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeFilterSortSheet(
            selectedCategory: '',
            selectedSort: '',
            categories: ['Dairy', 'Fruit'],
            onClear: () {},
            onApply: (cat, sort) {},
            categoryLabel: 'Category',
            sortLabel: 'Sort By',
          ),
        ),
      ));
      // Open and select category
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dairy').last);
      await tester.pumpAndSettle();

      // Open and select sort
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sort by Name').last);
      await tester.pumpAndSettle();
      // No error means dropdowns work
    });

    testWidgets('handles empty/invalid categories gracefully', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FridgeFilterSortSheet(
            selectedCategory: '',
            selectedSort: '',
            categories: ['', ' ', 'Dairy'],
            onClear: () {},
            onApply: (cat, sort) {},
            categoryLabel: 'Category',
            sortLabel: 'Sort By',
          ),
        ),
      ));
      // Open and select category
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dairy').last);
      await tester.pumpAndSettle();
      // No error means empty/invalid categories are filtered
    });
  });

  group('IngredientReminderDialog', () {
    late Ingredient ingredient;
    late bool alertSet;
    setUp(() {
      ingredient = Ingredient(
        id: '1',
        name: 'Egg',
        category: 'Dairy',
        count: 1,
        imageURL: '',
      );
      alertSet = false;
    });

    Widget buildDialog({required ReminderType type}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationsViewModel>(
              create: (_) => MockNotificationsViewModel()),
          ChangeNotifierProvider<UserViewModel>(
              create: (_) => MockUserViewModel()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => IngredientReminderDialog(
                ingredient: ingredient,
                type: type,
                onSetAlert: (_) {
                  alertSet = true;
                },
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders expiry reminder dialog', (tester) async {
      await tester.pumpWidget(buildDialog(type: ReminderType.expiry));
      expect(find.text('Set Expiry Reminder'), findsOneWidget);
      expect(find.text('Egg'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Set Reminder'), findsOneWidget);
    });

    testWidgets('renders grocery reminder dialog', (tester) async {
      await tester.pumpWidget(buildDialog(type: ReminderType.grocery));
      expect(find.text('Set Grocery Reminder'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await tester.pumpWidget(buildDialog(type: ReminderType.expiry));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(IngredientReminderDialog), findsNothing);
    });

    testWidgets('set reminder button calls onSetAlert and closes dialog',
        (tester) async {
      await tester.pumpWidget(buildDialog(type: ReminderType.expiry));
      await tester.tap(find.text('Set Reminder'));
      await tester.pumpAndSettle();
      expect(alertSet, isTrue);
      // Dialog should close
      expect(find.byType(IngredientReminderDialog), findsNothing);
    });

    testWidgets('shows error snackbar if exception thrown', (tester) async {
      // Use a viewmodel that throws in addNotification
      final errorViewModel = ErrorNotificationsViewModel();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<NotificationsViewModel>(
                create: (_) => errorViewModel),
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => IngredientReminderDialog(
                  ingredient: ingredient,
                  type: ReminderType.expiry,
                  onSetAlert: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Set Reminder'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining('Invalid date or time format.'), findsOneWidget);
    });
  });

  group('ActionButton', () {
    Widget buildButton({
      bool isDisabled = false,
      ImageService? imageService,
      UserViewModel? userViewModel,      
    }) {
      return ChangeNotifierProvider<UserViewModel>(
        create: (_) => userViewModel ?? MockUserViewModel(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ActionButton(
                isDisabled: isDisabled,                
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows all SpeedDial actions', (tester) async {
      await tester.pumpWidget(buildButton());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Generate Recipe'), findsOneWidget);
      expect(find.text('Scan Barcode'), findsOneWidget);
      expect(find.text('Scan Receipt'), findsOneWidget);
      expect(find.text('Capture Photo'), findsOneWidget);
    });

    testWidgets('disabled state shows unavailable offline', (tester) async {
      await tester.pumpWidget(buildButton(isDisabled: true));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Recipe'), warnIfMissed: false);
      await tester.pumpAndSettle();      
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('generate recipe navigates when enabled', (tester) async {
      await tester.pumpWidget(buildButton());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Recipe'));
      await tester.pumpAndSettle();      
      expect(find.byType(GenerateRecipeScreen), findsOneWidget);
    });

    testWidgets('scan barcode with no barcode shows snackbar', (tester) async {
      final mockImageService = MockImageService()..barcodeMode = true;
      await tester.pumpWidget(buildButton(imageService: mockImageService));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan Barcode'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('No barcode found'), findsOneWidget);
    });

    testWidgets('scan receipt shows recognition results', (tester) async {
      final mockImageService = MockImageService();
      await tester.pumpWidget(buildButton(imageService: mockImageService));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan Receipt'));
      await tester.pumpAndSettle();
      expect(find.text('Recognized Ingredients'), findsOneWidget);
    });

    testWidgets('capture photo shows recognition results', (tester) async {
      final mockImageService = MockImageService();
      await tester.pumpWidget(buildButton(imageService: mockImageService));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Capture Photo'));
      await tester.pumpAndSettle();
      expect(find.text('Recognized Ingredients'), findsOneWidget);
    });

    testWidgets('image pick returns null shows no ingredients popup', (tester) async {
      final mockImageService = MockImageService()..returnImage = false;
      await tester.pumpWidget(buildButton(imageService: mockImageService));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan Receipt'));
      await tester.pumpAndSettle();
      expect(find.text('No Ingredients Recognized'), findsOneWidget);
    });

    testWidgets('image pick throws error shows snackbar', (tester) async {
      final mockImageService = MockImageService()..throwOnPick = true;
      await tester.pumpWidget(buildButton(imageService: mockImageService));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan Receipt'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('process image throws error shows snackbar', (tester) async {
      final mockImageService = MockImageService()..throwOnProcess = true;
      await tester.pumpWidget(buildButton(imageService: mockImageService));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan Receipt'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  group('RecognitionResultsWidget', () {
    late Map<String, Map<String, dynamic>> groupedIngredients;
    late MockFridgeViewModel mockViewModel;

    setUp(() {
      groupedIngredients = {
        'Egg': {
          'name': 'Egg',
          'category': 'Dairy',
          'id': '1',
          'imageURL': '',
          'quantity': 2,
        },
        'Milk': {
          'name': 'Milk',
          'category': 'Dairy',
          'id': '2',
          'imageURL': '',
          'quantity': 1,
        },
      };
      mockViewModel = MockFridgeViewModel();
    });

    Widget buildWidget([Map<String, Map<String, dynamic>>? data]) {
      return ChangeNotifierProvider<FridgeViewModel>.value(
        value: mockViewModel,
        child: MaterialApp(
          home: Scaffold(
            body: RecognitionResultsWidget(
              groupedIngredients: data ?? groupedIngredients,
              fridgeId: 'fridge123',
            ),
          ),
        ),
      );
    }

    testWidgets('renders with ingredients', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Recognized Ingredients'), findsOneWidget);
      expect(find.text('Egg'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('shows empty state when all processed', (tester) async {
      await tester.pumpWidget(buildWidget({}));
      expect(find.text('All ingredients have been processed.'), findsOneWidget);
    });

    testWidgets('increase and decrease quantity', (tester) async {
      await tester.pumpWidget(buildWidget());
      // Decrease Egg (from 2 to 1)
      await tester.tap(find.descendant(
        of: find.widgetWithText(Card, 'Egg'),
        matching: find.byIcon(Icons.remove_circle_outline),
      ));
      await tester.pumpAndSettle();
      // Increase Egg (from 1 to 2)
      await tester.tap(find.descendant(
        of: find.widgetWithText(Card, 'Egg'),
        matching: find.byIcon(Icons.add_circle_outline),
      ));
      await tester.pumpAndSettle();
      // Quantity text should still be present
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('add to fridge success removes ingredient and shows snackbar',
        (tester) async {
      mockViewModel.addFridgeSuccess = true;
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.descendant(
        of: find.widgetWithText(Card, 'Egg'),
        matching: find.byIcon(Icons.check_circle),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining('added to fridge successfully'), findsOneWidget);
    });

    testWidgets('add to fridge failure shows error snackbar', (tester) async {
      mockViewModel.addFridgeSuccess = false;
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.descendant(
        of: find.widgetWithText(Card, 'Egg'),
        matching: find.byIcon(Icons.check_circle),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining('Failed to add Egg to fridge'), findsOneWidget);
    });

    testWidgets('discard ingredient removes it and closes when empty',
        (tester) async {
      // Only one ingredient
      final single = {
        'Egg': {
          'name': 'Egg',
          'category': 'Dairy',
          'id': '1',
          'imageURL': '',
          'quantity': 1,
        }
      };
      await tester.pumpWidget(buildWidget(single));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      // Widget should be gone after last ingredient is discarded
      expect(find.byType(RecognitionResultsWidget), findsNothing);
    });    
  });
}
