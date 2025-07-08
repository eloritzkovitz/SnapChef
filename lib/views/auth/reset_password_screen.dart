import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authViewModel.errorMessage != null) {
        showError(context, authViewModel.errorMessage!);
        authViewModel.errorMessage = null;
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Reset Password',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Enter your email to receive a password reset code.'),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
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
                        if (emailController.text.isEmpty ||
                            !emailController.text.contains('@')) {
                          return;
                        }
                        setState(() {
                          _loading = true;
                        });
                        await authViewModel.requestPasswordReset(
                          emailController.text,
                          context,
                        );
                        setState(() => _loading = false);
                        // Only navigate if there was no error
                        if (authViewModel.errorMessage == null &&
                            context.mounted) {
                          Navigator.pushNamed(
                            context,
                            '/confirm-reset',
                            arguments: emailController.text,
                          );
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
