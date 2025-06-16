import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/auth/signup_screen.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import '../../mocks/mock_auth_viewmodel.dart';

void main() {
  testWidgets('SignupScreen renders and validates',
      (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider<AuthViewModel>(
      create: (_) => MockAuthViewModel(),
      child: MaterialApp(home: SignupScreen()),
    ));

    expect(find.text('Join SnapChef today!'), findsOneWidget);

    // Try submitting empty form
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    expect(find.text('First name is required'), findsOneWidget);
    expect(find.text('Last name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).at(2), 'invalid');
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    // Enter short password
    await tester.enterText(find.byType(TextFormField).at(3), '123');
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    expect(find.text('Password must be at least 6 characters long'),
        findsOneWidget);

    // Enter valid data
    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    // No validation errors
    expect(find.text('First name is required'), findsNothing);
    expect(find.text('Last name is required'), findsNothing);
    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Password is required'), findsNothing);
  });
}
