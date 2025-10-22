import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class TwoFactorVerifyScreen extends StatefulWidget {
  TwoFactorVerifyScreen({Key? key}) : super(key: key);

  @override
  State<TwoFactorVerifyScreen> createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends State<TwoFactorVerifyScreen> {
  final _codeController = TextEditingController();
  final authController = Get.find<AuthController>();
  bool _loading = false;

  int? get userIdFromArgs {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('userId'))
      return args['userId'] as int?;
    if (authController.pending2FaUserId.value != null)
      return authController.pending2FaUserId.value!;
    return null;
  }

  void _showSnack(String message, {bool success = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _submit() async {
    final codeText = _codeController.text.trim();
    if (codeText.length != 6) {
      _showSnack('Please enter the 6-digit code');
      return;
    }
    final code = int.tryParse(codeText);
    if (code == null) {
      _showSnack('Invalid code format');
      return;
    }

    final uid = userIdFromArgs;
    if (uid == null) {
      _showSnack('Missing user id');
      return;
    }

    setState(() => _loading = true);
    final resp = await authController.verifyTwoFactor(uid, code);
    setState(() => _loading = false);
    _showSnack(resp.message, success: resp.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify 2FA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Enter the 6-digit code from your Authenticator app.'),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: '6-digit code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
