import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../utils/ui_util.dart';

class ConfirmResetScreen extends StatefulWidget {
  final String? email;
  const ConfirmResetScreen({super.key, this.email});

  @override
  State<ConfirmResetScreen> createState() => _ConfirmResetScreenState();
}

class _ConfirmResetScreenState extends State<ConfirmResetScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _resendOtp(AuthViewModel authViewModel, String email) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await authViewModel.requestPasswordReset(email, context);
    setState(() => _loading = false);
    if (authViewModel.errorMessage == null) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final String email = widget.email ??
        (ModalRoute.of(context)?.settings.arguments as String? ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authViewModel.errorMessage != null) {
        showError(context, authViewModel.errorMessage!);
        authViewModel.errorMessage = null;
      }
      if (authViewModel.infoMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authViewModel.infoMessage!)),
        );
        // Navigate if password reset was successful
        if (authViewModel.infoMessage ==
                'Password reset successful! Please log in.' &&
            context.mounted) {
          // Clear the infoMessage before navigating to avoid duplicate snackbars
          authViewModel.infoMessage = null;
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          authViewModel.infoMessage = null;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Set New Password',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                  'Enter the code sent to your email and set a new password.'),
              const SizedBox(height: 24),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'Reset Code',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  errorText: _error,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.grey),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (otpController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            setState(() {
                              _error = 'Please fill in all fields.';
                            });
                            return;
                          }
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          await authViewModel.confirmPasswordReset(
                            email,
                            otpController.text,
                            passwordController.text,
                            context,
                          );
                          setState(() => _loading = false);
                        },
                        child: const Text('Set New Password'),
                      ),
                    ),
              const SizedBox(height: 24),
              Text(
                _canResend
                    ? 'Didn\'t receive the code?'
                    : 'Resend code in $_secondsRemaining seconds',
                style: const TextStyle(fontSize: 14),
              ),
              TextButton(
                onPressed: _canResend && !_loading
                    ? () => _resendOtp(authViewModel, email)
                    : null,
                child: const Text('Resend Code'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
