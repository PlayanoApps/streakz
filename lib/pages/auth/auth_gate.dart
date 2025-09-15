// If user logged in, show Home, else login or register page 

/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/_home_page.dart';
import 'package:habit_tracker/pages/auth/login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          // User logged in
          if (snapshot.hasData) {
            return HomePage();
          }
          else 
            return LoginOrRegister();
        }
      ),
    );
  }
}  */
 
/* Download habits from firestore into isar before switching to home page */

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/custom_dialog.dart';
import 'package:habit_tracker/firestore_database.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/_home_page.dart';
import 'package:habit_tracker/pages/auth/login_or_register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Future<void>? _loadingFuture;
  User? _currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          // User logged in
          if (snapshot.hasData) {
            final user = snapshot.data!;
            
            // Only create new loading future if user changed or no future exists
            if (_currentUser?.uid != user.uid || _loadingFuture == null) {
              _currentUser = user;
              _loadingFuture = _loadFromFirestore(user);
            }
            
            return FutureBuilder(
              future: _loadingFuture,
              builder: (context, loadingSnapshot) {

                // Loading
                if (loadingSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    body: Center(
                      child: CupertinoActivityIndicator(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  );
                }
                
                // Error
                if (loadingSnapshot.hasError) {
                  return Scaffold(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    body: Center(
                      child: Text(
                        'Error: ${loadingSnapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                }
                
                return HomePage();
              },
            );
          }
          // User logged out - reset everything
          else {
            _loadingFuture = null;
            _currentUser = null;
            return LoginOrRegister();
          }
        }
      ),
    );
  }
  
  Future<void> _loadFromFirestore(User user) async {
    bool debug = false;

    try {
      final localCount = await HabitDatabase.isar.habits.count();
      
      // Isar habits empty --> Download from firestore
      if (localCount == 0) {
        if(debug) showCustomDialog(context, title: "No habits in isar --> Load from firestore");

        await FirestoreDatabase(HabitDatabase.isar).loadFromFirestore(user, context);
        
        // No habits in Firestore either --> new user
        final countAfterDownload = await HabitDatabase.isar.habits.count();

        if (countAfterDownload == 0) {
          final prefs = await SharedPreferences.getInstance();
          final showOnboarding = prefs.getBool("showOnboarding");
          
          if(showOnboarding == null || showOnboarding == true) {
            await HabitDatabase.loadDefaultHabits();

            try {
              await FirestoreDatabase(HabitDatabase.isar).syncToFirestore(user, context: context);
            } catch(e) {
              if (debug) showCustomDialog(context, title: "Error during sync");
            }
          }
        }
      } 
      else {
        // Isar not empty --> logged in
        //await FirestoreDatabase(HabitDatabase.isar).downloadHabitsToIsar(user);

        // Prioitize local habits
        if (debug) 
          showCustomDialog(context, title: "Isar not empty --> Prioritize local habits");

        // If user has internet, sync with firestore
        try {
          final result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 3));
    
          if (result.isNotEmpty) {
            await FirestoreDatabase(HabitDatabase.isar).syncToFirestore(user, context: context)
                .timeout(Duration(seconds: 5));
            if (debug) showCustomDialog(context, title: "Sync successful");
          } 
          else if (debug) 
              showCustomDialog(context, title: "No internet - skipping sync");
        } catch(e) {
          if (debug)
            showCustomDialog(context, title: "Error syncing to cloud");
        }
      }
    } catch (e) {
      rethrow;
    }
  }


}