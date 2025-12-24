import 'dart:ui';
import 'package:flutter/material.dart';

class MyBlur extends StatelessWidget {
  final Widget child;

  const MyBlur({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // translucent overlay
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
