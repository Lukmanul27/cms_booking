import 'package:booking_cms/widget/widget_admin/custom_appbar.dart';
import 'package:booking_cms/widget/widget_admin/sidebar_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, int>> bookingCounts = {
    'Diterima': {},
    'Ditolak': {},
  };
  String selectedStatus = 'Diterima'; // Default filter option
  String selectedMonth = ''; // Selected month for filtering

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  Future<void> _fetchBookingData() async {
    try {
      final acceptedSnapshot = await _firestore
          .collection('penyewaan')
          .where('status', isEqualTo: 'Diterima')
          .get();

      final rejectedSnapshot = await _firestore
          .collection('penyewaan')
          .where('status', isEqualTo: 'Ditolak')
          .get();

      Map<String, int> acceptedCounts = {};
      Map<String, int> rejectedCounts = {};

      for (var doc in acceptedSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime bookingDate = (data['tanggal'] as Timestamp).toDate();
        String monthYear = DateFormat('MM/yyyy').format(bookingDate);

        if (acceptedCounts.containsKey(monthYear)) {
          acceptedCounts[monthYear] = acceptedCounts[monthYear]! + 1;
        } else {
          acceptedCounts[monthYear] = 1;
        }
      }

      for (var doc in rejectedSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime bookingDate = (data['tanggal'] as Timestamp).toDate();
        String monthYear = DateFormat('MM/yyyy').format(bookingDate);

        if (rejectedCounts.containsKey(monthYear)) {
          rejectedCounts[monthYear] = rejectedCounts[monthYear]! + 1;
        } else {
          rejectedCounts[monthYear] = 1;
        }
      }

      setState(() {
        bookingCounts['Diterima'] = acceptedCounts;
        bookingCounts['Ditolak'] = rejectedCounts;
        selectedMonth = bookingCounts['Diterima']!.isNotEmpty
            ? bookingCounts['Diterima']!.keys.first
            : '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data booking: $e')),
      );
    }
  }

  List<BarChartGroupData> _createBarChartData(
      Map<String, int> bookingCounts, Color barColor) {
    List<BarChartGroupData> barGroups = [];
    List<String> months = bookingCounts.keys.toList()..sort();

    for (int i = 0; i < months.length; i++) {
      String month = months[i];
      int count = bookingCounts[month] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: count.toDouble(),
              color: barColor,
              width: 16,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> selectedCounts =
        bookingCounts[selectedStatus] ?? {};
    Map<String, int> filteredCounts = selectedCounts
        .map((key, value) =>
            MapEntry(key, selectedMonth == key ? value : 0));
    Color barColor =
        selectedStatus == 'Diterima' ? Colors.white : Colors.red;

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
              Color(0xFF4CAF50), // Green shade for soccer field
              Color(0xFF388E3C), // Darker green shade for contrast
              Color(0xFF1B5E20), // Even darker green shade for depth
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedStatus,
                  items: <String>['Diterima', 'Ditolak'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                      selectedMonth = bookingCounts[selectedStatus]!.isNotEmpty
                          ? bookingCounts[selectedStatus]!.keys.first
                          : '';
                    });
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedMonth,
                  items: bookingCounts[selectedStatus]!
                      .keys
                      .toList()
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMonth = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedCounts.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: _createBarChartData(filteredCounts, barColor),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                List<String> months =
                                    filteredCounts.keys.toList()..sort();
                                return Text(
                                  months[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.black26,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: const Color(0xFF1B5E20),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        backgroundColor: Colors.black12,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
