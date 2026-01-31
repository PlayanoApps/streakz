import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/components/general/app_bar.dart';
import 'package:habit_tracker/components/general/auth_button.dart';
import 'package:habit_tracker/components/general/custom_dialog.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/pages/profile/presentation/current_user.dart';
import 'package:habit_tracker/pages/profile/presentation/other_user_tile.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:habit_tracker/util/profile_helpers.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController pwController = TextEditingController();

  /* File? image;
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage(); // load saved image when app starts
  } */

  /* Future<void> pickImage(ImageSource source) async {
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("profile_image", pickedFile.path);
    }
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString("profile_image");

    if (imagePath != null) {
      setState(() {
        image = File(imagePath);
      });
    }
  } */

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user logged in");
    }

    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .get();
  }

  Future<void> deleteProfile(context) async {
    HapticFeedback.lightImpact();
    await Future.delayed(Duration(milliseconds: 100));

    showCustomDialog(
      context,
      title: "Delete Account",
      text: "This action cannot be undone.",
      labels: ("Delete", "Cancel"),
      zoomTransition: true,
      actions: (
        () {
          Navigator.pop(context);
          showCustomDialog(
            context,
            title: "Are you sure?",
            labels: ("No", "Yes"),
            actions: (
              () => Navigator.pop(context),
              () => deleteAccount(context),
            ),
          );
        },
        () => Navigator.pop(context),
      ),
    );
  }

  void updateProfile(context) async {
    usernameController.text = await getUsername();
    pwController.text = await getPassword();

    showCustomDialog(
      context,
      title: "Your Profile",
      text: "You can edit your username and password below.",
      hintText: "New username",
      secondHintText: "New password",
      controller: usernameController,
      secondController: pwController,
      labels: ("Cancel", "Confirm"),
      actions: (
        () => Navigator.pop(context),
        () async {
          updateUsername(usernameController.text);

          // Update password if it changed
          if (pwController.text != await getPassword())
            updatePassword(context, pwController.text);

          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Column(
        children: [
          MyAppBar(
            title: "My Profile",
            bottomPadding: 70,
            endIcon: Icons.edit,
            endAction: () => updateProfile(context),
          ),

          //displayCurrentUser(),
          CurrentUserTile(updateProfile: () => updateProfile(context)),

          displayFirstLaunchDate(context),

          MyButton(
            text: "Delete Account",
            onTap: () => deleteProfile(context),
            margin: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            padding: EdgeInsets.all(10),
          ),

          SizedBox(height: 40),

          /* Text(
            "Other users",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 20,
            ),
          ),

          SizedBox(height: 10),

          Expanded(child: displayAllUsers()), */
        ],
      ),
    );
  }

  /* Widget displayCurrentUser() {
    return FutureBuilder(
      future: getUserDetails(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CupertinoActivityIndicator());
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");

        // User data received
        if (snapshot.hasData) {
          Map<String, dynamic>? user = snapshot.data!.data();
          String username, email;

          if (user == null) {
            username = "No username";
            email = "No email";
          } else {
            username = user["username"];
            email = user["email"];
          }

          return Center(
            child: Column(
              children: [
                // Icon
                GestureDetector(
                  onTap: () => pickImage(ImageSource.gallery),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all((image == null) ? 20 : 5),
                    child:
                        (image == null)
                            ? Icon(Icons.person, size: 64)
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(image!, fit: BoxFit.cover),
                            ),
                  ),
                ),

                SizedBox(height: 20),

                // Username
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 1),
                    InkWell(
                      onTap: () => updateProfile(context),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      highlightColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          size: 21,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5),

                // Email
                Text(
                  email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          );
        } else
          return Text(
            "No data found",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          );
      },
    );
  } */

  Widget displayFirstLaunchDate(context) {
    return FutureBuilder(
      future: Provider.of<HabitDatabase>(context).getFirstLaunchDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData)
          return SizedBox.shrink();

        final date = snapshot.data!; // First launch date

        return Text(
          "Member since ${numberToMonth(date.month)} ${date.day}th",
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        );
      },
    );
  }

  Widget displayAllUsers() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CupertinoActivityIndicator());
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");
        if (snapshot.data == null) return Text("No data");

        // Get all users
        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return UserTile(user: user);
          },
        );
      },
    );
  }
}
