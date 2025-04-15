import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:best/di/injection_container.dart' as di;

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/email_verification.dart';
import 'screens/favorites_screen.dart';
import 'screens/property_detail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://iyajxzfteobmvuodghzg.supabase.co', // Replace with your NEW Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5YWp4emZ0ZW9ibXZ1b2RnaHpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0NTE1OTYsImV4cCI6MjA2MDAyNzU5Nn0.jw-STWXrFB10lRaC3H62Ty9xHtdli7CZVIedfLUPs80', // Replace with your NEW Supabase anon key
  );

  // Initialize dependency injection
  await di.initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        primaryColor: const Color(0xFF988A44),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF988A44),
          primary: const Color(0xFF988A44),
        ),
      ),
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/search', page: () => const SearchPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/favorites', page: () => const FavoritesScreen()),
        GetPage(
            name: '/forgot-password', page: () => const ForgotPasswordScreen()),
        GetPage(
            name: '/email-verification',
            page: () => const EmailVerificationScreen()),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animation/home_animation.json',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
