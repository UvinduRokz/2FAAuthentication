import 'package:auth_demo_flutter/screens/two_factor_qr_screen.dart';
import 'package:auth_demo_flutter/screens/two_factor_verify_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/2fa-qr', page: () => TwoFactorQrScreen()),
        GetPage(name: '/2fa-verify', page: () => TwoFactorVerifyScreen()),
      ],
    );
  }
}
