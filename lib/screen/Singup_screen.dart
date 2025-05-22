import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wention/screen/SingIn_screen.dart';
import 'package:wention/screen/verification.dart';

import '../widgets/snackbar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool nameError = false;
  bool emailError = false;
  bool passwordError = false;
  bool isLoading = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> onLogin() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      nameError = name.isEmpty;
      emailError = !isValidEmail(email);
      passwordError = password.length < 7;
    });

    if (nameError || emailError || passwordError) {
      showCustomSnackBar(
          context: context,message: "Please correct the highlighted fields", success: false);
      return;
    }

    setState(() => isLoading = true);

    try {
      // Skip Firebase signup here
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: email,
            password: password,
          ),
        ),
      );

      showCustomSnackBar(
        message: "OTP sent successfully. Please verify.",
        success: true,
        context: context,
      );
    } catch (e) {
      showCustomSnackBar(
        message: "Something went wrong: ${e.toString()}",
        success: false,
        context: context,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0B1B3B), const Color(0xFF1B2B4B)]
                      : [const Color(0xFFB2D8FF), const Color(0xFFE6F3FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: buildLoginUI(isDark),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget buildLoginUI(bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Join for better \nWeather insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            buildTextField(
              controller: nameController,
              hint: 'Enter your Name',
              icon: Icons.person,
              isDark: isDark,
              error: nameError,
            ),
            const SizedBox(height: 20),
            buildTextField(
              controller: emailController,
              hint: 'Enter your email',
              icon: Icons.email,
              isDark: isDark,
              error: emailError,
            ),
            const SizedBox(height: 20),
            buildTextField(
              controller: passwordController,
              hint: 'Set Password',
              icon: Icons.lock,
              isDark: isDark,
              obscure: !isPasswordVisible,
              error: passwordError,
              suffix: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                onPressed: () {
                  setState(() => isPasswordVisible = !isPasswordVisible);
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4589F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Sign up",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "Sign-In",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInScreen()),
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
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffix,
    required bool error,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.grey),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
          BorderSide(color: error ? Colors.red : Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
          BorderSide(color: error ? Colors.red : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: error ? Colors.red : Colors.blue),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}