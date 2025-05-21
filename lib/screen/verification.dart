import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();

    // Auto-check email verification every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await auth.currentUser?.reload();
      if (auth.currentUser?.emailVerified == true) {
        timer.cancel();
        if (mounted) {
          _showSnackBar("Email verified successfully!");
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    final user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        _showSnackBar("Verification email sent!");
      } catch (e) {
        _showSnackBar("Failed to send verification email.", isError: true);
      }
    }
  }

  Future<void> _checkVerification() async {
    setState(() => isLoading = true);
    await auth.currentUser?.reload();
    final user = auth.currentUser;

    if (user != null && user.emailVerified) {
      _showSnackBar("Email verified!");
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar(
        "Email not verified yet or link expired. Please check your inbox or resend.",
        isError: true,
      );
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = auth.currentUser?.email ?? "";

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFB2D8FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mail_outline, size: 80),
              const SizedBox(height: 24),
              const Text(
                "Verify your email address",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "We sent a verification link to:\n$email\n\nPlease check your inbox and click the link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "If the link expired or was used, tap the button below.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Continue"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _sendVerificationEmail,
                child: const Text(
                  "Resend Email Link",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back, size: 16, color: Colors.blueAccent),
                    SizedBox(width: 6),
                    Text(
                      "Back to Login",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
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
}
