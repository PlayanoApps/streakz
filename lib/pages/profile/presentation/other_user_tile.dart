import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String email = user["email"];
    String name = user["username"];

    if (email == FirebaseAuth.instance.currentUser!.email) return Container();

    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 5, top: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 20),
              Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 30),
            ],
          ),
        ),
      ),
    );
  }
}
