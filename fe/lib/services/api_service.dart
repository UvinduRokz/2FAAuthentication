import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auth_demo_flutter/env/env.dart';
import '../models/user_model.dart';

class ApiResponse {
  final bool success;
  final String message;
  final User? user;
  final int? userId;
  final String? qrCodeUrl;
  final String? otpAuthUrl;
  final String? secret;
  final String? qrImageBase64; // NEW: server may return inline PNG base64

  ApiResponse({
    required this.success,
    required this.message,
    this.user,
    this.userId,
    this.qrCodeUrl,
    this.otpAuthUrl,
    this.secret,
    this.qrImageBase64,
  });
}

class ApiService {
  static final String baseUrl = Env.baseUrl; // e.g. https://your-server/api

  static Future<ApiResponse> register(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
      );

      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      final message = data['message'] ?? 'Unknown error';

      final success = (response.statusCode == 201) ||
          message.toLowerCase().contains('success') ||
          message.toLowerCase().contains('registered');

      return ApiResponse(
        success: success,
        message: message,
      );
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Failed to connect to server');
    }
  }

  static Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      if (data.containsKey('id') && data.containsKey('email')) {
        final user = User.fromJson(data);
        final message = data['message'] ?? 'Login successful';
        return ApiResponse(success: true, message: message, user: user);
      }

      if (data.containsKey('userId')) {
        final message = data['message'] ?? '2FA required';
        final uid = (data['userId'] is int)
            ? data['userId']
            : int.tryParse(data['userId'].toString());
        final twoFaExpired = data['twoFaExpired'] ?? false;

        return ApiResponse(
          success: false,
          message: message,
          userId: uid,
          user: data.containsKey('username') ? User.fromJson(data) : null,
        );
      }

      final message = data['message'] ?? 'Invalid credentials';
      return ApiResponse(success: false, message: message);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Failed to connect to server');
    }
  }

  static Future<ApiResponse> setupTwoFactor(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/setup-2fa/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      final message = data['message'] ?? '';

      final String? otpAuthUrl = data['otpAuthUrl'] as String?;
      final String? qr =
          (data['qrCodeUrl'] ?? data['qrCode'] ?? null) as String?;
      final String? secret = data['secret'] as String?;
      final String? qrBase64 = data['qrImageBase64'] as String?;
      final uid = (data['userId'] is int)
          ? data['userId']
          : int.tryParse((data['userId'] ?? '').toString());

      final success = response.statusCode == 200 &&
          (otpAuthUrl != null || qr != null || qrBase64 != null);

      return ApiResponse(
          success: success,
          message: message,
          userId: uid,
          qrCodeUrl: qr,
          otpAuthUrl: otpAuthUrl,
          secret: secret,
          qrImageBase64: qrBase64);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Failed to connect to server');
    }
  }

  static Future<ApiResponse> verifyTwoFactor(int userId, int code) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/verify-2fa/$userId?code=$code');
      final response =
          await http.post(uri, headers: {'Content-Type': 'application/json'});

      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      final message = data['message'] ?? '';

      if (data.containsKey('id') && data.containsKey('email')) {
        final user = User.fromJson(data);
        return ApiResponse(success: true, message: message, user: user);
      }

      return ApiResponse(
          success: response.statusCode == 200 &&
              (message.toLowerCase().contains('successful') ||
                  message.toLowerCase().contains('verified')),
          message: message);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Failed to connect to server');
    }
  }

  static Future<ApiResponse> disableTwoFactor(
      int userId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/disable-2fa/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      final message = data['message'] ?? '';

      return ApiResponse(success: response.statusCode == 200, message: message);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Failed to connect to server');
    }
  }
}
