import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return TextField(
      obscureText: obscureText,
      controller: controller,

      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),

      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 0.7,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                darkMode
                    ? Colors.grey.shade800
                    : Theme.of(context).colorScheme.tertiary,
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16.3,
        ),
      ),
    );
  }
}
