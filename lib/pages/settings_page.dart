import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/components/dialog_box.dart';
import 'package:habit_tracker/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final bool showThemes;
  const SettingsPage({super.key, this.showThemes = false});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();

    // Check if theme dialog should be shown 
    if (widget.showThemes) {
      // ensure the context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showThemeDialog();
      });
    }
  }

  void showThemeDialog() {  
    HapticFeedback.lightImpact();    
    showGeneralDialog(
      context: context, 
      barrierDismissible: true, 
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, x, y) => AlertDialog(
        title: Text("Select Color"),
        content: StatefulBuilder(
          builder: (context, StateSetter setState) =>
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              radioTile(value: 1, text: "Mint (default)"),
              Divider(color: Theme.of(context).colorScheme.primary), 
              radioTile(value: 2, text: "Azure blue"),
              radioTile(value: 3, text: "Vibrant red"),
              radioTile(value: 4, text: "Magenta pink"),
              Divider(color: Theme.of(context).colorScheme.primary), 
              radioTile(value: 5, text: "Monochrome 1"),
              radioTile(value: 6, text: "Monochrome 2"),
              radioTile(value: 7, text: "Experimental"),
            ],
          ),
        ),
      ),
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: moveUpTransition()
    );
  }

  Widget radioTile({required int value, required String text}) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return InkWell(
          onTap: () => themeProvider.setAccentColor(value),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Radio(
                value: value,
                groupValue: themeProvider.selectedColor,
                onChanged: (val) {
                  if (val != null)
                    themeProvider.setAccentColor(val);
                },
              ),
              Text(text),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Get current selected Color from Theme Provider
    int? selectedValue = Provider.of<ThemeProvider>(context).selectedColor;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("S E T T I N G S", style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 20
          )),
        ),
        leading: IconButton(
          onPressed: () async {
            await Future.delayed(Duration(milliseconds: 100));
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.inversePrimary)
        ),
        actions: [  // Placeholder Icon so that title centered
          IconButton(onPressed: null, icon: Icon(Icons.abc, color: Colors.transparent))
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 5),

          _settingsTile(
            onTap: () {
              HapticFeedback.lightImpact();

              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              bool currentValue = themeProvider.useSystemTheme;
              themeProvider.toggleUseSystemTheme(!currentValue);
            },
            onLongPress: () {},
            text: "Follow theme of system settings",
            trailing: CupertinoSwitch(          
              value: Provider.of<ThemeProvider>(context).useSystemTheme,
              onChanged: (value) async { 
                HapticFeedback.lightImpact();   

                Provider.of<ThemeProvider>(context, listen: false).toggleUseSystemTheme(value);
              }
            )
          ),

          Provider.of<ThemeProvider>(context).useSystemTheme ? SizedBox() : _settingsTile(
            onTap: Provider.of<ThemeProvider>(context, listen: false).toggleTheme,
            onLongPress: () {},
            text: "Dark Mode",
            trailing: CupertinoSwitch(          
              value: (Theme.of(context).brightness == Brightness.dark), //Provider.of<ThemeProvider>(context).isDarkMode, 
              onChanged: (value) { 
                HapticFeedback.lightImpact();   
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              }
            )
          ),
          
          _settingsTile(
            onTap: showThemeDialog, 
            onLongPress: () => showCustomDialog(
              context: context, title: "Accent color", 
              text: "The accent color is used throughout the app, including in the heatmap, analysis, and habit completion indicators.",
              labels: ("Dismiss", "Open"),
              actions: (() => Navigator.pop(context), () { Navigator.pop(context); showThemeDialog(); })
            ), 
            text: "Edit accent color", // app theme
            trailing: Padding(
              padding: const EdgeInsets.only(right: 7),
              child: IconButton(
                onPressed: showThemeDialog, 
                icon: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary)
              ),
            )
          ),

          _settingsTile(
            onTap: () {
              HapticFeedback.lightImpact();

              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              bool currentValue = themeProvider.crossCompletedHabits;
              // Toggle the value
              themeProvider.setCrossCompletedHabit = !currentValue;
            },
            onLongPress: () => showCustomDialog(
              context: context,
              title: "Do not highlight completed habits",
              text: "When enabled, completed habits are crossed out and shown with reduced visibility instead of being highlighted in the theme color, helping you to focus on habits you still need to complete.",
              actions: (null, () => Navigator.pop(context)), labels: ("", "Understood  ")
            ),
            text: "Do not highlight completed habits",
            trailing: CupertinoSwitch(          
              value: (Provider.of<ThemeProvider>(context, listen: false).crossCompletedHabits),
              onChanged: (value) { 
                HapticFeedback.lightImpact();   
                Provider.of<ThemeProvider>(context, listen: false).setCrossCompletedHabit = value;
              }
            )
          ),

          // Dark Mode Tile
          /* Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
            child: Material(
              child: InkWell(
                onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                onLongPress: () {},
                borderRadius: BorderRadius.circular(10),
                splashColor: Colors.grey.withAlpha(50),
                highlightColor:Colors.grey.withAlpha(100),
            
                child: Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 5),
                    child: ListTile(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary
                        ),
                      ),
                      trailing: CupertinoSwitch(
                        value: Provider.of<ThemeProvider>(context).isDarkMode, 
                        onChanged: (value) => 
                          Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme()
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),  */

          // Theme tile
          /* Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
            child: Material(
              child: InkWell(
                onTap: showThemeDialog,
                onLongPress: () => showCustomDialog(
                  context: context, title: "Accent color", 
                  text: "The accent color is used throughout the app, including in the heatmap, analysis, and habit completion indicators.",
                  labels: ("Dismiss", "Open"),
                  actions: (() => Navigator.pop(context), () { Navigator.pop(context); showThemeDialog(); })
                ),
                borderRadius: BorderRadius.circular(10),
                splashColor: Colors.grey.withAlpha(50),
                highlightColor:Colors.grey.withAlpha(100),
            
                child: Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 5),
                    child: ListTile(
                      title: Text(
                        "Edit accent color",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary
                        ),
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: IconButton(
                          onPressed: showThemeDialog, 
                          icon: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary)
                        ),
                      )
                    ),
                  ),
                ),
              ),
            ),
          ) */
        ]
      
      ),
    ); 
  }

  Widget _settingsTile({
      required void Function()? onTap, 
      required void Function()? onLongPress,
      required String text,
      Widget? trailing
    }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
      child: Material(
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.grey.withAlpha(20),
          highlightColor:Colors.grey.withAlpha(80),
      
          // Container
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 5),

              // List Tile
              child: ListTile(
                title: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary
                  ),
                ),
                trailing: trailing
              ),
            ),
          ),
        ),
      ),
    );
  }
}