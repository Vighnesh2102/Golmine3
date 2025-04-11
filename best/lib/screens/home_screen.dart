import 'package:flutter/material.dart';
import 'package:best/widgets/category_button.dart';
import 'package:best/widgets/featured_estate_card.dart';
import 'package:best/widgets/nearby_estate_card.dart';
import 'package:best/widgets/OverlayEstateCard.dart';
import 'package:best/screens/search_screen.dart';
import 'package:best/screens/property_detail.dart';
import 'package:best/screens/filter_page.dart';
import 'package:best/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTabContent(),
    const Center(child: Text("Search Page", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Favorites Page", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Profile Page", style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/favorites');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
      default:
        Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({super.key, required this.selectedIndex, required this.onItemTapped});

  Widget _buildNavItem(IconData icon, int index, {bool isLarge = false}) {
    bool isSelected = selectedIndex == index;

    double iconSize = isLarge ? 29 : 28;
    double containerWidth = isLarge ? 31 : 30;
    double containerHeight = isLarge ? 35 : 34;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: containerWidth,
            height: containerHeight,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: iconSize,
              color: isSelected ? Colors.blue.shade900 : const Color(0xFF988A44),
            ),
          ),
          const SizedBox(height: 3),
          if (isSelected)
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 0, isLarge: true),
          _buildNavItem(Icons.search_outlined, 1, isLarge: true),
          _buildNavItem(Icons.favorite_border, 2),
          _buildNavItem(Icons.person_outline, 3),
        ],
      ),
    );
  }
}

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  void navigateToDetails(BuildContext context, Map<String, dynamic> property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
      Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      },
      child: const CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage('assets/profile.jpg'),
      ),
    ),
  ],
),

        const SizedBox(height: 16),

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            'Hey,',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            "Let's start exploring",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),

    

// Inside your build method:
TextField(
  readOnly: true,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  },
  decoration: InputDecoration(
    hintText: 'Search House, Apartment, etc',
    prefixIcon: const Icon(Icons.search, color: Colors.grey),
    suffixIcon: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilterPage(
              initialLocation: '', // Default or current location if any
              initialType: 'All', // Default type or selected one
              onApply: (filters) {
                // 🔥 This is where you can handle the result (optional)
                print('Applied Filters: $filters');
                // Optionally trigger setState or filter your listings
              },
            ),
          ),
        );
      },
      child: const Icon(Icons.filter_list, color: Colors.grey),
    ),
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
  ),
),

        const SizedBox(height: 16),

        // Category Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => print("All clicked"),
              child: CategoryButton(label: 'All', isSelected: true),
            ),
            GestureDetector(
              onTap: () => print("House clicked"),
              child: CategoryButton(label: 'House'),
            ),
            GestureDetector(
              onTap: () => print("Apartment clicked"),
              child: CategoryButton(label: 'Apartment'),
            ),
            GestureDetector(
              onTap: () => print("Land clicked"),
              child: CategoryButton(label: 'Land'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Overlay Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'Holiday Offer Villa',
                    'location': 'Bali, Indonesia',
                    'price': '1300',
                    'type': 'Villa',
                    'image': 'assets/property (1).jpg',
                    'bedrooms': 3,
                    'bathrooms': 2,
                    'area': 1600,
                  });
                },
                child: const OverlayEstateCard(
                  imageUrl: 'assets/property (1).jpg',
                  title: 'Offers..! ',
                  subtitle: 'All discounts up to 66%',
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'Special Sea Resort',
                    'location': 'Lombok, Indonesia',
                    'price': '900',
                    'type': 'Resort',
                    'image': 'assets/property (3).jpg',
                    'bedrooms': 2,
                    'bathrooms': 1,
                    'area': 1200,
                  });
                },
                child: const OverlayEstateCard(
                  imageUrl: 'assets/property (3).jpg',
                  title: 'Special offer!',
                  subtitle: 'All discounts up to 50%',
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'New Land Deal',
                    'location': 'Bandung, Indonesia',
                    'price': '450',
                    'type': 'Land',
                    'image': 'assets/property (4).jpg',
                    'bedrooms': 0,
                    'bathrooms': 0,
                    'area': 2500,
                  });
                },
                child: const OverlayEstateCard(
                  imageUrl: 'assets/property (4).jpg',
                  title: 'New Land..!!',
                  subtitle: 'All discounts up to 50%',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Featured Estates
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            'Featured Estates',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'Sky Dandelions Apartment',
                    'location': 'Jakarta, Indonesia',
                    'price': '290',
                    'type': 'Apartment',
                    'image': 'assets/property (3).jpg',
                    'bedrooms': 2,
                    'bathrooms': 1,
                    'area': 1000,
                  });
                },
                child: const FeaturedEstateCard(
                  imageUrl: 'assets/property (3).jpg',
                  title: 'Sky Dandelions Apartment',
                  subtitle: '4.9 Jakarta, Indonesia\n\$290/month',
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'New Moon Resort',
                    'location': 'Bali, Indonesia',
                    'price': '1500',
                    'type': 'Resort',
                    'image': 'assets/property (4).jpg',
                    'bedrooms': 4,
                    'bathrooms': 3,
                    'area': 2000,
                  });
                },
                child: const FeaturedEstateCard(
                  imageUrl: 'assets/property (4).jpg',
                  title: 'New Moon Resort',
                  subtitle: '5.0 Bali, Indonesia\n\$1500/month',
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'Pineapple Hill',
                    'location': 'Bali, Indonesia',
                    'price': '2000',
                    'type': 'Villa',
                    'image': 'assets/property (5).jpg',
                    'bedrooms': 5,
                    'bathrooms': 4,
                    'area': 3000,
                  });
                },
                child: const FeaturedEstateCard(
                  imageUrl: 'assets/property (5).jpg',
                  title: 'Pineapple Hill',
                  subtitle: '4.5 Bali, Indonesia\n\$2000/month',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Nearby Estates
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            'Nearby Estates',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'Cloud 9 Resort',
                    'location': 'Bali, Indonesia',
                    'price': '1500000',
                    'type': 'Resort',
                    'image': 'assets/property (6).jpg',
                    'bedrooms': 2,
                    'bathrooms': 2,
                    'area': 1800,
                  });
                },
                child: const NearbyEstateCard(
                  estateName: 'Cloud 9 Resort',
                  location: 'Bali, Indonesia',
                  price: '1,500,000 IDR/month',
                  imageUrl: 'assets/property (6).jpg',
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  navigateToDetails(context, {
                    'name': 'Tropical Breeze',
                    'location': 'Jakarta, Indonesia',
                    'price': '3000000',
                    'type': 'Apartment',
                    'image': 'assets/property (7).jpg',
                    'bedrooms': 3,
                    'bathrooms': 2,
                    'area': 1900,
                  });
                },
                child: const NearbyEstateCard(
                  estateName: 'Tropical Breeze',
                  location: 'Jakarta, Indonesia',
                  price: '3,000,000 IDR/month',
                  imageUrl: 'assets/property (7).jpg',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
