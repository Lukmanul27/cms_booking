import 'package:booking_cms/user_pages/booking_screen.dart';
import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:booking_cms/user_pages/detail/detail_screen_history.dart'; // Import DetailScreen from detail_screen.dart
import 'package:booking_cms/widget/widget_user/widget_appbar.dart';
import 'package:booking_cms/widget/widget_user/widget_footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Import untuk format tanggal

class HistoryScreen extends StatefulWidget {
  final String user_id;

  const HistoryScreen({super.key, required this.user_id});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _bookings;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _bookings = fetchBookings();
  }

  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('penyewaan')
        .where('user_id', isEqualTo: widget.user_id)
        .get();

    List<Map<String, dynamic>> bookings = [];

    snapshot.docs.forEach((doc) {
      final data = doc.data();
      final status =
          data.containsKey('status') ? data['status'] : 'Status Not Available';
      final booking = {
        'booking_id': doc.id,
        'status': status,
        'nama': data['nama'] ??
            'Tidak ada nama', // Menambahkan nama ke data booking
        'alamat': data['alamat'] ??
            'Tidak ada alamat', // Menambahkan alamat ke data booking
        'waktu': data['waktu'] ??
            'Tidak ada waktu', // Menambahkan waktu ke data booking
        'pukul': data['pukul'] ??
            'Tidak ada pukul', // Menambahkan pukul ke data booking
        'mulai': data['mulai'] ??
            'Tidak ada waktu mulai', // Menambahkan mulai ke data booking
        'berakhir': data['berakhir'] ??
            'Tidak ada waktu berakhir', // Menambahkan berakhir ke data booking
        'harga': data['harga'] ??
            'Tidak ada harga', // Menambahkan harga ke data booking
        'alasan_penolakan': data['alasan_penolakan'] ??
            'Tidak ada alasan penolakan', // Menambahkan alasan penolakan ke data booking
        'tanggal': data['tanggal'] != null
            ? (data['tanggal'] as Timestamp).toDate()
            : DateTime.now(), // Menambahkan tanggal ke data booking
        'file_url': data['file_url'] ??
            '', // Menambahkan URL bukti pembayaran ke data booking
      };

      bookings.add(booking);
      print('Booking fetched: $booking'); // Tambahkan ini untuk debugging
    });

    return bookings;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(user_id: widget.user_id),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(user_id: widget.user_id),
        ),
      );
    } else if (index == 2) {
      // Stay on the current screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '',
        subtitle: 'Riwayat Booking',
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _bookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada riwayat booking.'));
            } else {
              List<Map<String, dynamic>> recentBookings = [];
              List<Map<String, dynamic>> pastBookings = [];

              for (var booking in snapshot.data!) {
                if (DateTime.now().difference(booking['tanggal']).inHours <
                    24) {
                  recentBookings.add(booking);
                } else {
                  pastBookings.add(booking);
                }
              }

              return ListView(
                children: [
                  if (recentBookings.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Histori Terbaru',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    ...recentBookings
                        .map((booking) => _buildBookingCard(booking))
                        .toList(),
                  ],
                  if (pastBookings.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Histori Sebelumnya',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    ...pastBookings
                        .map((booking) => _buildBookingCard(booking))
                        .toList(),
                  ],
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      child: ListTile(
        title: Text('Booking ID: ${booking['booking_id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${booking['status']}'),
            Text(
                'Tanggal: ${DateFormat('EEEE, dd/MM/yyyy').format(booking['tanggal'])}'), // Menampilkan tanggal
          ],
        ),
        trailing: booking['file_url'].isNotEmpty
            ? ElevatedButton(
                onPressed: () {
                  // Aksi untuk melihat bukti pembayaran
                  _viewProof(booking['file_url']);
                },
                child: const Text('Lihat Bukti Pembayaran'),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(data: booking),
            ),
          );
        },
      ),
    );
  }

  void _viewProof(String fileUrl) {
    // Implementasi untuk melihat bukti pembayaran
    launch(fileUrl);
  }
}
