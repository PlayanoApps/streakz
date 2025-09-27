import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUserTile extends StatefulWidget {
  final void Function()? updateProfile;

  const CurrentUserTile({super.key, required this.updateProfile});

  @override
  State<CurrentUserTile> createState() => _CurrentUserTileState();
}

class _CurrentUserTileState extends State<CurrentUserTile> {
  File? image;
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage(); // load saved image when app starts
  }

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

  Future<void> pickImage(ImageSource source) async {
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
  }

  @override
  Widget build(BuildContext context) {
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
                            ? Icon(
                              Icons.person,
                              size: 55,
                              color: Theme.of(context).colorScheme.primary,
                            )
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
                    /* SizedBox(width: 1),
                    InkWell(
                      onTap: widget.updateProfile,
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
                    ), */
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
  }
}
