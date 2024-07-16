import 'package:booking_cms/widget/widget_admin/custom_appbar.dart';
import 'package:booking_cms/widget/widget_admin/sidebar_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservasiScreen extends StatefulWidget {
  const ReservasiScreen({super.key});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _fetchReservations() {
    return _firestore
        .collection('penyewaan')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _updateStatus(String id, String status, {String? alasan}) async {
    try {
      final reservationDoc = await _firestore.collection('penyewaan').doc(id).get();
      final reservationData = reservationDoc.data() as Map<String, dynamic>;
      final tanggal = (reservationData['tanggal'] as Timestamp).toDate();
      final waktuMulai = reservationData['mulai'];
      final waktuBerakhir = reservationData['berakhir'];

      if (status == 'Diterima') {
        bool alreadyBooked = await _checkExistingReservation(tanggal, waktuMulai, waktuBerakhir);
        if (alreadyBooked) {
          _showAlreadyBookedDialog();
          return;
        }
      }

      final updateData = {'status': status};
      if (alasan != null) updateData['alasan_penolakan'] = alasan;
      await _firestore.collection('penyewaan').doc(id).update(updateData);

      final userId = reservationData['user_id'];
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userToken = userDoc['token'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diperbarui menjadi $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    }
  }

  Future<bool> _checkExistingReservation(DateTime tanggal, String waktuMulai, String waktuBerakhir) async {
    final querySnapshot = await _firestore
        .collection('penyewaan')
        .where('tanggal', isEqualTo: Timestamp.fromDate(tanggal))
        .where('status', isEqualTo: 'Diterima')
        .get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String existingWaktuMulai = data['mulai'];
      String existingWaktuBerakhir = data['berakhir'];

      // Mengubah waktu mulai dan berakhir menjadi DateTime untuk perbandingan
      DateTime existingStartTime = DateFormat('HH:mm').parse(existingWaktuMulai);
      DateTime existingEndTime = DateFormat('HH:mm').parse(existingWaktuBerakhir);
      DateTime newStartTime = DateFormat('HH:mm').parse(waktuMulai);
      DateTime newEndTime = DateFormat('HH:mm').parse(waktuBerakhir);

      // Memeriksa apakah waktu baru tumpang tindih dengan waktu yang ada
      if ((newStartTime.isBefore(existingEndTime) && newStartTime.isAfter(existingStartTime)) ||
          (newEndTime.isBefore(existingEndTime) && newEndTime.isAfter(existingStartTime)) ||
          (newStartTime.isAtSameMomentAs(existingStartTime) || newEndTime.isAtSameMomentAs(existingEndTime)) ||
          (newStartTime.isBefore(existingStartTime) && newEndTime.isAfter(existingEndTime))) {
        return true;
      }
    }

    return false;
  }

  void _showAlreadyBookedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Penyewaan Sudah Diterima'),
          content: const Text('Penyewaan pada tanggal dan waktu yang dipilih sudah ada yang diterima.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewProof(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    print("URL yang digunakan: $fileUrl");

    try {
      final bool launched = await launch(
        fileUrl,
        forceSafariVC: false,
        forceWebView: false,
        enableJavaScript: true,
      );
      if (!launched) {
        print("Gagal membuka dengan launch");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka bukti pembayaran')),
        );
      }
    } catch (e) {
      print("Error saat membuka URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat membuka bukti pembayaran')),
      );
    }
  }

  void _showRejectDialog(String id) {
    final TextEditingController alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tolak Reservasi'),
          content: TextField(
            controller: alasanController,
            decoration: const InputDecoration(
              labelText: 'Alasan Penolakan',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final alasan = alasanController.text.trim();
                if (alasan.isNotEmpty) {
                  _updateStatus(id, 'Ditolak', alasan: alasan);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan penolakan harus diisi')),
                  );
                }
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _fetchReservations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada reservasi ditemukan'));
            }

            const statusOrder = [
              'Pembayaran sedang Divalidasi', 
              'Diterima', 
              'Ditolak', 
            ];

            Map<String, List<DocumentSnapshot>> groupedReservations = {};
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Tidak Diketahui';

              if (!groupedReservations.containsKey(status)) {
                groupedReservations[status] = [];
              }
              groupedReservations[status]!.add(doc);
            }

            if (groupedReservations['Pembayaran sedang Divalidasi'] != null) {
              groupedReservations['Pembayaran sedang Divalidasi']!.sort((a, b) {
                var aData = a.data() as Map<String, dynamic>;
                var bData = b.data() as Map<String, dynamic>;
                return (aData['timestamp'] as Timestamp).compareTo(bData['timestamp'] as Timestamp);
              });
            }

            return ListView.builder(
              itemCount: statusOrder.length,
              itemBuilder: (context, index) {
                var status = statusOrder[index];
                var reservations = groupedReservations[status] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reservations.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Status: $status',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reservations.length,
                      itemBuilder: (context, idx) {
                        var data = reservations[idx].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              data['nama'] ?? 'Tidak ada nama',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Status: ${data['status'] ?? 'Tidak ada status'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _updateStatus(reservations[idx].id, 'Diterima'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _showRejectDialog(reservations[idx].id),
                                ),
                              ],
                            ),
                            onTap: () => _showDetailDialog(data),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Reservasi'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nama', data['nama'] ?? 'Tidak ada nama'),
                _buildDetailRow('Alamat', data['alamat'] ?? 'Tidak ada alamat'),
                _buildDetailRow('Waktu', data['waktu'] ?? 'Tidak ada waktu'),
                _buildDetailRow('Waktu Mulai', data['mulai'] ?? 'Tidak ada waktu mulai'),
                _buildDetailRow('Waktu Selesai', data['berakhir'] ?? 'Tidak ada waktu selesai'),
                _buildDetailRow('Total Harga', data['total_harga']?.toString() ?? 'Tidak ada harga'),
                _buildDetailRow('Status', data['status'] ?? 'Tidak ada status'),
                _buildDetailRow('Tanggal', DateFormat('EEEE, dd/MM/yyyy').format((data['tanggal'] as Timestamp).toDate())),
                if (data['file_url'] != null && data['file_url'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _viewProof(data['file_url']),
                      child: const Text('Lihat Bukti Pembayaran'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}