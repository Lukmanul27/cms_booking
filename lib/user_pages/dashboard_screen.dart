import 'package:booking_cms/services/jadwal_services.dart';
import 'package:booking_cms/user_pages/history_screen.dart';
import 'package:booking_cms/widget/widget_user/widget_appbar.dart';
import 'package:booking_cms/widget/widget_user/widget_footer.dart';
import 'package:flutter/material.dart';

import 'booking_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String user_id; // Tambahkan user_id

  const DashboardScreen({super.key, required this.user_id});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardScreen(
                  user_id: widget.user_id)), // Tambahkan user_id
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BookingScreen(user_id: widget.user_id)), // Tambahkan user_id
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HistoryScreen(user_id: widget.user_id)), // Tambahkan user_id
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '',
        subtitle: 'Dashboard',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Jadwal Lapangan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Jika lebar layar lebih dari 600, gunakan Row dengan MainAxisAlignment.spaceAround
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LapanganCard(
                          time: 'Siang',
                          img: 'lib/assets/img/lSiang.png',
                        ),
                        _LapanganCard(
                          time: 'Sore',
                          img: 'lib/assets/img/lSore.png',
                        ),
                        _LapanganCard(
                          time: 'Malam',
                          img: 'lib/assets/img/lMalam.png',
                        ),
                      ],
                    );
                  } else {
                    // Jika tidak, gunakan Column dengan MainAxisAlignment.center
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LapanganCard(
                          time: 'Siang',
                          img: 'lib/assets/img/lSiang.png',
                        ),
                        SizedBox(height: 8),
                        _LapanganCard(
                          time: 'Sore',
                          img: 'lib/assets/img/lSore.png',
                        ),
                        SizedBox(height: 8),
                        _LapanganCard(
                          time: 'Malam',
                          img: 'lib/assets/img/lMalam.png',
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _LapanganCard extends StatelessWidget {
  const _LapanganCard({required this.time, required this.img});

  final String time;
  final String img;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfoDialog(context),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // Ubah warna latar belakang sesuai kebutuhan
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                img,
                width: 80,
                height: 80,
                fit: BoxFit.cover, // Sesuaikan dengan gambar
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informasi Lapangan $time'),
          content: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService().getJadwal(time),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Tidak ada data tersedia.');
              } else {
                var jadwalList = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: jadwalList.map((jadwal) {
                        return ListTile(
                          title: Text(jadwal['pukul']),
                          subtitle:
                              Text('Harga Per Jam: Rp.${jadwal['harga']}'),
                        );
                      }).toList(),
                    ),
                    TextButton(
                      child: const Text('Booking'),
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BookingScreen(
                                  user_id: 'user_id')), // Tambahkan user_id
                        );
                      },
                    ),
                  ],
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
