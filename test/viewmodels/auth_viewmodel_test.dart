import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Tell mockito to generate mocks for these classes:
@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
  MockSpec<BuildContext>(),
])
import 'auth_viewmodel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('login success navigates to main', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.login('test@example.com', 'password'))
        .thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    bool fetchCalled = false;
    await viewModel.login(
      'test@example.com',
      'password',
      mockContext,
      () async {
        fetchCalled = true;
      },
    );
    expect(fetchCalled, isTrue);
    expect(viewModel.isLoading, isFalse);
    verify(mockAuthService.login('test@example.com', 'password')).called(1);
  });

  test('signup success returns true', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.signup('First', 'Last', 'email', 'pass'))
        .thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    final result = await viewModel.signup('First', 'Last', 'email', 'pass', mockContext);
    expect(result, isTrue);
    expect(viewModel.isLoading, isFalse);
    verify(mockAuthService.signup('First', 'Last', 'email', 'pass')).called(1);
  });

  test('logout calls AuthService.logout', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.logout()).thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.logout(mockContext);
    verify(mockAuthService.logout()).called(1);
  });

  test('refreshTokens calls AuthService.refreshTokens', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.refreshTokens()).thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.refreshTokens();
    verify(mockAuthService.refreshTokens()).called(1);
  });

  test('verifyOTP calls AuthService.verifyOTP', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.verifyOTP('email', 'otp')).thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.verifyOTP('email', 'otp', mockContext);
    verify(mockAuthService.verifyOTP('email', 'otp')).called(1);
  });

  test('resendOTP calls AuthService.resendOTP', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.resendOTP('email')).thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.resendOTP('email');
    verify(mockAuthService.resendOTP('email')).called(1);
  });

  test('requestPasswordReset calls AuthService.requestPasswordReset', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.requestPasswordReset('email')).thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.requestPasswordReset('email', mockContext);
    verify(mockAuthService.requestPasswordReset('email')).called(1);
  });

  test('confirmPasswordReset calls AuthService.confirmPasswordReset', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass')).thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.confirmPasswordReset('email', 'otp', 'newPass', mockContext);
    verify(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass')).called(1);
  });

  test('googleSignIn success flow', () async {
    final mockAuthService = MockAuthService();
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final mockAccount = MockGoogleSignInAccount();
    final mockAuth = MockGoogleSignInAuthentication();
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
    when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
    when(mockAuth.idToken).thenReturn('idToken');
    when(mockAuthService.googleSignIn('idToken')).thenAnswer((_) async => <String, dynamic>{});
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    bool fetchCalled = false;
    await viewModel.googleSignIn(mockContext, () async {
      fetchCalled = true;
    });
    expect(fetchCalled, isTrue);
    expect(viewModel.isLoading, isFalse);
    verify(mockAuthService.googleSignIn('idToken')).called(1);
  });

  test('googleSignIn cancelled', () async {
    final mockAuthService = MockAuthService();
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    bool fetchCalled = false;
    await viewModel.googleSignIn(mockContext, () async {
      fetchCalled = true;
    });
    expect(fetchCalled, isFalse);
    expect(viewModel.isLoading, isFalse);
  });

  test('setLoggingOut updates state', () {
    final mockAuthService = MockAuthService();
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    viewModel.setLoggingOut(true);
    expect(viewModel.isLoggingOut, isTrue);
  });

  test('login error shows error', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.login('test@example.com', 'password'))
        .thenThrow(Exception('Login failed'));
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    bool fetchCalled = false;
    await viewModel.login(
      'test@example.com',
      'password',
      mockContext,
      () async {
        fetchCalled = true;
      },
    );
    expect(fetchCalled, isFalse);
    expect(viewModel.isLoading, isFalse);
    verify(mockAuthService.login('test@example.com', 'password')).called(1);
  });

  test('signup error returns false', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.signup('First', 'Last', 'email', 'pass'))
        .thenThrow(Exception('Signup failed'));
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    final result = await viewModel.signup('First', 'Last', 'email', 'pass', mockContext);
    expect(result, isFalse);
    expect(viewModel.isLoading, isFalse);
    verify(mockAuthService.signup('First', 'Last', 'email', 'pass')).called(1);
  });
}