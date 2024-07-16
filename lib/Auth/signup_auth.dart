import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtUsername = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPhoneNumber = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      _showDialog(context, 'Error', 'Password tidak sesuai');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: txtEmail.text,
        password: txtPassword.text,
      );

      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'user_id': userId,
        'nama': txtName.text,
        'username': txtUsername.text,
        'email': txtEmail.text,
        'nomorhp': txtPhoneNumber.text,
        'role': 'user',
      });

      _showDialog(context, 'Berhasil', 'Pendaftaran berhasil. Silakan login.',
          onOkPressed: () {
        Navigator.of(context).pop();
        Get.offAllNamed('/login');
      });
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Password yang Anda masukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        message =
            'Email sudah terdaftar. Silakan gunakan email lain atau login.';
      } else if (e.code == 'invalid-email') {
        message = 'Email yang Anda masukkan tidak valid.';
      } else {
        message = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _showDialog(context, 'Error Daftar', message);
    } on PlatformException catch (e) {
      _showDialog(context, 'Error Platform',
          e.message ?? 'Terjadi kesalahan platform yang tidak terduga.');
    } catch (e) {
      _showDialog(context, 'Error',
          'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.');
    }
  }

  void _showDialog(BuildContext context, String title, String content,
      {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SignUp',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: txtName,
            decoration: _buildInputDecoration('Nama'),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          TextFormField(
            controller: txtUsername,
            decoration: _buildInputDecoration('Username'),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username tidak boleh kosong';
              }
              return null;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          TextFormField(
            controller: txtEmail,
            decoration: _buildInputDecoration('Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              return null;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          TextFormField(
            controller: txtPhoneNumber,
            decoration: _buildInputDecoration('Nomor HP'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor HP tidak boleh kosong';
              }
              return null;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          TextFormField(
            controller: txtPassword,
            decoration: _buildPasswordInputDecoration(
                'Kata Sandi', _obscurePassword, () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            }),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata Sandi tidak boleh kosong';
              }
              return null;
            },
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi Kata Sandi tidak boleh kosong';
              }
              return null;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          ElevatedButton(
            onPressed: () => signUp(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5.0,
              minimumSize: const Size(double.infinity, 50),
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          _buildLoginLink(),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.3),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }

  InputDecoration _buildPasswordInputDecoration(
      String labelText, bool obscureText, VoidCallback toggleObscureText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.3),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
        ),
        onPressed: toggleObscureText,
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Sudah punya akun?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        TextButton(
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }
}
