import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/auth/reset_password_screen.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import '../../mocks/mock_auth_viewmodel.dart';

void main() {
  testWidgets('ResetPasswordScreen renders and validates',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => MockAuthViewModel(),
        child: MaterialApp(
          home: ResetPasswordScreen(),
          routes: {
            '/confirm-reset': (context) =>
                const Scaffold(body: Text('Confirm Reset')),
          },
        ),
      ),
    );

    expect(find.text('Reset Password'), findsOneWidget);

    // Try submitting empty form
    await tester.tap(find.text('Send Reset Code'));
    await tester.pump();
    // No explicit validator, but should not crash

    // Enter email and submit
    await tester.enterText(find.byType(TextField), 'test@example.com');
    await tester.tap(find.text('Send Reset Code'));
    await tester.pump();
    // Should call requestPasswordReset (no error)
  });
}
