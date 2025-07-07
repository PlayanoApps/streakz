import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:habit_tracker/pages/onboarding.dart";
import "package:habit_tracker/pages/settings_page.dart";
import "package:habit_tracker/pages/statistics_page.dart";
import "package:shared_preferences/shared_preferences.dart";

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Access background color from color schemes defined in my custom theme (assigned in main.dart)
      backgroundColor: Theme.of(context).colorScheme.surface,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: 100),
              Icon(
                Icons.favorite, 
                size: 48,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              SizedBox(height: 60),
              // Divider
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
                child: Divider(color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.home, color: Theme.of(context).colorScheme.inversePrimary),
                    title: Text("H O M E"),
                    horizontalTitleGap: 20,
                  ),
                )         
              ),
              // Settings
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    HapticFeedback.mediumImpact(); 
                    await Future.delayed(Duration(milliseconds: 120));
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.inversePrimary), 
                    title: Text("S E T T I N G S"), 
                    horizontalTitleGap: 20,
                  )
                )
              ),
              // Theme
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    HapticFeedback.mediumImpact(); 
                    await Future.delayed(Duration(milliseconds: 120));
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(showThemes: true)));
                  },
                  child: ListTile(
                    leading: Icon(Icons.palette, color: Theme.of(context).colorScheme.inversePrimary), 
                    title: Text("T H E M E"), 
                    horizontalTitleGap: 20   
                  )
                )               
              ),
              /* Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ListTile(
                  leading: Icon(Icons.analytics, color: Theme.of(context).colorScheme.inversePrimary), 
                  title: Text("A N A L Y T I C S"), 
                  horizontalTitleGap: 20,
                  onTap: () async {
                    HapticFeedback.mediumImpact(); 
                    await Future.delayed(Duration(milliseconds: 120));
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsPage()));
                  }
                )
              ), */
              
            ]
          ),
          // Bottom Items
          Column(
            children: [
              // Logout
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
                child: ListTile(
                  leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.inversePrimary), 
                  title: Text("L O G O U T"), 
                  horizontalTitleGap: 20,
                  onTap: () async {
                    HapticFeedback.mediumImpact(); 
                    await Future.delayed(Duration(milliseconds: 70));
                    final prefs = await SharedPreferences.getInstance();
                    final showOnboarding = prefs.setBool('showOnboarding', true);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnboardingPage()));
                  }
                )
              )
            ]
          )
          
        ],
      ),
    );
  }
}