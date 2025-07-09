import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/preferences.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/views/profile/edit_notification_preferences_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_user_viewmodel.dart';

void main() {
  group('EditNotificationPreferencesScreen', () {
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
            notificationPreferences: {
              'friendRequests': true,
              'recipeShares': false,
            }, allergies: [], dietaryPreferences: {},
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
          home: EditNotificationPreferencesScreen(),
        ),
      );
    }

    testWidgets('renders EditNotificationPreferencesScreen and fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(EditNotificationPreferencesScreen), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Friend Requests'), findsOneWidget);
      expect(find.text('Recipe Shares'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('toggles switches and calls updateUserPreferences on Save (success)', (tester) async {
      bool updated = false;
      userViewModel.updateUserPreferencesCallback = ({
        Map<String, dynamic>? notificationPreferences,
      }) async {
        updated = true;
        expect(notificationPreferences, isNotNull);
        expect(notificationPreferences!['friendRequests'], isFalse);
        expect(notificationPreferences['recipeShares'], isTrue);
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Toggle Friend Requests off
      await tester.tap(find.widgetWithText(SwitchListTile, 'Friend Requests'));
      await tester.pumpAndSettle();

      // Toggle Recipe Shares on
      await tester.tap(find.widgetWithText(SwitchListTile, 'Recipe Shares'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start dialog
      await tester.pump(const Duration(milliseconds: 100)); // Let dialog show

      // Simulate async completion
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    });

    testWidgets('shows SnackBar on updateUserPreferences error', (tester) async {
      userViewModel.updateUserPreferencesCallback = ({
        Map<String, dynamic>? notificationPreferences,
      }) async {
        throw Exception('Test error');
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start dialog
      await tester.pump(const Duration(milliseconds: 100)); // Let dialog show

      // Simulate async completion
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to update notification preferences'), findsOneWidget);
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
            home: EditNotificationPreferencesScreen(),
          ),
        ),
      );
      // Should show CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}