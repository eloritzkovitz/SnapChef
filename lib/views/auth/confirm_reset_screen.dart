import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';

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

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    // Get email from arguments if not passed directly
    final String email = widget.email ?? (ModalRoute.of(context)?.settings.arguments as String? ?? '');

    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Enter the code sent to your email and set a new password.'),
            const SizedBox(height: 24),
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: 'Reset Code',
                errorText: _error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        try {
                          await authViewModel.confirmPasswordReset(
                            email,
                            otpController.text,
                            passwordController.text,
                            context,
                          );
                          // Success: handled in ViewModel (navigates to login)
                        } catch (e) {
                          setState(() {
                            _error = 'Failed to reset password. Please try again.';
                          });
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                      child: const Text('Set New Password'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}