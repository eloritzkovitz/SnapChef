import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({required this.email, super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
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
    super.dispose();
  }

  // Resend OTP
  Future<void> _resendOtp(AuthViewModel authViewModel) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await authViewModel.resendOTP(widget.email);
      _startTimer();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent! Please check your email.')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to resend OTP. Please try again.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                errorText: _error,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        try {
                          await authViewModel.verifyOTP(
                            widget.email,
                            otpController.text,
                            context,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Email verified! Please log in.')),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        } catch (e) {
                          setState(() {
                            _error = 'Invalid OTP. Please try again.';
                          });
                        } finally {
                          setState(() => _loading = false);
                        }
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
