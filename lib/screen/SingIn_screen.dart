import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/snackbar.dart';
import 'Singup_screen.dart'; // Ensure this exists

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> onSignIn() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      showCustomSnackBar(message: "Sign-in successful", success: true,context: context,);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      showCustomSnackBar(message: "Sign-in failed: ${e.toString()}", success: false,context: context,);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0B1B3B), const Color(0xFF1B2B4B)]
                : [const Color(0xFFB2D8FF), const Color(0xFFE6F3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: isDark ? Colors.white54 : Colors.grey),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: isDark ? Colors.white54 : Colors.grey),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4589F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
