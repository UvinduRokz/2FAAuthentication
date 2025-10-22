import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/services.dart';

class TwoFactorQrScreen extends StatelessWidget {
  TwoFactorQrScreen({Key? key}) : super(key: key);
  final authController = Get.find<AuthController>();

  bool looksLikeBase64(String s) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/=\s]+$');
    return base64Pattern.hasMatch(s) && s.length > 100;
  }

  bool isPngHeader(Uint8List bytes) {
    return bytes.length > 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47; // "\x89PNG"
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String? payload = args['qrPayload'] as String?;
    final bool isImageUrlFlag = args['isImageUrl'] as bool? ?? false;
    final bool isBase64Flag = args['isBase64'] as bool? ?? false;
    final int? userId = args['userId'] as int?;
    final String? secret = args['secret'] as String?;

    print(
        'DEBUG TwoFactorQrScreen payload: ${payload?.substring(0, payload?.length.clamp(0, 120) ?? 0)}'
        '  flags: isImageUrl=$isImageUrlFlag isBase64=$isBase64Flag');

    Widget content;

    if (payload == null) {
      content = const Text('No QR available');
    } else if (payload.startsWith('otpauth://')) {
      // Preferred: raw otpAuthUrl -> render with qr_flutter
      content = Column(
        children: [
          QrImageView(
            data: payload,
            version: QrVersions.auto,
            size: 300.0,
            gapless: false,
            errorStateBuilder: (ctx, err) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('QR generation failed: $err'),
            ),
          ),
        ],
      );
    } else if (isBase64Flag || looksLikeBase64(payload)) {
      // Try decode - check PNG header before trusting
      try {
        final bytes = base64Decode(payload);
        if (isPngHeader(bytes)) {
          content =
              Image.memory(bytes, width: 300, height: 300, fit: BoxFit.contain);
        } else {
          content = Column(
            children: [
              const Text('Invalid base64 image data'),
              SelectableText('RAW: $payload', textAlign: TextAlign.center),
            ],
          );
        }
      } catch (err) {
        content = Column(
          children: [
            const Text('Invalid base64 image data'),
            SelectableText('RAW: $payload', textAlign: TextAlign.center),
          ],
        );
      }
    } else if (payload.startsWith('http')) {
      // Remote image URL
      content = Image.network(payload,
          width: 300,
          height: 300,
          fit: BoxFit.contain, errorBuilder: (ctx, err, st) {
        return Column(
          children: [
            const Text('Failed to load QR image from network'),
            SelectableText('URL: $payload', textAlign: TextAlign.center),
          ],
        );
      });
    } else {
      // Fallback: show raw payload and let user copy it
      content = Column(
        children: [
          const Text('Unknown payload format — showing raw payload:'),
          SelectableText('RAW: $payload', textAlign: TextAlign.center),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Setup 2FA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            content,
            const SizedBox(height: 16),
            if (secret != null) ...[
              SelectableText('Secret (manual entry): $secret',
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: secret));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Secret copied to clipboard')));
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy secret'),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (userId != null) {
                  Get.toNamed('/2fa-verify', arguments: {'userId': userId});
                } else {
                  Get.snackbar(
                      'Error', 'Missing user id for 2FA verification.');
                }
              },
              child: const Text('I scanned it — Verify now'),
            ),
          ],
        ),
      ),
    );
  }
}
