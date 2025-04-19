import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_location.dart';

class AddListingPage extends StatefulWidget {
  @override
  _AddListingPageState createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  String _selectedListingType = 'Rent';
  String _selectedCategory = 'House';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Listing',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Text
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: 'Hi Josh, Fill detail of your '),
                  TextSpan(
                    text: 'real estate',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Property Name Input Field
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                hintText: 'The Lodge House',
                hintStyle: GoogleFonts.poppins(fontSize: 16),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(Icons.home_outlined,
                      color: Colors.black54, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Listing Type
            Text(
              'Listing type',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: ['Rent', 'Sell'].map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    labelPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    label: Text(
                      type,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedListingType == type
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    selected: _selectedListingType == type,
                    selectedColor: Colors.blueGrey[900],
                    backgroundColor: Colors.grey.shade300,
                    onSelected: (selected) {
                      setState(() => _selectedListingType = type);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 35),

            // Property Category
            Text(
              'Property category',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['House', 'Apartment', 'Hotel', 'Villa', 'Cottage']
                  .map((category) {
                return ChoiceChip(
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  label: Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _selectedCategory == category,
                  selectedColor: Colors.blueGrey[900],
                  backgroundColor: Colors.grey.shade300,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                );
              }).toList(),
            ),
            const Spacer(),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button (Rounded with Shadow)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    child: const Icon(Icons.arrow_back,
                        color: Colors.black, size: 28),
                  ),
                ),

                // Next Button (Gradient Style)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC1D000), Color(0xFF7A8900)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddLocationPage()),
                      );
                    },
                    child: Text(
                      'Next',
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
