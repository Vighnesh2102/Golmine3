import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:best/widgets/empty_state.dart';
import 'package:best/widgets/property_card.dart';
import 'package:best/widgets/view_toggle.dart';
import 'package:best/widgets/search_bar_2.dart';
import 'package:best/screens/filter_page.dart';
import 'package:best/screens/home_screen.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isGridView = true;
  String _currentLocationFilter = '';
  String _currentTypeFilter = 'All';

  final List<Map<String, dynamic>> properties = List.generate(10, (index) {
    final types = ['House', 'Apartment', 'Villa'];
    final locations = ['Kharadi, Pune', 'Vimannagar, Pune', 'Hadapsar, Pune', 'Bali, Indonesia'];
    return {
      'name': ['Bungalow', 'Modern House', 'Mill Sper', 'Flower Heaven'][index % 4],
      'price': [235, 260, 271, 370][index % 4],
      'location': locations[index % locations.length],
      'type': types[index % types.length],
      'image': 'assets/image${(index % 4) + 1}.jpg',
      'isFavorite': false,
    };
  });

 List<Map<String, dynamic>> get filteredProperties => properties.where((property) {
  final query = _searchController.text.toLowerCase();
  final matchesSearch = query.isEmpty ||
      property['name'].toLowerCase().contains(query) ||
      property['location'].toLowerCase().contains(query); // include location in search
  final matchesLocation = _currentLocationFilter.isEmpty || property['location'] == _currentLocationFilter;
  final matchesType = _currentTypeFilter == 'All' || property['type'] == _currentTypeFilter;
  return matchesSearch && matchesLocation && matchesType;
}).toList();


  void _toggleFavorite(int index) {
    setState(() => properties[index]['isFavorite'] = !properties[index]['isFavorite']);
  }

  Future<void> _openFilter() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          initialLocation: _currentLocationFilter,
          initialType: _currentTypeFilter,
          onApply: (filters) {
            setState(() {
              _currentLocationFilter = filters['location'];
              _currentTypeFilter = filters['propertyType'];
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomSearchBar(controller: _searchController, onChanged: () => setState(() {})),
            const SizedBox(height: 16),
            ViewToggle(
              isGridView: isGridView,
              itemCount: filteredProperties.length,
              onToggle: (value) => setState(() => isGridView = value),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildPropertyList()),
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
      'Search results',
      style: GoogleFonts.raleway(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF988A44),
      ),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF988A44)),
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      },
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.tune, color: Color(0xFF988A44)),
        onPressed: _openFilter,
      ),
    ],
  );
}

  Widget _buildPropertyList() {
    if (filteredProperties.isEmpty) {
      return const EmptyState();
    }
    return isGridView
        ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: filteredProperties.length,
            itemBuilder: (context, index) => PropertyCard(
              property: filteredProperties[index],
              index: index,
              isGrid: true,
              onToggleFavorite: () => _toggleFavorite(index),
            ),
          )
        : ListView.builder(
            itemCount: filteredProperties.length,
            itemBuilder: (context, index) => PropertyCard(
              property: filteredProperties[index],
              index: index,
              isGrid: false,
              onToggleFavorite: () => _toggleFavorite(index),
            ),
          );
  }
}
