import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.toNamed('/search');
        break;
      case 2:
        Get.toNamed('/favorites');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }

  Widget _buildNavItem(IconData icon, int index, {bool isLarge = false}) {
    bool isSelected = selectedIndex == index;

    double iconSize = isLarge ? 29 : 28;
    double containerWidth = isLarge ? 31 : 30;
    double containerHeight = isLarge ? 35 : 34;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
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
              color:
                  isSelected ? Colors.blue.shade900 : const Color(0xFF988A44),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
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
