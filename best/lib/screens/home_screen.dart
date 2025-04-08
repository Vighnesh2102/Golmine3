import 'package:flutter/material.dart';
import 'package:best/widgets/category_button.dart';
import 'package:best/widgets/featured_estate_card.dart';
import 'package:best/widgets/location_card.dart';
import 'package:best/widgets/nearby_estate_card.dart';
import 'package:best/widgets/OverlayEstateCard.dart';
import 'package:best/widgets/bottom_nav.dart';
import 'package:best/screens/search_screen.dart'; // Assuming you have a separate BottomNavBar widget

// HomeScreen widget
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage(); // HomeScreen now points to the HomePage
  }
}

// HomePage widget (Stateful) for managing selected index and bottom nav
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Declare the selectedIndex and the function to handle tab changes
  int _selectedIndex = 0;

  // List of pages for each navigation tab (directly using routes instead of manually managing pages)
  final List<Widget> _pages = [
    const HomeTabContent(),  // Home page content
    const Center(child: Text("Search Page", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Favorites Page", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Profile Page", style: TextStyle(fontSize: 24))),
  ];

  // 2. Function to update the selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the respective page via the route based on the index
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/search');
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
      body: SafeArea(child: _pages[_selectedIndex]), // Display the selected page based on index
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex, // Pass the selectedIndex to BottomNavBar
        onItemTapped: _onItemTapped, // Pass the function to handle item taps
      ),
    );
  }
}

// BottomNavBar widget (you already have it, make sure to pass parameters correctly)
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

// HomeTabContent widget (the actual content of the home tab)
class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: const Text(
            'Hey,',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            "Let's start exploring",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Search bar with interactions
        StatefulBuilder(
          builder: (context, setState) {
            Color searchIconColor = Colors.grey;
            Color filterIconColor = Colors.grey;

            return TextField(
              onChanged: (query) {
                // Navigate to SearchScreen as soon as typing starts
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchResultsPage()),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search House, Apartment, etc',
                prefixIcon: InkWell(
                  onTap: () {
                    // Update the color when search icon is tapped
                    setState(() {
                      searchIconColor = (searchIconColor == Colors.grey) ? Colors.brown : Colors.grey;
                    });
                    print("Search icon clicked");
                  },
                  child: Icon(Icons.search, color: searchIconColor),
                ),
                suffixIcon: InkWell(
                  onTap: () {
                    // Update the color when filter icon is tapped
                    setState(() {
                      filterIconColor = (filterIconColor == Colors.grey) ? Colors.brown : Colors.grey;
                    });
                    print("Filter icon clicked");
                  },
                  child: Icon(Icons.filter_list, color: filterIconColor),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Category Buttons (House, Apartment, Land)
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

        // Estate Cards (Offers, Featured Estates)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              OverlayEstateCard(
                imageUrl: 'assets/property (1).jpg',
                title: 'Offers..! ',
                subtitle: 'All discounts up to 66%',
              ),
              SizedBox(width: 16),
              OverlayEstateCard(
                imageUrl: 'assets/property (3).jpg',
                title: 'Special offer!',
                subtitle: 'All discounts up to 50%',
              ),
              SizedBox(width: 16),
              OverlayEstateCard(
                imageUrl: 'assets/property (4).jpg',
                title: 'New Land..!!',
                subtitle: 'All discounts up to 50%',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Featured Estates section
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            'Featured Estates',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              FeaturedEstateCard(
                imageUrl: 'assets/property (3).jpg',
                title: 'Sky Dandelions Apartment',
                subtitle: '4.9 Jakarta, Indonesia\n\$290/month',
              ),
              SizedBox(width: 16),
              FeaturedEstateCard(
                imageUrl: 'assets/property (4).jpg',
                title: 'New Moon Resort',
                subtitle: '5.0 Bali, Indonesia\n\$1500/month',
              ),
              SizedBox(width: 16),
              FeaturedEstateCard(
                imageUrl: 'assets/property (5).jpg',
                title: 'Pineapple Hill',
                subtitle: '4.5 Bali, Indonesia\n\$2000/month',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Nearby Estates section
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            'Nearby Estates',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              NearbyEstateCard(
                estateName: 'Cloud 9 Resort',
                location: 'Bali, Indonesia',
                price: '1,500,000 IDR/month',
                imageUrl: 'assets/property (6).jpg',
              ),
              SizedBox(width: 16),
              NearbyEstateCard(
                estateName: 'Tropical Breeze',
                location: 'Jakarta, Indonesia',
                price: '3,000,000 IDR/month',
                imageUrl: 'assets/property (7).jpg',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
