import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController txtEmail = TextEditingController();

  // Function to reset password
  void resetPassword() async {
    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: txtEmail.text);
      // Show success snackbar
      Get.snackbar('Success', 'Password reset email has been sent',
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      if (e.code == 'user-not-found') {
        // If user email not found
        Get.snackbar('Error', 'No user found with this email',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // For other errors
        String message = 'Error occurred: ${e.message}';
        Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      // Handle other errors
      String message = 'Error occurred: $e';
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 4.0, // Add elevation to AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Green shade for soccer field
              Color(0xFF388E3C), // Darker green shade for contrast
              Color(0xFF1B5E20), // Even darker green shade for depth
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title "Forgot Password?"
            const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Email input field
            TextFormField(
              controller: txtEmail,
              decoration: InputDecoration(
                      labelText: 'Masukan Email Terdaftar',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                    ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // "Send Reset Email" button
            ElevatedButton(
              onPressed: resetPassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Send Reset Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Button text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
