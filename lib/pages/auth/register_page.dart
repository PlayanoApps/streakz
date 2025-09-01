import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/auth/auth_button.dart';
import 'package:habit_tracker/components/auth/auth_textfield.dart';
import 'package:habit_tracker/components/dialog_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/firestore_database.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPwController = TextEditingController();

  // Register method
  void register() async {
    // Show loading circle
    BuildContext? loadingContext;

    showDialog(
      context: context, 
      builder: (context) {
        loadingContext = context;
        return Center(
          child: CupertinoActivityIndicator(color: Theme.of(context).colorScheme.tertiary,)
        );
      }
    );

    // Make sure passwords match
    if (passwordController.text != confirmPwController.text) {
      if (mounted)
        Navigator.pop(context); // Pop loading circle
      showCustomDialog(context: context, title: "Passwords don't match");
      return;
    }

    // Show Onboarding for new account
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showOnboarding', true);

    // Try creating new user
    try {
      UserCredential? userCredential = 
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, 
          password: passwordController.text
      );

      await createUserDocument(userCredential);   // Save user

      // Show default habits for new account if isar is empty
      /* final count = await HabitDatabase.isar.habits.count();
      if (count == 0)
        HabitDatabase.loadDefaultHabits();  
      */

      Navigator.pop(loadingContext!);        // Pop loading circle
    } 
    on FirebaseAuthException catch(e) {
      Navigator.pop(context);   // Pop loading circle
      showCustomDialog(context: context, title: e.code);
    }
  }

  // Save user into firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null)
      await FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.email)
        .set({
          "email": userCredential.user!.email,
          "username": usernameController.text,
          "password": passwordController.text
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
          
              const SizedBox(height: 25),
          
              // App name 
              Text("S T R E A K Z", style: TextStyle(fontSize: 20)),

              const SizedBox(height: 50),

              // User textfield
              MyTextField(
                hintText: "Username",
                controller: usernameController
              ),

              SizedBox(height: 10),
          
              // Email textfield
              MyTextField(
                hintText: "Email",
                controller: emailController
              ),

              SizedBox(height: 10),
          
              // Password textfield
              MyTextField(
                hintText: "Password",
                controller: passwordController,
                obscureText: true,
              ),

              SizedBox(height: 10),

              // Confirm Password textfield
              MyTextField(
                hintText: "Confirm Password",
                controller: confirmPwController,
                obscureText: true,
              ),

              SizedBox(height: 10),
          
              // Forgot password 
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Forgot password?", style: TextStyle(
                    color: Theme.of(context).colorScheme.primary
                  ),),
                ],
              ),

              SizedBox(height: 10),
          
              // Register button
              MyButton(
                text: "Register", 
                onTap: register
              ),

              SizedBox(height: 25),
          
              // Don't have an account? Register here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary
                  ),),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      " Login Here", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary
                      ),
                    ),
                  )
                ],
              )
            ],
            
          ),
        ),
      ),
    );
  }
}