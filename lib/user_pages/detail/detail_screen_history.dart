import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penyewaan', style: TextStyle(
          color: Colors.white,
        )),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Penyewaan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Nama', data['nama']),
              _buildDetailRow('Alamat', data['alamat']),
              _buildDetailRow('Waktu', data['waktu']),
              _buildDetailRow('Pukul', data['pukul']),
              _buildDetailRow('Mulai', data['mulai']),
              _buildDetailRow('Berakhir', data['berakhir']),
              _buildDetailRow('Harga', 'Rp. ${data['harga'] ?? ''}'),
              _buildDetailRow('Status', data['status'] ?? 'Pembayaran Belum Dilakukan'),
              _buildDetailRow('Alasan Penolakan', data['alasan_penolakan']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value != null ? '$value' : '-',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
