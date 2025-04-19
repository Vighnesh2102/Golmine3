import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_page.dart';

class AddInformationPage extends StatefulWidget {
  @override
  _AddInformationPageState createState() => _AddInformationPageState();
}

class _AddInformationPageState extends State<AddInformationPage> {
  int bedrooms = 3;
  int bathrooms = 2;
  int balconies = 2;
  int totalRooms = 6;
  bool isMonthly = true;

  TextEditingController sellPriceController =
      TextEditingController(text: "180000");
  TextEditingController rentPriceController =
      TextEditingController(text: "315");

  final List<String> facilities = [
    "Parking Lot",
    "Pet Allowed",
    "Garden",
    "Gym",
    "Park",
    "Home Theatre",
    "Kid’s Friendly"
  ];

  final Set<String> selectedFacilities = {"Parking Lot", "Garden", "Gym"};

  void toggleFacility(String facility) {
    setState(() {
      if (selectedFacilities.contains(facility)) {
        selectedFacilities.remove(facility);
      } else {
        selectedFacilities.add(facility);
      }
    });
  }

  void _onFinishPressed() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SuccessPage()),
  );
}


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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 22, color: Colors.black),
                children: [
                  TextSpan(text: "Almost "),
                  TextSpan(
                    text: "finish",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ", complete the listing"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sell Price Input
            Text("Sell Price (₹)",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            _buildPriceField(sellPriceController),

            // Rent Price Input
            const SizedBox(height: 15),
            Text("Rent Price (₹)",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            _buildPriceField(rentPriceController, isRent: true),

            // Rent Type Toggle
            const SizedBox(height: 15),
            Row(
              children: [
                _buildToggleButton("Monthly", isMonthly,
                    () => setState(() => isMonthly = true)),
                const SizedBox(width: 10),
                _buildToggleButton("Yearly", !isMonthly,
                    () => setState(() => isMonthly = false)),
              ],
            ),

            // Property Features
            const SizedBox(height: 20),
            Text("Property Features",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _buildFeatureRow(
                "Bedroom", bedrooms, (val) => setState(() => bedrooms = val)),
            _buildFeatureRow("Bathroom", bathrooms,
                (val) => setState(() => bathrooms = val)),
            _buildFeatureRow(
                "Balcony", balconies, (val) => setState(() => balconies = val)),

            // Total Rooms
            const SizedBox(height: 20),
            Text("Total Rooms",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [4, 6].map((val) {
                bool selected = totalRooms == val;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildIconButton(val.toString(), selected,
                      () => setState(() => totalRooms = val)),
                );
              }).toList(),
            ),

            // Environment / Facilities
            const SizedBox(height: 20),
            Text("Environment / Facilities",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: facilities.map((facility) {
                return _buildFacilityButton(facility);
              }).toList(),
            ),

            // Finish Button
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8C100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _onFinishPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Finish",
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.white)),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField(TextEditingController controller,
      {bool isRent = false}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixText: "₹ ",
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 16, color: isSelected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
      String title, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 16)),
          Row(
            children: [
              _buildFeatureButton(
                  Icons.remove, () => onChanged(value > 0 ? value - 1 : 0)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(value.toString(),
                    style: GoogleFonts.poppins(fontSize: 18)),
              ),
              _buildFeatureButton(Icons.add, () => onChanged(value + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black54),
    );
  }

  Widget _buildIconButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 16, color: isSelected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildFacilityButton(String facility) {
    bool isSelected = selectedFacilities.contains(facility);
    return _buildIconButton(
        facility, isSelected, () => toggleFacility(facility));
  }
}