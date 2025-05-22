import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart'; // make sure this path is correct for your project

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String? name;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    this.name,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  late final EmailOTP myOtp;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    myOtp = EmailOTP();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    myOtp.setConfig(
      appEmail: 'wention@official.com', // must be verified in EmailOTP
      appName: 'Wention',
      userEmail: widget.email,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );

    final sent = await myOtp.sendOTP();
    _showSnackBar(
      sent ? 'OTP has been sent to ${widget.email}' : 'Failed to send OTP',
      isError: !sent,
    );
  }

  Future<void> _verifyOtp() async {
    // show loader immediately
    setState(() => isLoading = true);

    final isVerified = await myOtp.verifyOTP(
      otp: otpController.text.trim(),
    );

    if (!isVerified) {
      _showSnackBar('Invalid OTP', isError: true);
      setState(() => isLoading = false);
      return;
    }

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      // 1️⃣ Create the user in Firebase Auth
      final UserCredential cred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // 2️⃣ Save additional details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'email': widget.email,
        'name': widget.name ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3️⃣ Navigate to HomeScreen

    } on FirebaseAuthException catch (e) {
      _showSnackBar('Signup failed: ${e.message}', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              const Icon(Icons.sms_outlined, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Enter the OTP',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'An OTP has been sent to:\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit OTP',
                  counterText: '',
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading ? null : _sendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pushReplacementNamed(context, '/signup'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back, size: 16, color: Colors.blueAccent),
                    SizedBox(width: 6),
                    Text(
                      'Back to Signup',
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
