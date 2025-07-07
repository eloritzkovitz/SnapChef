import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snapchef/views/auth/login_screen.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import '../../mocks/mock_auth_viewmodel.dart';
import '../../mocks/mock_user_viewmodel.dart';

void main() {
  testWidgets('LoginScreen renders and validates', (WidgetTester tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>(
                create: (_) => MockAuthViewModel()),
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
          ],
          child: MaterialApp(
            home: LoginScreen(
              googleButton: ElevatedButton(
                onPressed: () {},
                child: Text('Sign in with Google'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Try submitting empty form
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).first, 'invalid');
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    // Enter valid email and password
    await tester.enterText(
        find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Login'));
    await tester.pump();
    // No validation error now
    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Password is required'), findsNothing);
  });

  testWidgets('toggles password visibility', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>(
                create: (_) => MockAuthViewModel()),
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
          ],
          child: MaterialApp(
            home: LoginScreen(
              googleButton: ElevatedButton(
                onPressed: () {},
                child: Text('Sign in with Google'),
              ),
            ),
          ),
        ),
      ),
    );
    // Tap the password visibility icon
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('forgot password button navigates', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>(
                create: (_) => MockAuthViewModel()),
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
          ],
          child: MaterialApp(
            routes: {
              '/reset-password': (context) =>
                  Scaffold(body: Text('ResetPassword')),
            },
            home: LoginScreen(
              googleButton: ElevatedButton(
                onPressed: () {},
                child: Text('Sign in with Google'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Forgot your password?'));
    await tester.pumpAndSettle();
    expect(find.text('ResetPassword'), findsOneWidget);
  });

  testWidgets('google sign in button triggers callback', (tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>(
                create: (_) => MockAuthViewModel()),
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
          ],
          child: MaterialApp(
            home: LoginScreen(
              googleButton: ElevatedButton(
                onPressed: () {
                  pressed = true;
                },
                child: Text('Sign in with Google'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Sign in with Google'));
    expect(pressed, isTrue);
  });

  testWidgets('sign up button navigates', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>(
                create: (_) => MockAuthViewModel()),
            ChangeNotifierProvider<UserViewModel>(
                create: (_) => MockUserViewModel()),
          ],
          child: MaterialApp(
            routes: {
              '/signup': (context) => Scaffold(body: Text('SignupScreen')),
            },
            home: LoginScreen(
              googleButton: ElevatedButton(
                onPressed: () {},
                child: Text('Sign in with Google'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("Don't have an account?"));
    await tester.pumpAndSettle();
    expect(find.text('SignupScreen'), findsOneWidget);
  });
}
