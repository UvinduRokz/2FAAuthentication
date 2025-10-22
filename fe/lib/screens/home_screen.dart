import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Clear user session
              authController.user.value = null;
              // Navigate back to login
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          final currentUser = authController.user.value;
          final enabled = currentUser?.twoFaEnabled ?? false;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome, ${currentUser?.username ?? 'Guest'}',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Two-Factor Authentication: ${enabled ? "Enabled" : "Disabled"}'),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (!enabled) {
                        // Enable: call setupTwoFactor which will navigate to QR screen
                        final resp = await authController.setupTwoFactor();
                        if (!resp.success) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(resp.message),
                              backgroundColor: Colors.red));
                        }
                      } else {
                        // Disable: prompt for password then call disable API
                        final password = await showDialog<String>(
                          context: context,
                          builder: (ctx) {
                            final _pw = TextEditingController();
                            return AlertDialog(
                              title: const Text('Confirm Disable 2FA'),
                              content: TextField(
                                  controller: _pw,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Password')),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, null),
                                    child: const Text('Cancel')),
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, _pw.text),
                                    child: const Text('Disable')),
                              ],
                            );
                          },
                        );
                        if (password == null || password.isEmpty) return;
                        final uid = currentUser?.id;
                        if (uid == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not logged in')));
                          return;
                        }
                        final resp = await authController.disableTwoFactor(
                            uid, password);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(resp.message),
                            backgroundColor:
                                resp.success ? Colors.green : Colors.red));
                      }
                    },
                    child: Text(enabled ? 'Disable 2FA' : 'Enable 2FA'),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
