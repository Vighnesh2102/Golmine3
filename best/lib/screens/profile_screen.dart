import 'package:flutter/material.dart';
import 'privacy_policy_page.dart';
import 'faq_support_page.dart';

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
    // Sample list of liked properties - empty for demonstration
   // final List<Map<String, String>> likedProperties = []; // Empty list
    final List<Map<String, String>> likedProperties = [
  {
    'title': 'Brookvale Villa',
    'price': '\$320/month',
    'image': 'assets/house1.jpg'
  },
  {
    'title': 'The Overdale Apartment',
    'price': '\$290/month',
    'image': 'assets/house2.jpg'
  },
];
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
            // Only show liked properties section if there are properties
            if (likedProperties.isNotEmpty) ...[
              _likedPropertiesSection(likedProperties),
              const SizedBox(height: 20),
            ],
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

  Widget _likedPropertiesSection(List<Map<String, String>> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Liked Properties",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7C8500)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: properties.map((property) => 
              _propertyCard(property['title']!, property['price']!, property['image']!)
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _propertyCard(String title, String price, String image) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              image,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C8500))),
                const SizedBox(height: 5),
                Text(price, style: const TextStyle(color: Color(0xFFD4C600), fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  children: const [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(" 5.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    return Column(
      children: [
        _settingsTile(Icons.lock, "Change Password", () {}),
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
