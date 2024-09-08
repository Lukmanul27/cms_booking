import 'dart:io';

import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';

class PembayaranScreen extends StatefulWidget {
  final String price;
  final String bookingId;
  final String user_id;
  final String form_id; // Add form_id

  const PembayaranScreen({
    Key? key,
    required this.price,
    required this.bookingId,
    required this.user_id,
    required this.form_id, required String userId, required String waktu, // Receive form_id
  }) : super(key: key);

  @override
  _PembayaranScreenState createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fileName;
  PlatformFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    print('Received bookingId: ${widget.bookingId}');
    print('Received form_id: ${widget.form_id}'); // Print received form_id
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
        _fileName = _pickedFile?.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_pickedFile != null) {
      try {
        // Upload file to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('payment_proofs/${_pickedFile!.name}');

        UploadTask uploadTask;

        if (kIsWeb) {
          // For web
          uploadTask = storageRef.putData(_pickedFile!.bytes!);
        } else {
          // For mobile platforms
          uploadTask = storageRef.putFile(File(_pickedFile!.path!));
        }

        final snapshot = await uploadTask.whenComplete(() => {});

        // Get the download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update the booking document in Firestore
        await FirebaseFirestore.instance
            .collection('penyewaan')
            .doc(widget.bookingId)
            .update({
          'file_name': _fileName,
          'file_url': downloadUrl,
          'status': 'Pembayaran sedang Divalidasi',
          'user_id': widget.user_id,
          'form_id': widget.form_id, // Update form_id in Firestore
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran Diproses')),
        );

        // Notify the user via Firebase Cloud Messaging
        await sendNotification();

        // Display confirmation dialog
        await Future.delayed(const Duration(seconds: 2));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mohon Untuk Menunggu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pembayaran Anda Sedang di Validasi',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(
                          user_id: widget.user_id,
                        ),
                      ),
                    );
                  },
                  child: const Text('Kembali ke Dashboard'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus mengunggah bukti pembayaran')),
      );
    }
  }

  Future<void> sendNotification() async {
    // TODO: Implement the logic to send a notification using Firebase Cloud Functions or any other preferred method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      "Pembayaran",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Mohon Lakukan Pembayaran Sebesar:\nRP. ${widget.price}",
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Silakan melakukan pembayaran melalui salah satu metode berikut:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildPaymentMethod(
                    title: "Transfer Bank",
                    details: [
                      "Nomor Rekening: 1234567890",
                      "Bank: BNI",
                      "Atas Nama: Feby",
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildPaymentMethod(
                    title: "Dana",
                    details: [
                      "Nomor Dana: 081234567890",
                      "Atas Nama: Feby",
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Setelah melakukan pembayaran, mohon untuk melampirkan bukti pembayaran. Reservasi Anda akan diproses setelah pembayaran terverifikasi.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Bukti Pembayaran",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Unggah Bukti Pembayaran",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    readOnly: true,
                    onTap: _pickFile,
                    validator: (value) {
                      if (_pickedFile == null) {
                        return 'Anda harus mengunggah bukti pembayaran';
                      }
                      return null;
                    },
                    controller: TextEditingController(
                      text: _fileName ?? '',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _uploadFile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        "Konfirmasi Pembayaran",
                        style: TextStyle(fontSize: 18),
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

  Widget buildPaymentMethod({
    required String title,
    required List<String> details,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details
                .map((detail) => Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
