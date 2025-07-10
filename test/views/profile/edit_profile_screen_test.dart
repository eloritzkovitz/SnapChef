import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:snapchef/views/profile/edit_profile_screen.dart';

import '../../mocks/mock_connectivity_provider.dart';
import '../../mocks/mock_user_viewmodel.dart';

void main() {
  group('EditProfileScreen', () {
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
        ),
      );
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>(
            create: (_) => userViewModel,
          ),
          ChangeNotifierProvider<ConnectivityProvider>(
            create: (_) => MockConnectivityProvider(),
          ),
        ],
        child: MaterialApp(
          home: const EditProfileScreen(),
          // Add routes for navigation coverage
          onGenerateRoute: (settings) {
            if (settings.name == '/login') {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Login Screen')),
              );
            }
            return null;
          },
        ),
      );
    }

    testWidgets('renders EditProfileScreen and fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields and short password',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Clear all fields
      await tester.enterText(
          find.widgetWithText(TextFormField, 'First Name'), '');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Last Name'), '');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '123');

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your first name'), findsOneWidget);
      expect(find.text('Please enter your last name'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters long'),
          findsOneWidget);
    });

    testWidgets('calls updateUser on Save (success)', (tester) async {
      bool updated = false;
      userViewModel.updateUserCallback = ({
        String? firstName,
        String? lastName,
        String? password,
        dynamic profilePicture,
      }) async {
        updated = true;
        expect(firstName, 'NewFirst');
        expect(lastName, 'NewLast');
        expect(password, 'newpassword');
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'First Name'), 'NewFirst');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Last Name'), 'NewLast');
      // Tap password field to clear placeholder, then enter new password
      await tester.tap(find.widgetWithText(TextFormField, 'Password'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'newpassword');

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start dialog
      await tester.pump(const Duration(milliseconds: 100)); // Let dialog show
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    });

    testWidgets('shows SnackBar on updateUser error', (tester) async {
      userViewModel.updateUserCallback = ({
        String? firstName,
        String? lastName,
        String? password,
        dynamic profilePicture,
      }) async {
        userViewModel.errorMessage = 'Failed to update profile: Test error';
        userViewModel.notifyListeners();
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start form submission

      // Give time for the post-frame callback to show the SnackBar
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(); // Extra frame for SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to update profile'), findsOneWidget);
    });

    testWidgets('shows and cancels Delete Account dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Delete Account'));
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(
          find.text('Delete Account'), findsNWidgets(2)); // Button and dialog
      expect(
          find.text(
              'This action will remove all your data and cannot be reverted. Are you sure you want to proceed?'),
          findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(
          find.text(
              'This action will remove all your data and cannot be reverted. Are you sure you want to proceed?'),
          findsNothing);
    });

    testWidgets('calls deleteUser and navigates to login on confirm',
        (tester) async {
      bool deleted = false;
      userViewModel.deleteUserCallback = (context) async {
        deleted = true;
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Delete Account'));
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      // Tap Delete in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pump(); // Start dialog
      await tester.pump(const Duration(milliseconds: 100)); // Let dialog show
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
      expect(find.text('Login Screen'), findsOneWidget); // Navigated to login
    });

    testWidgets('shows SnackBar on deleteUser error', (tester) async {
      userViewModel.deleteUserCallback = (context) async {
        userViewModel.errorMessage = 'Failed to delete account: Delete error';
        userViewModel.notifyListeners();
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Delete Account'));
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      // Tap Delete in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pump(); // Start dialog
      await tester.pump(const Duration(milliseconds: 100)); // Let dialog show
      await tester.pumpAndSettle();

      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to delete account'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      userViewModel = MockUserViewModel();
      // Simulate loading state
      userViewModel.setUser(null);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserViewModel>(
              create: (_) => userViewModel,
            ),
            ChangeNotifierProvider<ConnectivityProvider>(
              create: (_) => MockConnectivityProvider(),
            ),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
