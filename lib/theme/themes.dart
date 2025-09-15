import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300, // background color
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    secondaryFixed: Color.fromARGB(250, 225, 225, 225), // Secondary but lighter (for heatmap background in analysis)
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade600,
    onPrimary: Colors.grey.shade900         
  ),
  textTheme: GoogleFonts.latoTextTheme(), // Roboto, inter, lato, poppings
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade600,
    secondary: Color.fromARGB(255, 47, 47, 47),
    secondaryFixed:  Color.fromARGB(255, 40, 40, 40),   // 75
    tertiary: Colors.grey.shade200,
    inversePrimary: Colors.grey.shade300,
    onPrimary: Colors.grey.shade300
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);