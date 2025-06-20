import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/auth/confirm_reset_screen.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import '../../mocks/mock_auth_viewmodel.dart';

void main() {
  testWidgets('ConfirmResetScreen renders and allows code/password entry', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => MockAuthViewModel(),
        child: MaterialApp(home: ConfirmResetScreen(email: 'test@example.com')),
      ),
    );

    // Check for the button specifically, not just any text
    expect(find.widgetWithText(ElevatedButton, 'Set New Password'), findsOneWidget);

    // Enter code and password and submit
    await tester.enterText(find.byType(TextField).at(0), '654321');
    await tester.enterText(find.byType(TextField).at(1), 'newpassword');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set New Password'));
    await tester.pump();
    // Should call confirmPasswordReset (no error)
  });
}