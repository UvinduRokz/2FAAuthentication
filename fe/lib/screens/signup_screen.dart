import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../components/custom_button.dart';

class SignupScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authController = Get.put(AuthController());

  SignupScreen({super.key});

  void _showSnackBar(BuildContext context, String message, {bool success = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Sign Up',
              onPressed: () async {
                final response = await authController.signup(
                  _usernameController.text,
                  _emailController.text,
                  _passwordController.text,
                );
                _showSnackBar(context, response.message, success: response.success);
              },
            ),
          ],
        ),
      ),
    );
  }
}
