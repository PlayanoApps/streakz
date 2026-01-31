/* Profile page */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/general/custom_dialog.dart';

Future<String> getPassword() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  final doc =
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .get();

  return doc.data()?["password"] as String;
}

Future<String> getUsername() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  final doc =
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .get();

  return doc.data()?["username"] as String;
}

Future<void> reauthenticateUser() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  /* final doc = await FirebaseFirestore.instance.collection("Users")
      .doc(currentUser!.email).get();
  String password = doc.data()?["password"] as String; */

  String password = await getPassword();

  final cred = EmailAuthProvider.credential(
    email: currentUser!.email!,
    password: password,
  );
  await currentUser.reauthenticateWithCredential(cred);
}

void updatePassword(context, String newPw) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  try {
    await reauthenticateUser();

    await currentUser!.updatePassword(newPw.trim());

    // Update in Firestore
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .update({"password": newPw.trim()});

    showCustomDialog(
      context,
      title: "Success",
      text: "Password updated successfully.",
      zoomTransition: true,
    );
  } on FirebaseAuthException catch (e) {
    showCustomDialog(
      context,
      title: "Error",
      text: e.code,
      zoomTransition: true,
    );
  }
}

void updateUsername(String newUsername) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  await FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser!.email)
      .update({"username": newUsername.trim()});
}

void deleteAccount(context) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  Navigator.pop(context); // Close dialog
  try {
    await reauthenticateUser();

    await FirebaseAuth.instance.currentUser!.delete();
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .delete();

    Navigator.pop(context); // Close profile page
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      showCustomDialog(context, title: e.code);
    }
  }
}
