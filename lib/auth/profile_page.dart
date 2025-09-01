import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/auth/back_button.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user logged in");
    }

    return await FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser!.email)
      .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 45, left: 20),
            child: Row(
              children: [
                MyBackButton(),
                SizedBox(width: 15),
                Text("Profile", style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ))
              ],
            ),
          ),

          SizedBox(height: 50),

          displayCurrentUser(),

          SizedBox(height: 50),

          Expanded(child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            //child: displayAllUsers(),
          ))
        ],
      ),
    );
  }

  Widget displayCurrentUser() {


    return FutureBuilder(
      future: getUserDetails(), 
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CupertinoActivityIndicator());
    
        // Error
        if (snapshot.hasError)
          return Text("Error: ${snapshot.error}");
    
        // Data received
        if (snapshot.hasData) {
          // Get user data
          Map<String, dynamic>? user = snapshot.data!.data();

          String username, email;

          if (user == null) {
            username = "No username";
            email = "No email";
          } else {
            username = user["username"] ?? "No username";
            email = user["email"] ?? "No email";
          }

    
          return Center(
            child: Column(
              children: [
                // Icon
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(24)
                  ),
                  padding: EdgeInsets.all(20),
                  child: Icon(Icons.person, size: 64),
                ),

                SizedBox(height: 20),

                // Username
                Text(username, style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                )),

                SizedBox(height: 5),

                // Email
                Text(email, style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  // fontSize: 20,
                ))
              ],
            ),
          );
        } else
          return Text("No data");
      }
    );
  }

  Widget displayAllUsers() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(), 
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CupertinoActivityIndicator());

        // Error
        if (snapshot.hasError)
          return Text("Error: ${snapshot.error}");

        if (snapshot.data == null)
          return Text("No data");

        // Get all users
        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            // Get individuall user from users
            final user = users[index];

            String username = user["username"];
            String email = user["email"];

            if (email == FirebaseAuth.instance.currentUser!.email)
              return Container();

            return ListTile(
              title: Center(child: Text(username)),
              subtitle: Center(child: Text(email)),
            );
          }
        );
      }
    );
  }
}