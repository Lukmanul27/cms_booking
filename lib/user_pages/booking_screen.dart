import 'package:booking_cms/services/firestoreservice.dart';
import 'package:booking_cms/user_pages/booking/form_screen.dart';
import 'package:booking_cms/user_pages/dashboard_screen.dart';
import 'package:booking_cms/user_pages/history_screen.dart';
import 'package:booking_cms/widget/widget_user/widget_appbar.dart';
import 'package:booking_cms/widget/widget_user/widget_footer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class BookingScreen extends StatefulWidget {
  final String user_id;

  const BookingScreen({Key? key, required this.user_id}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedIndex = 1;
  DateTime? _selectedDate; // To store the selected date

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(user_id: widget.user_id),
          ),
        );
        break;
      case 1:
        // Already on BookingScreen, no action needed
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryScreen(user_id: widget.user_id),
          ),
        );
        break;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '', subtitle: 'Booking Page'),
      body: Container(
        decoration: BoxDecoration(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih Tanggal dan Waktu Pemesanan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text(
                _selectedDate == null
                    ? 'Pilih Tanggal'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedDate != null) ...[
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
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildJadwalTable(String waktu) {
    if (_selectedDate == null) {
      return SizedBox(); // Return an empty widget if no date is selected
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getJadwal(waktu),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(); // No data to display
        }
        List<Map<String, dynamic>> jadwals = snapshot.data!;
        jadwals.sort((a, b) =>
            a['pukul'].compareTo(b['pukul'])); // Sort schedules by time
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
      availableTimes: jadwals.map((e) => e['pukul'] as String).toList(),
      jadwal: selectedTime,
      user_id: widget.user_id,
      selectedDate: _selectedDate!,
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
    Key? key,
    required this.title,
    required this.jadwals,
    required this.onTap,
  }) : super(key: key);

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
              color: Colors.black,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 40.0,
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Pukul',
                  style: TextStyle(
                    color: Colors.black,
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
                            fontSize: 18,
                            color: Colors.blue,
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
