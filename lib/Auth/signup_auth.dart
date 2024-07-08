import 'dart:math';

import 'package:booking_cms/Auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPhoneNumber = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String generateRandomUsername() {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    return 'user_' +
        List.generate(8, (index) => letters[random.nextInt(letters.length)])
            .join();
  }

  void signUp(BuildContext context) async {
    if (txtPassword.text != txtConfirmPassword.text) {
      Get.snackbar('Error', 'Password tidak sesuai',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: txtEmail.text,
        password: txtPassword.text,
      );

      String userId = userCredential.user!.uid;
      String username = 'CMS_';
      if (username == 'CMS_') {
        username = generateRandomUsername();
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'user_id': userId,
        'username': username,
        'email': txtEmail.text,
        'nomorhp': txtPhoneNumber.text,
        'role': 'user',
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Pendaftaran berhasil. Silakan login.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.offAll(() => LoginPage());
                },
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Password yang Anda masukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Akun sudah ada untuk email tersebut.';
      } else {
        message = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      Get.snackbar('Error Daftar', message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF388E3C),
            Color(0xFF1B5E20),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Image.asset(
            "lib/assets/img/logo.png",
            width: 100,
            height: 100,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Center(
            child: Text(
              'Silahkan Daftar Terlebih Dahulu',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          _buildSignUpForm(context),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: txtEmail,
          decoration: _buildInputDecoration('Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        TextFormField(
          controller: txtPhoneNumber,
          decoration: _buildInputDecoration('Nomor HP'),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        TextFormField(
          controller: txtPassword,
          decoration:
              _buildPasswordInputDecoration('Kata Sandi', _obscurePassword, () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          }),
          obscureText: _obscurePassword,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        TextFormField(
          controller: txtConfirmPassword,
          decoration: _buildPasswordInputDecoration(
              'Konfirmasi Kata Sandi', _obscureConfirmPassword, () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          }),
          obscureText: _obscureConfirmPassword,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.04),
        ElevatedButton(
          onPressed: () => signUp(context),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5.0,
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'Signup',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        _buildLoginLink(),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.3),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  InputDecoration _buildPasswordInputDecoration(
      String labelText, bool obscureText, VoidCallback toggleObscureText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.3),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.white,
        ),
        onPressed: toggleObscureText,
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah Punya Akun?',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
