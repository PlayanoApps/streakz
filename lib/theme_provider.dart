/* 
  CREATE THEMES
  - add themes and provider class
  - make the class public in main() function with ChangeNotifierProvider
  - assign custom theme to 'theme' property in main.dart
   
  - to access theme data:
      backgroundColor: Theme.of(context).colorScheme.primary

  - to access functions below, use either consumer widget or:
      Provider.of<ThemeProvider>(context).isDarkMode, 
*/

import 'package:flutter/material.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:isar/isar.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300, // background color
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,  // 200
    secondaryFixed: const Color.fromARGB(250, 225, 225, 225), // Secondary but lighter (for heatmap background in analysis)
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade600,
    onPrimary: Colors.grey.shade900         // Text color for elements on primary color
  )
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade600,
    secondary: const Color.fromARGB(255, 47, 47, 47),
    secondaryFixed:  Color.fromARGB(255, 40, 40, 40),   // 75
    tertiary: Colors.grey.shade200,
    inversePrimary: Colors.grey.shade300,
    onPrimary: Colors.grey.shade300
  )
);

class ThemeProvider extends ChangeNotifier 
{
  static ThemeData _themeData = lightMode;

  /* Getter functions */
  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;

  /* Setter functions */
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    _themeData = (_themeData == lightMode) ? darkMode : lightMode;
    updateThemeInDatabase();
    notifyListeners();
  }

  /* This is called in home_page init method */
  Future<void> loadTheme() async {
    final appSettings = await HabitDatabase.isar.appSettings.where().findFirst();

    if (appSettings != null) {
      bool useDarkMode = appSettings.darkModeEnabled;
      _themeData = useDarkMode ? darkMode : lightMode;
    }
    notifyListeners();
  }

  Future<void> updateThemeInDatabase() async {
    Isar isar = HabitDatabase.isar;
    final appSettings = await isar.appSettings.where().findFirst();

    if (appSettings != null) {
      appSettings.darkModeEnabled = (_themeData == darkMode);
      await isar.writeTxn(() => isar.appSettings.put(appSettings));
    }
  }

  /* ACCENT COLOR */

  int selectedColor = 1;   // set from settings page

  final Map<int, MaterialColor> themeColors = {
    1: Colors.green,
    2: Colors.blue,
    3: Colors.red,
    4: Colors.pink, 
    5: Colors.blueGrey,
    6: Colors.brown,
    7: Colors.deepPurple
  };

  void setAccentColor(int? settingsRadioValue) {
    selectedColor = settingsRadioValue ?? 1;  // Default to 1 if null
    updateSelectedColorInDatabase();
    notifyListeners();
  }

  MaterialColor getAccentColor() {
    return themeColors[selectedColor] ?? Colors.green;
  }

  Future<void> updateSelectedColorInDatabase() async {
    Isar isar = HabitDatabase.isar;
    final appSettings = await isar.appSettings.where().findFirst();

    if (appSettings != null) {
      appSettings.selectedColor = selectedColor;
      await isar.writeTxn(() => isar.appSettings.put(appSettings));
    }
  }

  /* This is called in home_page init method */
  Future<void> loadAccentColor() async {
    final appSettings = await HabitDatabase.isar.appSettings.where().findFirst();

    if (appSettings != null) {
      if (themeColors.containsKey(appSettings.selectedColor))
        selectedColor = appSettings.selectedColor;
      else
        selectedColor = 1;
    }
    notifyListeners();
  }

  /* HIGHLIGHT COMPLETED HABITS OR CROSS THEM */

  bool _crossCompletedHabits = true;

  get crossCompletedHabits => _crossCompletedHabits;

  set setCrossCompletedHabit(bool val) {
    _crossCompletedHabits = val;
    updateHabitCompletedPref();
    notifyListeners();
  }

  Future<void> updateHabitCompletedPref() async {
    Isar isar = HabitDatabase.isar;
    final appSettings = await isar.appSettings.where().findFirst();

    if (appSettings != null) {
      appSettings.crossCompletedHabits = _crossCompletedHabits;
      await isar.writeTxn(() => isar.appSettings.put(appSettings));
    }
  }

  /* This is called in home_page init method */
  Future<void> loadHabitCompletedPref() async {
    final appSettings = await HabitDatabase.isar.appSettings.where().findFirst();

    if (appSettings != null) {
      _crossCompletedHabits = appSettings.crossCompletedHabits;
    }
    notifyListeners();
  }
}