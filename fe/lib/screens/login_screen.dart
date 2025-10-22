import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../components/custom_button.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authController = Get.put(AuthController());

  LoginScreen({super.key});

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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Login',
              onPressed: () async {
                final response = await authController.login(
                  _emailController.text,
                  _passwordController.text,
                );
                _showSnackBar(context, response.message, success: response.success);
              },
            ),
            TextButton(
              onPressed: () => Get.toNamed('/signup'),
              child: const Text('Don’t have an account? Sign up'),
            )
          ],
        ),
      ),
    );
  }
}
