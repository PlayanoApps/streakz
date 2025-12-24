import 'package:flutter/material.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 50, color: Colors.grey),
        Container(height: 50, color: Colors.grey.shade200),
        Container(height: 50, color: Colors.grey),
        Container(height: 50, color: Colors.grey.shade200),
      ],
    );
  }
}
