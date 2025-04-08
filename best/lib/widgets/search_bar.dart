import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Color searchIconColor = Colors.grey;
  Color filterIconColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search House, Apartment, etc',
        prefixIcon: InkWell(
          onTap: () {
            setState(() => searchIconColor = Colors.brown);
            print("Search icon clicked");
          },
          child: Icon(Icons.search, color: searchIconColor),
        ),
        suffixIcon: InkWell(
          onTap: () {
            setState(() => filterIconColor = Colors.brown);
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
  }
}
