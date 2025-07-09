import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/utils/ui_util.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';
import 'package:snapchef/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  setUpAll(() {
    showError = (context, message) {};
    showBackOnline = (context) {};
    showOffline = (context) {};
  });

  // ----------- LOGIN & SIGNUP FLOW -----------
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

  test('login error with email verification navigates to verify', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.login('test@example.com', 'password'))
        .thenThrow(Exception('Please verify your email'));
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
    verify(mockContext.mounted).called(1);
  });

  test('login error with wrong password shows error', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.login('test@example.com', 'password'))
        .thenThrow(Exception('Wrong username or password'));
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
    verify(mockContext.mounted).called(1);
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
    final result =
        await viewModel.signup('First', 'Last', 'email', 'pass', mockContext);
    expect(result, isTrue);
    expect(viewModel.isLoading, isFalse);
    verify(mockAuthService.signup('First', 'Last', 'email', 'pass')).called(1);
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
    final result =
        await viewModel.signup('First', 'Last', 'email', 'pass', mockContext);
    expect(result, isFalse);
    expect(viewModel.isLoading, isFalse);
    verify(mockAuthService.signup('First', 'Last', 'email', 'pass')).called(1);
  });

  // ----------- GOOGLE SIGN IN FLOW -----------
  test('googleSignIn success flow', () async {
    final mockAuthService = MockAuthService();
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final mockAccount = MockGoogleSignInAccount();
    final mockAuth = MockGoogleSignInAuthentication();
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
    when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
    when(mockAuth.idToken).thenReturn('idToken');
    when(mockAuthService.googleSignIn('idToken'))
        .thenAnswer((_) async => <String, dynamic>{});
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

  // ----------- LOGOUT & TOKEN REFRESH -----------
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

  test('logout error shows error', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.logout()).thenThrow(Exception('Logout failed'));
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.logout(mockContext);
    verify(mockAuthService.logout()).called(1);
    verify(mockContext.mounted).called(1);
  });

  test('refreshTokens calls AuthService.refreshTokens', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.refreshTokens())
        .thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.refreshTokens();
    verify(mockAuthService.refreshTokens()).called(1);
  });

  // ----------- OTP & PASSWORD RESET FLOW -----------
  test('verifyOTP calls AuthService.verifyOTP', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.verifyOTP('email', 'otp'))
        .thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.verifyOTP('email', 'otp', mockContext);
    verify(mockAuthService.verifyOTP('email', 'otp')).called(1);
  });

  test('verifyOTP error sets errorMessage', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.verifyOTP('email', 'otp'))
        .thenThrow(Exception('OTP failed'));
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.verifyOTP('email', 'otp', mockContext);
    verify(mockAuthService.verifyOTP('email', 'otp')).called(1);
    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.otpVerified, isFalse);
  });

  test('verifyOTP success sets infoMessage and otpVerified', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.verifyOTP('email', 'otp')).thenAnswer((_) async => {});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.verifyOTP('email', 'otp', mockContext);
    verify(mockAuthService.verifyOTP('email', 'otp')).called(1);
    expect(viewModel.infoMessage, isNotNull);
    expect(viewModel.otpVerified, isTrue);
  });

  test('resendOTP calls AuthService.resendOTP', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.resendOTP('email'))
        .thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.resendOTP('email');
    verify(mockAuthService.resendOTP('email')).called(1);
  });

  test('resendOTP sets infoMessage on success', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.resendOTP('email')).thenAnswer((_) async => {});
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    final result = await viewModel.resendOTP('email');
    expect(result, isTrue);
    expect(viewModel.infoMessage, isNotNull);
  });

  test('resendOTP sets errorMessage on error', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.resendOTP('email')).thenThrow(Exception('fail'));
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    final result = await viewModel.resendOTP('email');
    expect(result, isFalse);
    expect(viewModel.errorMessage, isNotNull);
  });

  test('requestPasswordReset calls AuthService.requestPasswordReset', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.requestPasswordReset('email'))
        .thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.requestPasswordReset('email', mockContext);
    verify(mockAuthService.requestPasswordReset('email')).called(1);
  });

  test('requestPasswordReset sets infoMessage on success', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.requestPasswordReset('email'))
        .thenAnswer((_) async => {});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.requestPasswordReset('email', mockContext);
    expect(viewModel.infoMessage, isNotNull);
  });

  test('requestPasswordReset error shows error', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.requestPasswordReset('email'))
        .thenThrow(Exception('Reset failed'));
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.requestPasswordReset('email', mockContext);
    verify(mockAuthService.requestPasswordReset('email')).called(1);
    expect(viewModel.errorMessage, isNotNull);
  });

  test('confirmPasswordReset calls AuthService.confirmPasswordReset', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass'))
        .thenAnswer((_) async => <String, dynamic>{});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.confirmPasswordReset(
        'email', 'otp', 'newPass', mockContext);
    verify(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass'))
        .called(1);
  });

  test('confirmPasswordReset sets infoMessage on success', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass'))
        .thenAnswer((_) async => {});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.confirmPasswordReset(
        'email', 'otp', 'newPass', mockContext);
    expect(viewModel.infoMessage, isNotNull);
    expect(viewModel.errorMessage, isNull);
  });

  test('confirmPasswordReset error sets errorMessage', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass'))
        .thenThrow(Exception('Confirm failed'));
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.confirmPasswordReset(
        'email', 'otp', 'newPass', mockContext);
    verify(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass'))
        .called(1);
    expect(viewModel.errorMessage, isNotNull);
  });

  test('confirmPasswordReset success clears errorMessage', () async {
    final mockAuthService = MockAuthService();
    when(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass'))
        .thenAnswer((_) async => {});
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockContext = MockBuildContext();
    when(mockContext.mounted).thenReturn(true);
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    await viewModel.confirmPasswordReset(
        'email', 'otp', 'newPass', mockContext);
    verify(mockAuthService.confirmPasswordReset('email', 'otp', 'newPass'))
        .called(1);
    expect(viewModel.errorMessage, isNull);
  });

  // ----------- STATE MANAGEMENT METHODS -----------
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

  test('setLoading sets isLoading', () {
    final mockAuthService = MockAuthService();
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    viewModel.setLoading(true);
    expect(viewModel.isLoading, isTrue);
    viewModel.setLoading(false);
    expect(viewModel.isLoading, isFalse);
  });

  test('clear resets error and loading', () {
    final mockAuthService = MockAuthService();
    final mockGoogleSignIn = MockGoogleSignIn();
    final viewModel = AuthViewModel(
      authService: mockAuthService,
      googleSignIn: mockGoogleSignIn,
    );
    viewModel.setError('err');
    viewModel.setLoading(true);
    viewModel.clear();
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
  });
}