/* /* If user logged in, show Home, else login or register page */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/firestore_database.dart';
import 'package:habit_tracker/isar_database.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:habit_tracker/services/auth/login_or_register.dart';

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
} */

/* Download habits from firestore into isar before switching to home page */

/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/firestore_database.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:habit_tracker/services/auth/login_or_register.dart';

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
                
                if (loadingSnapshot.hasError) {
                  return Scaffold(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading data',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${loadingSnapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return HomePage();
              },
            );
          }
          // User not logged in
          else {
            // Reset the loading future when user logs out
            _loadingFuture = null;
            _currentUser = null;
            return LoginOrRegister();
          }
        }
      ),
    );
  }
  
  Future<void> _loadFromFirestore(User user) async {
    try {
      // Check if local database is empty (new user scenario)
      final count = await HabitDatabase.isar.habits.count();
      
      if (count == 0) {
        await FirestoreDatabase(HabitDatabase.isar).downloadHabitsToIsar(user);
        
        // Check if we got any habits from Firestore
        final countAfterDownload = await HabitDatabase.isar.habits.count();
        
        // If not, create default habits
        if (countAfterDownload == 0) {
          await HabitDatabase.loadDefaultHabits();
          await FirestoreDatabase(HabitDatabase.isar).syncToFirestore(user);
        }
      } else 
        await FirestoreDatabase(HabitDatabase.isar).downloadHabitsToIsar(user);
    } catch (e) {
      rethrow;
    }
  }
} */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/firestore_database.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:habit_tracker/auth/login_or_register.dart';

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
                
                if (loadingSnapshot.hasError) {
                  return Scaffold(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading data',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${loadingSnapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return HomePage();
              },
            );
          }
          // User not logged in
          else {
            // Reset the loading future when user logs out
            _loadingFuture = null;
            _currentUser = null;
            return LoginOrRegister();
          }
        }
      ),
    );
  }
  
  Future<void> _loadFromFirestore(User user) async {
    try {
      // Check if local database is empty (new user scenario)
      final localCount = await HabitDatabase.isar.habits.count();
      
      if (localCount == 0) {
        // Try to download from Firestore first
        await FirestoreDatabase(HabitDatabase.isar).downloadHabitsToIsar(user);
        
        // Check if we got any habits from Firestore
        final countAfterDownload = await HabitDatabase.isar.habits.count();
        
        if (countAfterDownload == 0) {
          // No habits in Firestore either - create default habits
          await HabitDatabase.loadDefaultHabits();
          // Upload them to Firestore immediately
          await FirestoreDatabase(HabitDatabase.isar).syncToFirestore(user);
        }
      } else {
        // Local database has habits - just download from Firestore to sync
        await FirestoreDatabase(HabitDatabase.isar).downloadHabitsToIsar(user);
      }
    } catch (e) {
      // Re-throw the error so FutureBuilder can handle it
      rethrow;
    }
  }
}