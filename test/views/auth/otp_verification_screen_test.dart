import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/auth/otp_verification_screen.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import '../../mocks/mock_auth_viewmodel.dart';

void main() {
  testWidgets('OtpVerificationScreen renders and allows OTP entry',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => MockAuthViewModel(),
        child: MaterialApp(
          home: OtpVerificationScreen(email: 'test@example.com'),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
            '/confirm-reset': (context) =>
                const Scaffold(body: Text('Confirm Reset')),
          },
        ),
      ),
    );

    expect(find.text('Verify Email'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);

    // Enter OTP and submit
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pump();
    // Should call verifyOTP (no error)
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

  testWidgets('shows error when OTP is invalid', (tester) async {
    final mockAuth = MockAuthViewModel();
    mockAuth.shouldFailOnVerify = true;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => mockAuth,
        child:
            MaterialApp(home: OtpVerificationScreen(email: 'test@example.com')),
      ),
    );

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Verify'));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading and show error
    expect(find.text('Invalid OTP. Please try again.'), findsOneWidget);
  });

  testWidgets('shows error when resend OTP fails', (tester) async {
    final mockAuth = MockAuthViewModel();
    mockAuth.shouldFailOnResend = true;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => mockAuth,
        child:
            MaterialApp(home: OtpVerificationScreen(email: 'test@example.com')),
      ),
    );
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resend OTP'));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading and show error
    expect(
        find.text('Failed to resend OTP. Please try again.'), findsOneWidget);
  });
}
