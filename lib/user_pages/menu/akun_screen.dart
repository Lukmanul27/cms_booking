import 'dart:io';

import 'package:booking_cms/Auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({Key? key}) : super(key: key);

  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? user;
  Map<String, dynamic>? userData;
  File? _imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        _nameController.text = userData!['nama'] ?? '';
        _phoneNumberController.text = userData!['nomorhp'] ?? '';
        _usernameController.text = userData!['username'] ?? '';
        _emailController.text = user!.email ?? '';
        _alamatController.text = userData!['alamat'] ?? '';
      });
    }
  }

  Future<void> _updateUserData() async {
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user!.uid).update({
          'nama': _nameController.text,
          'nomorhp': _phoneNumberController.text,
          'alamat': _alamatController.text,
        });
        Get.snackbar('Update Berhasil', 'Informasi akun telah diperbarui.');
      } catch (e) {
        Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage(_imageFile!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    if (user != null) {
      try {
        Reference storageReference =
            _storage.ref().child('profile_images/${user!.uid}.jpg');
        await storageReference.putFile(imageFile);
        String imageUrl = await storageReference.getDownloadURL();
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .update({'photoUrl': imageUrl});
        setState(() {
          userData!['photoUrl'] = imageUrl;
        });
        Get.snackbar('Upload Berhasil', 'Foto profil telah diperbarui.');
      } catch (e) {
        Get.snackbar('Error', 'Gagal mengunggah foto profil.');
      }
    }
  }

  void _resetPassword() async {
    if (user != null) {
      await _auth.sendPasswordResetEmail(email: user!.email!);
      Get.snackbar(
          'Reset Password', 'Link reset password telah dikirim ke email Anda.');
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin logout?'),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'LogOut',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.of(context).pop(true);
                  Get.offAll(() => const LoginPage());
                },
              ),
              TextButton(
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value) {
        Get.snackbar('Logout Berhasil', 'Anda telah logout.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Akun',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
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
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow,
                                    blurRadius: 5,
                                    spreadRadius: 3,
                                    offset: const Offset(1, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: userData!['photoUrl'] != null
                                    ? Image.network(
                                        userData!['photoUrl'],
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      )
                                    : Image.asset(
                                        'assets/img/profile_image.png',
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      ),
                              ),
                            ),
                            // IconButton(
                            //   onPressed: () => _pickImage(ImageSource.gallery),
                            //   icon: const Icon(
                            //     Icons.edit,
                            //     color: Colors.red,
                            //     iconSize: 30,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.red,
                            ),
                            label: const Text(
                              'Galeri',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.red,
                            ),
                            label: const Text(
                              'Kamera',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _usernameController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      filled: true,
                                      fillColor: Colors.blueAccent,
                                      border: OutlineInputBorder(),
                                    ),
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nameController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Nama',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      filled: true,
                                      fillColor: Colors.blueAccent,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneNumberController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Nomor HP',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      filled: true,
                                      fillColor: Colors.blueAccent,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      filled: true,
                                      fillColor: Colors.blueAccent,
                                      border: OutlineInputBorder(),
                                    ),
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _alamatController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Alamat',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      filled: true,
                                      fillColor: Colors.blueAccent,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _updateUserData,
                              icon: const Icon(Icons.save),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: Colors.yellowAccent,
                              ),
                              label: const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _resetPassword,
                        icon: const Icon(Icons.lock),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.yellow,
                        ),
                        label: const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.yellow,
                        ),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
