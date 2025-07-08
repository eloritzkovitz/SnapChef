import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/auth/confirm_reset_screen.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/views/auth/otp_verification_screen.dart';
import '../../mocks/mock_auth_viewmodel.dart';

void main() {
  testWidgets('ConfirmResetScreen renders and allows code/password entry',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => MockAuthViewModel(),
        child: MaterialApp(
          home: ConfirmResetScreen(email: 'test@example.com'),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
          },
        ),
      ),
    );

    // Check for the button specifically, not just any text
    expect(find.widgetWithText(ElevatedButton, 'Set New Password'),
        findsOneWidget);

    // Enter code and password and submit
    await tester.enterText(find.byType(TextField).at(0), '654321');
    await tester.enterText(find.byType(TextField).at(1), 'newpassword');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set New Password'));
    await tester.pump();
    // Should call confirmPasswordReset (no error)
  });

  testWidgets('resend OTP button is disabled until timer ends, then enabled',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => MockAuthViewModel(),
        child:
            MaterialApp(home: OtpVerificationScreen(email: 'test@example.com')),
      ),
    );
    // Button should be disabled initially
    final resendButton = find.widgetWithText(TextButton, 'Resend OTP');
    expect(tester.widget<TextButton>(resendButton).onPressed, isNull);

    // Fast-forward timer to enable button
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(resendButton).onPressed, isNotNull);
  });

  testWidgets('shows error when resend code fails', (tester) async {
    final mockAuth = MockAuthViewModel();
    mockAuth.shouldFailOnRequestReset = true;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => mockAuth,
        child: MaterialApp(home: ConfirmResetScreen(email: 'test@example.com')),
      ),
    );
    // Fast-forward timer to enable button
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resend Code'));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading and show error
    // The error should be shown as a snackbar or dialog
    expect(
        find.text('Failed to resend code. Please try again.'), findsOneWidget);
  });

  testWidgets('shows error when reset fails', (tester) async {
    final mockAuth = MockAuthViewModel();
    mockAuth.shouldFailOnConfirmReset = true;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => mockAuth,
        child: MaterialApp(home: ConfirmResetScreen(email: 'test@example.com')),
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), '654321');
    await tester.enterText(find.byType(TextField).at(1), 'newpassword');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set New Password'));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading and show error
    expect(find.text('Failed to reset password. Please try again.'),
        findsOneWidget);
  });
}
