import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../utils/ui_util.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({required this.email, super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool _loading = false;
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
    super.dispose();
  }

  // Resend OTP
  Future<void> _resendOtp(AuthViewModel authViewModel) async {
    setState(() {
      _loading = true;
    });
    await authViewModel.resendOTP(widget.email);
    setState(() => _loading = false);
    if (authViewModel.infoMessage != null) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Show message from ViewModel using UIUtil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authViewModel.errorMessage != null) {
        showError(context, authViewModel.errorMessage!);
        authViewModel.errorMessage = null;
      }
      if (authViewModel.infoMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authViewModel.infoMessage!)),
        );
        authViewModel.infoMessage = null;
      }
      if (authViewModel.otpVerified) {
        Navigator.pushReplacementNamed(context, '/login');
        authViewModel.otpVerified = false;
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Verify Email',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter the OTP sent to your email.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() {
                                _loading = true;
                              });
                              await authViewModel.verifyOTP(
                                widget.email,
                                otpController.text,
                                context,
                              );
                              setState(() => _loading = false);
                            },
                      child: const Text('Verify'),
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
                  ? () => _resendOtp(authViewModel)
                  : null,
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
