import 'package:flutter/material.dart';
import 'package:best/widgets/category_button.dart';
import 'package:best/widgets/featured_estate_card.dart';
import 'package:best/widgets/nearby_estate_card.dart';
import 'package:best/widgets/OverlayEstateCard.dart';
import 'package:best/widgets/bottom_nav_bar.dart';
import 'package:best/screens/search_screen.dart';
import 'package:best/screens/property_detail.dart';
import 'package:best/screens/filter_page.dart';
import 'package:best/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart' as location_package;
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin, sin, pi;

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: const HomeTabContent(),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}

class HomeTabContent extends StatefulWidget {
  const HomeTabContent({super.key});

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables
  List<Map<String, dynamic>> _nearbyProperties = [];
  bool _isLoadingProperties = true;
  bool _showAllNearbyProperties = false;

  // Location state variables
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;
  double _searchRadiusKm = 10.0; // Default radius in kilometers

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Get user's current location
  Future<void> _getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      setState(() {});

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are disabled. Please enable them.';
        _isLoadingLocation = false;
        setState(() {});
        _loadNearbyProperties(); // Load with default coordinates
        return;
      }

      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Location permissions are denied.';
          _isLoadingLocation = false;
          setState(() {});
          _loadNearbyProperties(); // Load with default coordinates
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permissions are permanently denied.';
        _isLoadingLocation = false;
        setState(() {});
        _loadNearbyProperties(); // Load with default coordinates
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _isLoadingLocation = false;
      setState(() {});

      // Load nearby properties with the current location
      _loadNearbyProperties(_currentPosition);
    } catch (e) {
      _locationError = 'Error getting location: $e';
      _isLoadingLocation = false;
      setState(() {});
      _loadNearbyProperties(); // Load with default coordinates as fallback
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // Radius of Earth in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c; // Distance in kilometers
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _loadNearbyProperties([Position? position]) async {
    try {
      setState(() {
        _isLoadingProperties = true;
      });

      // Default coordinates for Pune if position is null
      double latitude = position?.latitude ?? 18.5204;
      double longitude = position?.longitude ?? 73.8567;

      // Fetch properties from Supabase
      final response = await _supabase.from('properties').select('*').limit(10);

      List<Map<String, dynamic>> propertiesData =
          List<Map<String, dynamic>>.from(response);

      // If we have position, calculate distance and sort by proximity
      if (position != null) {
        // Add distance to each property
        for (var property in propertiesData) {
          // Parse location data - handle both string and double types
          double propertyLat = 0.0;
          double propertyLng = 0.0;

          if (property['latitude'] != null) {
            propertyLat = property['latitude'] is String
                ? double.tryParse(property['latitude']) ?? 0.0
                : (property['latitude'] ?? 0.0);
          }

          if (property['longitude'] != null) {
            propertyLng = property['longitude'] is String
                ? double.tryParse(property['longitude']) ?? 0.0
                : (property['longitude'] ?? 0.0);
          }

          // Calculate distance if coordinates are valid
          if (propertyLat != 0.0 && propertyLng != 0.0) {
            double distance = _calculateDistance(
                latitude, longitude, propertyLat, propertyLng);
            property['distance'] = distance;
          } else {
            property['distance'] =
                double.infinity; // Put at the end of the list
          }
        }

        // Sort by distance
        propertiesData.sort((a, b) =>
            (a['distance'] as double).compareTo(b['distance'] as double));
      }

      // Format properties for display
      _nearbyProperties = propertiesData.map((property) {
        String city = property['city'] ?? 'Unknown City';
        String title = property['title'] ?? 'Property';
        String price = property['price'] != null
            ? '₹${property['price']}'
            : 'Price on request';
        String bedroom = property['bedrooms']?.toString() ?? '0';
        String bathroom = property['bathrooms']?.toString() ?? '0';
        String area = property['area'] != null
            ? '${property['area']} sq.ft.'
            : 'Area not specified';
        String image = property['image_url'] ??
            'https://images.unsplash.com/photo-1480074568708-e7b720bb3f09?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1474&q=80';

        String distance = '';
        if (property.containsKey('distance') &&
            property['distance'] != double.infinity) {
          distance = '${property['distance'].toStringAsFixed(1)} km away';
        }

        return {
          'id': property['id'] ?? '',
          'name': title,
          'location': city + (distance.isNotEmpty ? ' • $distance' : ''),
          'price': price,
          'type': property['property_type'] ?? 'House',
          'image': image,
          'bedrooms': bedroom,
          'bathrooms': bathroom,
          'area': area,
          'isFavorite': false,
        };
      }).toList();

      // If no properties found or error, use mock data
      if (_nearbyProperties.isEmpty) {
        _nearbyProperties = _getMockNearbyProperties();
      }

      setState(() {
        _isLoadingProperties = false;
      });
    } catch (e) {
      print('Error loading properties: $e');
      // Use mock data as fallback
      setState(() {
        _nearbyProperties = _getMockNearbyProperties();
        _isLoadingProperties = false;
      });
    }
  }

  void _viewAllProperties() {
    setState(() {
      _showAllNearbyProperties = true;
    });
  }

  void _contactViaWhatsApp() {
    if (!_formKey.currentState!.validate()) return;

    // Construct WhatsApp message
    final name = _nameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final message = _messageController.text;

    final whatsappMessage = '''
*New Contact from Real Estate App*
-----------------
*Name:* $name
*Email:* $email
*Phone:* $phone
-----------------
*Message:* 
$message
-----------------
    ''';

    // Replace with your admin WhatsApp number
    final adminPhone =
        '912345678910'; // Format: country code + phone number without +

    // Encode message for URL
    final encodedMessage = Uri.encodeComponent(whatsappMessage);

    // Create WhatsApp URL
    final whatsappUrl = 'https://wa.me/$adminPhone?text=$encodedMessage';

    // Launch WhatsApp
    launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);

    // Clear form
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _messageController.clear();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening WhatsApp to send your message'),
        backgroundColor: Color(0xFF7C8500),
      ),
    );
  }

  void _navigateToPropertyDetails(String propertyId) {
    // Find the property in the list
    final property = _nearbyProperties.firstWhere(
      (p) => p['id'] == propertyId,
      orElse: () => _getMockNearbyProperties().first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(property: property),
      ),
    );
  }

  // Helper method to check if a string is a valid UUID
  bool _isValidUuid(String str) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(str);
  }

  Future<void> _togglePropertyFavorite(Map<String, dynamic> property) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      // User not logged in, prompt to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to save favorites'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
      );
      return;
    }

    try {
      // Get the property ID and ensure it's valid
      final propertyId = property['id'];

      if (propertyId == null) {
        throw Exception('Property ID is missing');
      }

      // Check if the property ID is a valid UUID or needs conversion
      String formattedPropertyId;

      if (!_isValidUuid(propertyId.toString())) {
        print(
            'Invalid UUID format: $propertyId, creating property in database first');

        // Create a new property entry with a valid UUID
        final newProperty = {
          'title': property['name'] ?? 'Property',
          'description':
              'Beautiful property in ${property['location'] ?? 'Unknown location'}',
          'price': property['price'] != null
              ? double.tryParse(property['price']
                      .toString()
                      .replaceAll(RegExp(r'[^\d.]'), '')) ??
                  0
              : 0,
          'city': property['location']?.toString().split(',').first.trim() ??
              'Unknown',
          'state': property['location']?.toString().contains(',') == true
              ? property['location'].toString().split(',').last.trim()
              : 'Unknown',
          'country': 'India',
          'address': 'Address details',
          'zip_code': '411000',
          'property_type': property['type'] ?? 'House',
          'bedrooms':
              int.tryParse(property['bedrooms']?.toString() ?? '0') ?? 3,
          'bathrooms':
              double.tryParse(property['bathrooms']?.toString() ?? '0') ?? 2,
          'area': double.tryParse(property['area']
                      ?.toString()
                      .replaceAll(RegExp(r'[^\d.]'), '') ??
                  '0') ??
              1200,
          'owner_id': user.id, // Set the current user as owner
          'created_at': DateTime.now().toIso8601String(),
          // Add required fields from database schema
          'status': 'available',
        };

        // Insert the property and get the UUID
        final propertyResponse = await client
            .from('properties')
            .insert(newProperty)
            .select('id')
            .single();

        formattedPropertyId = propertyResponse['id'];

        // Update the property in our widget
        property['id'] = formattedPropertyId;

        print('Created property with UUID: $formattedPropertyId');
      } else {
        formattedPropertyId = propertyId.toString();
      }

      // Check if the property is already in favorites
      final response = await client
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('property_id', formattedPropertyId)
          .maybeSingle();

      if (response != null) {
        // Remove from favorites
        await client.from('favorites').delete().match({
          'user_id': user.id,
          'property_id': formattedPropertyId,
        });

        // Update UI state
        int index =
            _nearbyProperties.indexWhere((p) => p['id'] == property['id']);
        if (index != -1) {
          setState(() {
            _nearbyProperties[index]['isFavorite'] = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Add to favorites
        await client.from('favorites').insert({
          'user_id': user.id,
          'property_id': formattedPropertyId,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Update UI state
        int index =
            _nearbyProperties.indexWhere((p) => p['id'] == property['id']);
        if (index != -1) {
          setState(() {
            _nearbyProperties[index]['isFavorite'] = true;
          });
        }

        // Show confirmation and option to view favorites
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Added to favorites'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View All',
              onPressed: () => Navigator.pushNamed(context, '/favorites'),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this method to provide mock data
  List<Map<String, dynamic>> _getMockNearbyProperties() {
    return [
      {
        'id': '1',
        'name': '3 BHK Apartment',
        'location': 'Pune • 2.3 km away',
        'price': '₹45L',
        'type': 'Apartment',
        'bedrooms': '3',
        'bathrooms': '2',
        'area': '1800 sq.ft.',
        'image':
            'https://images.unsplash.com/photo-1480074568708-e7b720bb3f09?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1474&q=80',
        'isFavorite': false,
      },
      {
        'id': '2',
        'name': 'Villa with Garden',
        'location': 'Pune • 3.5 km away',
        'price': '₹95L',
        'type': 'Villa',
        'bedrooms': '4',
        'bathrooms': '3',
        'area': '2500 sq.ft.',
        'image':
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
        'isFavorite': false,
      },
    ];
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
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
          ).createShader(bounds),
          child: const Text(
            "Let's start exploring",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),

        // Search Bar
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
                  _navigateToPropertyDetails('1');
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
                  _navigateToPropertyDetails('2');
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
                  _navigateToPropertyDetails('3');
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
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _navigateToPropertyDetails('4');
                },
                child: const FeaturedEstateCard(
                  imageUrl: 'assets/property (3).jpg',
                  estateName: 'Sky Dandelions Apartment',
                  location: 'Jakarta, Indonesia',
                  price: 290,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  _navigateToPropertyDetails('5');
                },
                child: const FeaturedEstateCard(
                  imageUrl: 'assets/property (4).jpg',
                  estateName: 'New Moon Resort',
                  location: 'Bali, Indonesia',
                  price: 1500,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  _navigateToPropertyDetails('6');
                },
                child: const FeaturedEstateCard(
                  imageUrl: 'assets/property (5).jpg',
                  estateName: 'Pineapple Hill',
                  location: 'Bali, Indonesia',
                  price: 2000,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Nearby Estates - UPDATED SECTION
        _buildNearbyPropertiesTitle(),
        const SizedBox(height: 8),

        // Show location status if trying to get location or if there was an error
        if (_isLoadingLocation || _locationError?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(
                  _isLoadingLocation
                      ? Icons.location_searching
                      : Icons.location_off,
                  size: 16,
                  color: _isLoadingLocation ? Colors.grey : Colors.red[300],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isLoadingLocation
                        ? 'Getting your location for nearby properties...'
                        : 'Location unavailable: $_locationError',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isLoadingLocation ? Colors.grey : Colors.red[300],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Loading indicator while fetching properties
        if (_isLoadingProperties)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C8500)),
          )
        else if (_nearbyProperties.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Icon(Icons.home_work, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No nearby properties found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_currentPosition != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Try increasing your search radius',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              // Display properties in a grid or list depending on screen size
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _showAllNearbyProperties
                    ? _nearbyProperties.length
                    : _nearbyProperties.length > 4
                        ? 4
                        : _nearbyProperties.length,
                itemBuilder: (context, index) {
                  return _buildNearbyEstateCard(
                      _nearbyProperties[index], index);
                },
              ),
              const SizedBox(height: 16),

              // Show More button
              if (_nearbyProperties.length > 4 && !_showAllNearbyProperties)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAllNearbyProperties = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF988A44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Show More',
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),

              // Show Less button
              if (_showAllNearbyProperties && _nearbyProperties.length > 4)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllNearbyProperties = false;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Show Less',
                        style: GoogleFonts.raleway(
                          color: const Color(0xFF988A44),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_upward,
                          color: Color(0xFF988A44), size: 16),
                    ],
                  ),
                ),
            ],
          ),

        const SizedBox(height: 40),

        // Contact Us Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
                ).createShader(bounds),
                child: const Text(
                  'Contact Us',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Have questions about a property? Send us a message and we\'ll respond as soon as possible.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFF7C8500)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF7C8500), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon:
                            const Icon(Icons.email, color: Color(0xFF7C8500)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF7C8500), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon:
                            const Icon(Icons.phone, color: Color(0xFF7C8500)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF7C8500), width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Your Message',
                        prefixIcon:
                            const Icon(Icons.message, color: Color(0xFF7C8500)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF7C8500), width: 2),
                        ),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _contactViaWhatsApp,
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: Text(
                          'Contact via WhatsApp',
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF25D366), // WhatsApp green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  // Update the nearby properties title to reflect location
  Widget _buildNearbyPropertiesTitle() {
    if (_isLoadingLocation) {
      return Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
            ).createShader(bounds),
            child: const Text(
              'Finding Nearby Estates...',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF988A44),
            ),
          ),
        ],
      );
    } else if (_locationError?.isNotEmpty == true) {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
        ).createShader(bounds),
        child: const Text(
          'Popular Estates',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    } else {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.amber, Color.fromARGB(198, 70, 53, 2)],
        ).createShader(bounds),
        child: const Text(
          'Nearby Estates',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }
  }

  // Update widget to display property distance if available
  Widget _buildNearbyEstateCard(Map<String, dynamic> property, int index) {
    // Parse the price string to extract the numeric value
    String priceStr = property['price'] ?? '₹0';
    // Remove any non-numeric characters except for digits
    priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    // Parse to int, default to 0 if unable to parse
    int priceValue = int.tryParse(priceStr) ?? 0;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _navigateToPropertyDetails(property['id']),
          child: NearbyEstateCard(
            estateName: property['name'],
            location: property['location'],
            price: priceValue,
            imageUrl: property['image'],
          ),
        ),
        // Add the like button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _togglePropertyFavorite(property),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                property['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: property['isFavorite'] ? Colors.red : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
