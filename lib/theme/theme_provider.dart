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
import 'package:habit_tracker/theme/themes.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider extends ChangeNotifier 
{
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs);   // pass as argument in main

  ThemeData themeData = lightMode;
  
  void toggleTheme() {
    themeData = (themeData == lightMode) ? darkMode : lightMode;

    updateThemeInDatabase();
    notifyListeners();
  }

  /* Called in home init */
  Future<void> loadTheme() async {
    final appSettings = await HabitDatabase.isar.appSettings.where().findFirst();

    if (appSettings != null) {
      bool useDarkMode = appSettings.darkModeEnabled;
      themeData = useDarkMode ? darkMode : lightMode;
    }
    notifyListeners();
  }

  Future<void> updateThemeInDatabase() async {
    Isar isar = HabitDatabase.isar;
    final appSettings = await isar.appSettings.where().findFirst();

    if (appSettings != null) {
      appSettings.darkModeEnabled = (themeData == darkMode);
      await isar.writeTxn(() => isar.appSettings.put(appSettings));
    }
  }

  /* S E T T I N G S */

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
  
  MaterialColor getAccentColor() => themeColors[selectedColor] ?? Colors.green;

  Future<void> setAccentColor(int? settingsRadioValue) async {
    selectedColor = settingsRadioValue ?? 1; // Default: 1
    await _setInt("selectedColor", selectedColor);
  }

  void loadAccentColor() {
    selectedColor = _getInt('selectedColor', 1);

    // Ensure the value exists in themeColors
    if (!themeColors.containsKey(selectedColor)) 
      selectedColor = 1;

    notifyListeners();
  }

  /* void setAccentColor(int? settingsRadioValue) {
    selectedColor = settingsRadioValue ?? 1;  // Default: 1 
    updateSelectedColorInDatabase();
    notifyListeners();
  }

  Future<void> updateSelectedColorInDatabase() async {
    Isar isar = HabitDatabase.isar;
    final appSettings = await isar.appSettings.where().findFirst();

    if (appSettings != null) {
      appSettings.selectedColor = selectedColor;
      await isar.writeTxn(() => isar.appSettings.put(appSettings));
    }
  }

  Future<void> loadAccentColor() async {
    final appSettings = await HabitDatabase.isar.appSettings.where().findFirst();

    if (appSettings != null) {
      if (themeColors.containsKey(appSettings.selectedColor))
        selectedColor = appSettings.selectedColor;
      else
        selectedColor = 1;
    }
    notifyListeners();
  } */

  /* USE SYSTEM THEME */
  bool _followSystemTheme = true;

  bool get useSystemTheme => _followSystemTheme;

  void loadfollowSystemTheme() {
    _followSystemTheme = _getBool("useSystemTheme", true);
    notifyListeners();
  }

  Future<void> togglefollowSystemTheme(bool value) async {
    _followSystemTheme = value;
    await _setBool('useSystemTheme', value); 
  }

  /* HIGHLIGHT COMPLETED HABITS OR CROSS THEM */
  bool crossCompletedHabits = true;

  Future<void> toggleCrossCompletedHabits(bool val) async {
    crossCompletedHabits = val;
    await _setBool('crossCompletedHabits', val); // uses generic setter
  }

  void loadHabitCompletedPref() {
    crossCompletedHabits = _getBool('crossCompletedHabits', true); // uses generic getter
    notifyListeners();
  }

  /* P R E F S */
  bool _getBool(String key, bool defaultValue) => _prefs.getBool(key) ?? defaultValue;
  Future<void> _setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    notifyListeners();
  }

  int _getInt(String key, int defaultValue) => _prefs.getInt(key) ?? defaultValue;
  Future<void> _setInt(String key, int value) async {
    await _prefs.setInt(key, value);
    notifyListeners();
  }

  /* Future<void> updateHabitCompletedPref() async {
    Isar isar = HabitDatabase.isar;
    final appSettings = await isar.appSettings.where().findFirst();

    if (appSettings != null) {
      appSettings.crossCompletedHabits = _crossCompletedHabits;
      await isar.writeTxn(() => isar.appSettings.put(appSettings));
    }
  }

  Future<void> loadHabitCompletedPref() async {
    final appSettings = await HabitDatabase.isar.appSettings.where().findFirst();

    if (appSettings != null) {
      _crossCompletedHabits = appSettings.crossCompletedHabits;
    }
    notifyListeners();
  } */
}