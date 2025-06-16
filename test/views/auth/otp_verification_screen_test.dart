import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/auth/otp_verification_screen.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import '../../mocks/mock_auth_viewmodel.dart';

void main() {
  testWidgets('OtpVerificationScreen renders and allows OTP entry', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => MockAuthViewModel(),
        child: MaterialApp(home: OtpVerificationScreen(email: 'test@example.com')),
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
}