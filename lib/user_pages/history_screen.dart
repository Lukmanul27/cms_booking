import 'package:booking_cms/user_pages/booking_screen.dart';
import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:booking_cms/user_pages/detail/detail_screen_history.dart'; // Import DetailScreen from detail_screen.dart
import 'package:booking_cms/widget/widget_user/widget_appbar.dart';
import 'package:booking_cms/widget/widget_user/widget_footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final status = data.containsKey('status') ? data['status'] : 'Status Not Available';

      return {
        'booking_id': doc.id,
        'status': status,
        'nama': data['nama'], // Menambahkan nama ke data booking
        'alamat': data['alamat'], // Menambahkan alamat ke data booking
        'waktu': data['waktu'], // Menambahkan waktu ke data booking
        'pukul': data['pukul'], // Menambahkan pukul ke data booking
        'mulai': data['mulai'], // Menambahkan mulai ke data booking
        'berakhir': data['berakhir'], // Menambahkan berakhir ke data booking
        'harga': data['harga'], // Menambahkan harga ke data booking
        'alasan_penolakan': data['alasan_penolakan'], // Menambahkan harga ke data booking
      };
    }).toList();
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
        hasNewNotification: false, // Update this based on your requirements
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
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final booking = snapshot.data![index];
                  return Card(
                    child: ListTile(
                      title: Text('Booking ID: ${booking['booking_id']}'),
                      subtitle: Text('Status: ${booking['status']}'),
                      trailing: const Icon(Icons.chevron_right),
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
                },
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
}
