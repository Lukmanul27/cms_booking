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
  Map<String, int> acceptedBookingCounts = {};
  Map<String, int> rejectedBookingCounts = {};
  String selectedFilter = 'Perhari'; // Default filter type
  String selectedDate = ''; // Selected date for filtering

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  Future<void> _fetchBookingData() async {
    try {
      final snapshot = await _firestore.collection('penyewaan').get();

      Map<String, int> acceptedCounts = {};
      Map<String, int> rejectedCounts = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime bookingDate = (data['tanggal'] as Timestamp).toDate();
        String dateKey = _getDateKey(bookingDate);
        bool isAccepted = data['status'] == 'Diterima';

        if (isAccepted) {
          if (acceptedCounts.containsKey(dateKey)) {
            acceptedCounts[dateKey] = acceptedCounts[dateKey]! + 1;
          } else {
            acceptedCounts[dateKey] = 1;
          }
        } else {
          if (rejectedCounts.containsKey(dateKey)) {
            rejectedCounts[dateKey] = rejectedCounts[dateKey]! + 1;
          } else {
            rejectedCounts[dateKey] = 1;
          }
        }
      }

      setState(() {
        acceptedBookingCounts = acceptedCounts;
        rejectedBookingCounts = rejectedCounts;
        selectedDate = acceptedBookingCounts.isNotEmpty ? acceptedBookingCounts.keys.first : '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data booking: $e')),
      );
    }
  }

  String _getDateKey(DateTime date) {
    switch (selectedFilter) {
      case 'Perhari':
        return DateFormat('dd/MM').format(date);
      case 'Perbulan':
        return DateFormat('MM/yyyy').format(date);
      default:
        return DateFormat('dd/MM').format(date);
    }
  }

  List<BarChartGroupData> _createBarChartData(
      Map<String, int> bookingCounts, Color barColor) {
    List<BarChartGroupData> barGroups = [];
    List<String> dates = bookingCounts.keys.toList()..sort();

    for (int i = 0; i < dates.length; i++) {
      String date = dates[i];
      int count = bookingCounts[date] ?? 0;

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
    Map<String, int> filteredAcceptedCounts = acceptedBookingCounts
        .map((key, value) =>
            MapEntry(key, selectedDate == key ? value : 0));
    Map<String, int> filteredRejectedCounts = rejectedBookingCounts
        .map((key, value) =>
            MapEntry(key, selectedDate == key ? value : 0));
    Color acceptedBarColor = Colors.yellow;
    Color rejectedBarColor = Colors.red;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    items: <String>['Perhari', 'Perbulan'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilter = newValue!;
                        _fetchBookingData();
                      });
                    },
                    underline: SizedBox(),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: selectedDate.isNotEmpty ? selectedDate : null,
                    items: (acceptedBookingCounts.keys.toList()..sort()).map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDate = newValue!;
                      });
                    },
                    underline: SizedBox(),
                    hint: Text('Pilih Tanggal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: acceptedBookingCounts.isEmpty && rejectedBookingCounts.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      children: [
                        const Text(
                          'Grafik Booking Diterima',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  barGroups: _createBarChartData(filteredAcceptedCounts, acceptedBarColor),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: const Border(
                                      top: BorderSide.none,
                                      right: BorderSide.none,
                                      left: BorderSide(width: 1),
                                      bottom: BorderSide(width: 1),
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          List<String> dates =
                                              filteredAcceptedCounts.keys.toList()..sort();
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text(
                                              dates[value.toInt()],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Grafik Booking Ditolak',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  barGroups: _createBarChartData(filteredRejectedCounts, rejectedBarColor),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: const Border(
                                      top: BorderSide.none,
                                      right: BorderSide.none,
                                      left: BorderSide(width: 1),
                                      bottom: BorderSide(width: 1),
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          List<String> dates =
                                              filteredRejectedCounts.keys.toList()..sort();
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text(
                                              dates[value.toInt()],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
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
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
