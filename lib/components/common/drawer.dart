import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:habit_tracker/components/common/custom_dialog.dart";
import "package:habit_tracker/database/habit_database.dart";
import "package:habit_tracker/features/profile/profile_page.dart";
import "package:habit_tracker/features/settings/settings_page.dart";
import "package:lottie/lottie.dart";
import "package:shared_preferences/shared_preferences.dart";

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      HapticFeedback.mediumImpact();
      await Future.delayed(Duration(milliseconds: 200));

      /* final prefs = await SharedPreferences.getInstance();
      prefs.setBool('showOnboarding', true); */

      Future<void> signOut() async {
        Navigator.pop(context);

        try {
          // Clear Isar
          await HabitDatabase().deleteHabits();

          // Sign out
          await FirebaseAuth.instance.signOut();

          final prefs = await SharedPreferences.getInstance();
          await prefs.remove("profile_image");
        } catch (e) {
          showCustomDialog(context, title: "Failed to sign out");
          await FirebaseAuth.instance.signOut();
        }
      }

      showCustomDialog(
        context,
        title: "Log out?",
        labels: ("Yes", "Cancel"),
        actions: (() => signOut(), () => Navigator.pop(context)),
      );

      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnboardingPage()));
    }

    return Drawer(
      // Access background color from color schemes defined in my custom theme (assigned in main.dart)
      backgroundColor: Theme.of(context).colorScheme.surface,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: 90), // 100
              /* Icon(
                Icons.favorite, 
                size: 48,
                color: Theme.of(context).colorScheme.inversePrimary,
              ), */
              SizedBox(
                width: 60,
                child: LottieBuilder.asset("assets/streak4.json"),
              ),

              SizedBox(height: 50), // 60
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
                    leading: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text("H O M E"),
                    horizontalTitleGap: 20,
                  ),
                ),
              ),
              // Settings
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await Future.delayed(Duration(milliseconds: 155));
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text("S E T T I N G S"),
                    horizontalTitleGap: 20,
                  ),
                ),
              ),
              // Profile
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await Future.delayed(Duration(milliseconds: 155));

                    Navigator.pop(context);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(showThemes: true)));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text("P R O F I L E"),
                    horizontalTitleGap: 20,
                  ),
                ),
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
            ],
          ),
          // Bottom Items
          Column(
            children: [
              // Logout
              Padding(
                padding: EdgeInsets.only(left: 25, right: 25, bottom: 40),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: logout,
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text("L O G O U T"),
                    horizontalTitleGap: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
