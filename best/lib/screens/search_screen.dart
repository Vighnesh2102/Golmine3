import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:best/screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate UI',
     
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF988A44),
        textTheme: GoogleFonts.ralewayTextTheme(),
      ),
      home: const SearchResultsPage(),
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredProperties = [];

  final List<String> locationSuggestions = [
    'Wagholi', 'Viman Nagar', 'Kharadi', 'Hinjewadi', 'Baner',
    'Koregaon Park', 'Hadapsar', 'Pashan', 'Kondhwa', 'Shivaji Nagar',
  ];

  final List<String> propertyImages = [
    'assets/image1.jpg', 'assets/image2.jpg', 'assets/image3.jpg', 'assets/image4.jpg',
  ];

  late List<Map<String, dynamic>> properties;

  @override
  void initState() {
    super.initState();
    properties = List.generate(
      24,
          (index) => {
        'name': 'House ${index + 1}',
        'price': 200 + index * 10,
        'location': locationSuggestions[index % locationSuggestions.length],
        'rating': 4.5 + (index % 5) * 0.1,
        'image': propertyImages[index % propertyImages.length],
        'isFavorite': false, // New field
      },
    );
    filteredProperties = List.from(properties);
  }

  void _toggleFavorite(int index) {
    setState(() {
      filteredProperties[index]['isFavorite'] = !(filteredProperties[index]['isFavorite'] ?? false);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredProperties = properties
          .where((property) => property['location'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTopRow(),
            const SizedBox(height: 16),
            _buildPropertyList(),
          ],
        ),
      ),
    );
  }

 AppBar _buildAppBar() {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text(
      'Search ',
      style: GoogleFonts.raleway(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF988A44),
      ),
    ),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF988A44)),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomeScreen()), // Ensure AnotherPage is properly defined
        );
      },
    ),
    actions: [
      Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        child: const Icon(
          Icons.filter_list,
          size: 20,
          color: Color(0xFF988A44),
        ),
      ),
    ],
  );
}


 Widget _buildSearchBar() {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search for houses',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(Icons.search, color: Colors.brown[600]),
          onPressed: () {
            // Navigate to the SearchResultsPage
            
          },
        ),
      ),
    ],
  );
}


  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Found ${filteredProperties.length} estates',
          style: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.grid_view, color: isGridView ? Colors.black : Colors.grey),
              onPressed: () => setState(() => isGridView = true),
            ),
            IconButton(
              icon: Icon(Icons.list, color: !isGridView ? Colors.black : Colors.grey),
              onPressed: () => setState(() => isGridView = false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyList() {
    return Expanded(
      child: isGridView
          ? GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: filteredProperties.length,
        itemBuilder: (context, index) => _buildPropertyCard(filteredProperties[index], index),
      )
          : ListView.builder(
        itemCount: filteredProperties.length,
        itemBuilder: (context, index) => _buildPropertyCard(filteredProperties[index], index),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  property['image'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 100, color: Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property['name'],
                        style: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("\$${property['price']}/month",
                        style: GoogleFonts.raleway(color: Colors.green, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text("${property['rating']}", overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(property['location'], overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _toggleFavorite(index),
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    property['isFavorite'] ?? false ? Icons.favorite : Icons.favorite_border,
                    size: 11,
                    color: property['isFavorite'] ?? false ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
