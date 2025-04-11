import 'package:flutter/material.dart';
import 'privacy_policy_page.dart';
import 'faq_support_page.dart';
import 'filter_page.dart';
import 'forgot_password.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Color(0xFF7C8500), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF7C8500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7C8500)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _userInfo(),
            const SizedBox(height: 20),
            // 👇 Liked properties section removed here 👇
            _settingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _userInfo() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/profile.jpg'),
        ),
        const SizedBox(height: 10),
        const Text(
          "Ganesh Swami",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C8500)),
        ),
        const Text(
          "ganeshswami2003@gmail.com",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _settingsSection(BuildContext context) {
    return Column(
      children: [
        _settingsTile(Icons.lock, "Change Password", () {
          Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
  );

        }),
        _settingsTile(Icons.notifications, "Notifications", () {}),
        _settingsTile(Icons.help_outline, "Help & Support", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FAQSupportPage()));
        }),
        _settingsTile(Icons.privacy_tip, "Privacy Policy", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
        }),
        _settingsTile(Icons.logout, "Logout", () {}),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4C600)),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: onTap,
    );
  }
}
