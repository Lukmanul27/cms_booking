import 'package:booking_cms/services/jadwal_services.dart';
import 'package:booking_cms/user_pages/booking/form_screen.dart'; // Import screen untuk form pemesanan
import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:booking_cms/user_pages/history_screen.dart';
import 'package:booking_cms/widget/widget_user/widget_appbar.dart';
import 'package:booking_cms/widget/widget_user/widget_footer.dart';
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final String user_id;

  const BookingScreen({Key? key, required this.user_id}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardScreen(user_id: widget.user_id)),
        );
        break;
      case 1:
        // Already on BookingScreen, no action needed
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HistoryScreen(user_id: widget.user_id)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '', subtitle:'Booking Page'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pilih Waktu Pemesanan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildJadwalTable('Siang'),
                    _buildJadwalTable('Sore'),
                    _buildJadwalTable('Malam'),
                  ],
                ),
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

  Widget _buildJadwalTable(String waktu) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getJadwal(waktu),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(); // No data to display
        }
        List<Map<String, dynamic>> jadwals = snapshot.data!;
        jadwals.sort((a, b) =>
            a['pukul'].compareTo(b['pukul'])); // Sort schedules by time
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white, // Change card color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Add border radius
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BookingTable(
                  title: waktu,
                  jadwals: jadwals,
                  onTap: (selectedTime) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(
                          waktu: waktu,
                          pukul: selectedTime,
                          availableTimes:
                              jadwals.map((e) => e['pukul'] as String).toList(),
                          jadwal: selectedTime,
                          user_id: widget.user_id, // Use widget.user_id to access the parameter
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookingTable extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> jadwals;
  final Function(String) onTap;

  const BookingTable({
    super.key,
    required this.title,
    required this.jadwals,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Change text color to black
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 40.0, // Add column spacing
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Pukul',
                  style: TextStyle(
                    color: Colors.black, // Change text color to black
                  ),
                ),
              )
            ],
            rows: List<DataRow>.generate(
              jadwals.length,
              (index) => DataRow(
                cells: [
                  DataCell(
                    InkWell(
                      onTap: () => onTap(jadwals[index]['pukul']),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          jadwals[index]['pukul'],
                          style: const TextStyle(
                            fontSize: 18, // Increase font size
                            color: Colors.blue, // Change text color to blue
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
