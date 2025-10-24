import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  var user = Rxn<User>();
  var pending2FaUserId = RxnInt();

  Future<ApiResponse> login(String email, String password) async {
    final response = await ApiService.login(email, password);
    if (response.success && response.user != null) {
      user.value = response.user;
      Get.offAllNamed('/home');
    } else {
      if (!response.success && response.userId != null) {
        // 🔹 new: check expiration
        if (response.message.toLowerCase().contains('expired')) {
          Get.snackbar('2FA Expired', 'Please re-verify your 2FA setup.');
          Get.toNamed('/2fa-verify', arguments: {
            'userId': response.userId,
            'expired': true,
          });
        } else {
          pending2FaUserId.value = response.userId;
          Get.toNamed('/2fa-verify');
        }
      }
    }
    return response;
  }

  Future<ApiResponse> signup(
      String username, String email, String password) async {
    final response = await ApiService.register(username, email, password);
    if (response.success) {
      Get.offAllNamed('/login');
    }
    return response;
  }

  Future<ApiResponse> setupTwoFactor() async {
    if (user.value == null) {
      return ApiResponse(success: false, message: 'Not logged in');
    }
    final resp = await ApiService.setupTwoFactor(user.value!.id);
    if (resp.success) {
      final payload = resp.otpAuthUrl ?? resp.qrImageBase64 ?? resp.qrCodeUrl;
      final bool isImageUrl = (resp.otpAuthUrl == null &&
          resp.qrImageBase64 == null &&
          resp.qrCodeUrl != null);
      final bool isBase64 = resp.qrImageBase64 != null;

      if (payload != null) {
        Get.toNamed('/2fa-qr', arguments: {
          'qrPayload': payload,
          'isImageUrl': isImageUrl,
          'isBase64': isBase64,
          'userId': user.value!.id,
          'secret': resp.secret
        });
      }
    }
    return resp;
  }

  Future<ApiResponse> verifyTwoFactor(int userId, int code) async {
    final resp = await ApiService.verifyTwoFactor(userId, code);
    if (resp.success) {
      if (resp.user != null) {
        user.value = resp.user;
        Get.offAllNamed('/home');
      } else {
        if (user.value == null)
          Get.offAllNamed('/login');
        else
          Get.offAllNamed('/home');
      }
    }
    return resp;
  }

  Future<ApiResponse> disableTwoFactor(int userId, String password) async {
    final resp = await ApiService.disableTwoFactor(userId, password);
    if (resp.success) {
      // update user locally if present
      if (user.value != null) {
        user.value = user.value!.copyWith(twoFaEnabled: false);
      }
    }
    return resp;
  }
}
