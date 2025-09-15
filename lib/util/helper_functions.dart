import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/custom_dialog.dart';

/* Given a completedDays list of a habit, check if this habit is completed today */
// For checking habit on and off (checkbox value)

bool habitCompleted(List<DateTime> completedDays, DateTime dateToCheck) {
  DateTime today = DateTime.now();

  bool habitCompletedToday = completedDays.any((date) => 
    date.year == dateToCheck.year &&
    date.month == dateToCheck.month &&
    date.day == dateToCheck.day
  );

  return habitCompletedToday;
}

/* For analysis: return the current streak of a habit */
int currentStreak(List<DateTime> completedDays) {
  DateTime today = DateTime.now();
  int streak = 0;

  for (int i = 0; true; i++) {
    DateTime dayToCheck = today.subtract(Duration(days: i));

    dayToCheck = normalize(dayToCheck);

    if (completedDays.contains(dayToCheck))
      streak++;
    else
      return streak;
  }
}

int highestStreak(List<DateTime> completedDays) {
  completedDays.sort((a, b) => a.compareTo(b));

  int maxStreak = 1; 
  int localStreak = 1;

  for (int i = 0; i < completedDays.length-1; i++) {
    DateTime currentDate = normalize(completedDays[i]);
    DateTime nextDate = normalize(completedDays[i+1]);

    if (currentDate.add(Duration(days: 1)) == nextDate)
      localStreak++;
    else if (currentDate != nextDate) {
      localStreak = 1;
    }
    maxStreak = max(maxStreak, localStreak);
  }
  return maxStreak;
}

DateTime normalize(DateTime date) => DateTime(date.year, date.month, date.day);

String numberToMonth(int month) {
  const months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  return months[month - 1]; // because list starts at 0
}

/* int amountOfHabitsCompleted(DateTime date, List<Habit> habits) {
  final normalizedDate = normalize(date);
  int count = 0;

  for (var habit in habits) {
    for (var completedDay in habit.completedDays) {
      final normalizedCompleted = normalize(completedDay);

      if (normalizedCompleted == normalizedDate) {
        count++;
        break; // only count habit once per day
      }
    }
  }
  return count;
} */

/* Profile page */

Future<String> getPassword() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  final doc = await FirebaseFirestore.instance.collection("Users")
      .doc(currentUser!.email).get();

  return doc.data()?["password"] as String;
}

Future<String> getUsername() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  
  final doc = await FirebaseFirestore.instance.collection("Users")
      .doc(currentUser!.email).get();

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
    password: password
  );
  await currentUser.reauthenticateWithCredential(cred);
}

void updatePassword(context, String newPw) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  try {
    await reauthenticateUser();
    
    await currentUser!.updatePassword(newPw.trim());

    // Update in Firestore
    await FirebaseFirestore.instance.collection("Users")
    .doc(currentUser.email).update({
      "password": newPw.trim()
    });

    showCustomDialog(
      context, 
      title: "Success",
      text: "Password updated successfully.",
      zoomTransition: true
    );
  } on FirebaseAuthException catch (e) {
    showCustomDialog(
      context,
      title: "Error",
      text: e.code,
      zoomTransition: true
    );
  } 
}

void updateUsername(String newUsername) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  
  await FirebaseFirestore.instance.collection("Users")
  .doc(currentUser!.email).update({
    "username": newUsername.trim()
  });
}

void deleteAccount(context) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  Navigator.pop(context); // Close dialog
  try {
    await reauthenticateUser();

    await FirebaseAuth.instance.currentUser!.delete();
    FirebaseFirestore.instance.collection("Users").doc(currentUser!.email).delete();

    Navigator.pop(context); // Close profile page
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      showCustomDialog(
        context, title: e.code
      );
    }
  }
}
