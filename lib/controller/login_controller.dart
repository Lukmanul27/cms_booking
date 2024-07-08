import 'package:booking_cms/Admin/dashboard_admin.dart';
import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtEmailOrPhone = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  RxString errorMessage = ''.obs;
  RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      errorMessage.value = ''; // Reset error message before attempting login
      try {
        // Cek apakah input adalah email atau nomor telepon
        if (txtEmailOrPhone.text.contains('@')) {
          // Jika email, login dengan email dan password
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: txtEmailOrPhone.text,
            password: txtPassword.text,
          );
        } else {
          // Jika nomor telepon, login dengan nomor telepon dan password
          await signInWithPhoneNumber(txtEmailOrPhone.text, txtPassword.text);
        }

        // Ambil pengguna saat ini
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            await saveUserSession(userDoc);
            checkUserRole(userDoc);
          } else {
            errorMessage.value = 'Email atau Nomor Handphone Tidak Terdaftar.';
            FirebaseAuth.instance.signOut();
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          errorMessage.value = 'Email atau Nomor Handphone Tidak Terdaftar.';
        } else {
          errorMessage.value = 'Email atau Nomor Handphone dan Password Salah.\nSilahkan Coba Lagi';
        }
      }
    }
  }

  Future<void> signInWithPhoneNumber(String phoneNumber, String password) async {
    // Logika untuk login dengan nomor telepon dan password
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('nomorhp', isEqualTo: phoneNumber)
        .get();

    if (userQuery.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userQuery.docs.first;
      String email = userDoc['email'];

      // Login dengan email yang terkait dengan nomor telepon tersebut
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      errorMessage.value = 'Email atau Nomor Handphone Tidak Terdaftar.';
      throw FirebaseAuthException(
          code: 'user-not-found', message: 'Email atau Nomor Handphone Tidak Terdaftar.');
    }
  }

  Future<void> saveUserSession(DocumentSnapshot userDoc) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setBool('isAdmin', userDoc['role'] == 'admin');
  }

  void checkUserRole(DocumentSnapshot userDoc) {
    String role = userDoc['role'];
    if (role == 'admin') {
      Get.offAll(() => AdminDashboardScreen());
    } else {
      Get.offAll(() => DashboardScreen(user_id: userDoc.id)); // Pass user_id to DashboardScreen
    }
  }

  void clearErrorMessage() {
    errorMessage.value = '';
  }
}
