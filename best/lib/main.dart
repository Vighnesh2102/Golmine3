import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart'; // Import login screen
import 'package:best/screens/home_screen.dart'; // Home screen after login
import 'package:best/screens/search_screen.dart'; // Import other page screens
//import 'pages/favorite_page.dart';
import 'package:best/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set splash screen as the initial route
      routes: {
        '/': (context) => SplashScreen(), // Splash screen route
        '/login': (context) => LoginScreen(), // Login screen route
        '/home': (context) => HomeScreen(), // Home screen after login
        '/search': (context) => SearchResultsPage(), // Search page route
       // '/favorites': (context) => FavoritePage(), // Favorites page route
        '/profile': (context) => ProfilePage(), // Profile page route
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page after splash
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
