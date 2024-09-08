import 'package:booking_cms/Auth/forgot_password.dart';
import 'package:booking_cms/Auth/signup_auth.dart';
import 'package:booking_cms/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _loginController.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    "lib/assets/img/logo.png",
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Silahkan Login Terlebih Dahulu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: _loginController.txtEmailOrPhone,
                    decoration: InputDecoration(
                      labelText: 'Email atau Nomor HP',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan email atau nomor HP Anda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14.0),
                  Obx(() => TextFormField(
                        controller: _loginController.txtPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _loginController.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: _loginController.togglePasswordVisibility,
                          ),
                        ),
                        obscureText: !_loginController.isPasswordVisible.value,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan password Anda';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 16.0),
                  Obx(() {
                    if (_loginController.errorMessage.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showErrorDialog(context, _loginController.errorMessage.value);
                      });
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _loginController.login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5.0,
                      minimumSize: const Size(double.infinity, 50),
                      iconColor: Colors.white,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141414),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const SignUpPage());
                        },
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Get.to(() => ForgotPasswordPage());
                    },
                    child: const Text(
                      "Lupa password?",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loginController.clearErrorMessage();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
