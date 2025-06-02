import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Enter your email to receive a password reset code.'),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
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
                          await authViewModel.requestPasswordReset(
                            emailController.text,
                            context,
                          );
                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              '/confirm-reset',
                              arguments: emailController.text,
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _error = 'Failed to send reset code. Please try again.';
                          });
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                      child: const Text('Send Reset Code'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}