import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/preferences.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/views/profile/edit_preferences_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_user_viewmodel.dart';

void main() {
  group('EditPreferencesScreen', () {
    late MockUserViewModel userViewModel;

    setUp(() {
      userViewModel = MockUserViewModel();
      userViewModel.setUser(
        User(
          id: 'u1',
          firstName: 'Test',
          lastName: 'User',
          email: 'test@example.com',
          fridgeId: 'fridge1',
          cookbookId: 'cb1',
          preferences: Preferences(
            allergies: ['Peanuts'],
            dietaryPreferences: {'vegetarian': true, 'carnivore': false},
          ),
        ),
      );
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
          ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider(),
          ),
        ],
        child: const MaterialApp(
          home: EditPreferencesScreen(),
        ),
      );
    }

    testWidgets('renders EditPreferencesScreen and fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(EditPreferencesScreen), findsOneWidget);
      expect(find.text('Allergies'), findsOneWidget);
      expect(find.text('Dietary Preferences'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Peanuts'), findsOneWidget);
    });

    testWidgets('adds and removes an allergy', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Add allergy
      await tester.enterText(find.byType(TextFormField), 'Strawberries');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('Strawberries'), findsOneWidget);

      // Remove allergy
      await tester.tap(find.byIcon(Icons.close).last);
      await tester.pumpAndSettle();
      expect(find.text('Strawberries'), findsNothing);
    });

    testWidgets('toggles dietary preferences and handles conflicts', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Vegetarian is true, Carnivore is false
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Vegetarian')).value,
        isTrue,
      );
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Carnivore')).value,
        isFalse,
      );

      // Turn on Carnivore, should turn off Vegetarian and Vegan
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Carnivore'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Carnivore')).value,
        isTrue,
      );
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Vegetarian')).value,
        isFalse,
      );
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Vegan')).value,
        isFalse,
      );

      // Turn on Vegan, should turn off Carnivore, Vegetarian, Pescatarian
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Vegan'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Vegan')).value,
        isTrue,
      );
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Carnivore')).value,
        isFalse,
      );
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Vegetarian')).value,
        isFalse,
      );
      expect(
        tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Pescatarian')).value,
        isFalse,
      );
    });

    testWidgets('calls updateUserPreferences on Save (success)', (tester) async {
      bool updated = false;
      userViewModel.updateUserPreferencesCallback = ({
        List<String>? allergies,
        Map<String, dynamic>? dietaryPreferences,
        Map<String, dynamic>? notificationPreferences,
      }) async {
        updated = true;
        expect(allergies, contains('Peanuts'));
        expect(dietaryPreferences, isNotNull);
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start dialog
      await tester.pump(const Duration(milliseconds: 100)); // Let dialog show
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    });

    testWidgets('shows SnackBar on updateUserPreferences error', (tester) async {
      userViewModel.updateUserPreferencesCallback = ({
        List<String>? allergies,
        Map<String, dynamic>? dietaryPreferences,
        Map<String, dynamic>? notificationPreferences,
      }) async {
        throw Exception('Test error');
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start dialog
      await tester.pump(const Duration(milliseconds: 100)); // Let dialog show
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to update preferences'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      // Simulate loading state by not calling setUser in setUp
      userViewModel = MockUserViewModel();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
            ChangeNotifierProvider<ConnectivityProvider>(
              create: (_) => MockConnectivityProvider(),
            ),
          ],
          child: const MaterialApp(
            home: EditPreferencesScreen(),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}