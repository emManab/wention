import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wention/screen/SingIn_screen.dart';
import 'package:wention/screen/verification.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isPasswordVisible = false;
  bool nameError = false;
  bool emailError = false;
  bool passwordError = false;
  bool isLoading = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void showCustomSnackBar({required String message, required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: success ? Colors.green.shade100 : Colors.red.shade100,
            border: Border.all(
              color: success ? Colors.green : Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.cancel,
                color: success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      success ? "SUCCESS!" : "ERROR!",
                      style: TextStyle(
                        color: success ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          message: "Please correct the highlighted fields", success: false);
      return;
    }

    try {
      setState(() => isLoading = true);

      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCred.user!.updateDisplayName(name);

      if (!userCred.user!.emailVerified) {
        await userCred.user!.sendEmailVerification();
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );

      showCustomSnackBar(
        message: "Sign-up successful! Please verify your email.",
        success: true,
      );
    } catch (e) {
      showCustomSnackBar(
        message: "Sign-up failed: ${e.toString()}",
        success: false,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> onGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      showCustomSnackBar(
        message: "Google Sign-In successful",
        success: true,
      );
    } catch (e) {
      showCustomSnackBar(
        message: "Google Sign-in failed: ${e.toString()}",
        success: false,
      );
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
            Text("Or",
                style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onGoogleSignIn,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/google.png', height: 24, width: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
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
