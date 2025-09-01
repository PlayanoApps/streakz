import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/auth/auth_button.dart';
import 'package:habit_tracker/components/auth/auth_textfield.dart';
import 'package:habit_tracker/components/dialog_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // Login method
  void login() async {
    // Show loading circle
    BuildContext? loadingContext;
    showDialog(
      context: context, 
      builder: (context) { 
        loadingContext = context;
        return Center(child: CupertinoActivityIndicator(color: Theme.of(context).colorScheme.tertiary,));
      }
    );

    // Do not show Onboarding for existing account
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showOnboarding', false);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text
      );

      // Logged in --> Load habits from firestore NOW IN AUTH GATE
      /* final user = FirebaseAuth.instance.currentUser;
      if (user != null)
        await FirestoreDatabase(HabitDatabase.isar).downloadHabitsToIsar(user); */

      // Pop loading circle
      Navigator.pop(loadingContext!); 
    } 
    on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Pop loading circle
      showCustomDialog(context: context, title: e.code);
    }
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
              Text("S T R E A K Z", style: TextStyle(
                fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary)
              ),

              const SizedBox(height: 50),
          
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
          
              // Login button
              MyButton(
                text: "Login", 
                onTap: login
              ),

              SizedBox(height: 25),
          
              // Don't have an account? Register here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary
                  ),),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      " Register Here", 
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