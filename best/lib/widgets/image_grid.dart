import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          buildImage('assets/Rectangle8.png'),
          buildImage('assets/Rectangle 9.png'),
          buildImage('assets/Rectangle 10.png'),
          buildImage('assets/Rectangle 11.png'),
        ],
      ),
    );
  }

  Widget buildImage(String asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
      ),
    );
  }
}
