import 'package:booking_cms/user_pages/booking/pembayaran_screen.dart';
import 'package:booking_cms/user_pages/booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FormScreen extends StatefulWidget {
  final String waktu;
  final String pukul;
  final List<String> availableTimes;
  final String jadwal;
  final String user_id;

  const FormScreen({
    Key? key,
    required this.waktu,
    required this.pukul,
    required this.availableTimes,
    required this.jadwal,
    required this.user_id,
  }) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _startTime = '';
  String _endTime = '';
  String _price = 'Loading...';
  late String _currentUserId;
  late String _formId;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1000),
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 2 * 3.141592653589793,
    ).animate(_controller);

    _initializeTimeAndPrice();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  void _initializeTimeAndPrice() {
    _startTime = widget.pukul;

    if (_startTime == widget.availableTimes.last) {
      _endTime = '60 menit';
      _calculateSinglePrice();
    } else {
      _endTime = widget.availableTimes.firstWhere(
        (time) => time.compareTo(_startTime) > 0,
        orElse: () => widget.availableTimes.last,
      );
      _calculatePrice();
    }
  }

  void _calculateSinglePrice() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('waktu', isEqualTo: widget.waktu)
          .where('pukul', isEqualTo: _startTime)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int price = querySnapshot.docs.first['harga'];
        setState(() {
          _price = price.toString();
        });
      } else {
        setState(() {
          _price = 'No price available';
        });
      }
    } catch (e) {
      setState(() {
        _price = 'Error fetching price: $e';
      });
    }
  }

  void _calculatePrice() async {
    try {
      int totalPrice = await _fetchPrice();
      setState(() {
        _price = totalPrice.toString();
      });
    } catch (e) {
      setState(() {
        _price = 'Error fetching price: $e';
      });
    }
  }

  Future<int> _fetchPrice() async {
    int startIndex = widget.availableTimes.indexOf(_startTime);
    int endIndex = widget.availableTimes.indexOf(_endTime);
    int totalPrice = 0;

    for (int i = startIndex; i < endIndex; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('waktu', isEqualTo: widget.waktu)
          .where('pukul', isEqualTo: widget.availableTimes[i])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int pricePerHour = querySnapshot.docs.first['harga'];
        totalPrice += pricePerHour;
      } else {
        return totalPrice;
      }
    }

    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    List<String> validEndTimes = widget.availableTimes
        .where((time) =>
            widget.availableTimes.indexOf(time) >
            widget.availableTimes.indexOf(_startTime))
        .toList();

    if (!validEndTimes.contains(_endTime)) {
      _endTime = validEndTimes.isNotEmpty ? validEndTimes[0] : widget.pukul;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const BookingScreen(user_id: 'user_id')),
            );
          },
        ),
        title: const Text('Form Penyewaan'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    const Text(
                      'Masukkan Detail Penyewaan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    RotationTransition(
                      turns: _animation,
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 50.0,
                        color: Colors.white60,
                      ),
                    ),
                    const Text(
                      'Harap lengkapi data berikut ini dengan benar!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      labelText: 'Nama',
                      onSaved: (value) => _name = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      labelText: 'Alamat',
                      onSaved: (value) => _address = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTimeInfo(validEndTimes),
                    const SizedBox(height: 32),
                    _buildCalendar(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField({
    required String labelText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildTimeInfo(List<String> validEndTimes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Mulai:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _startTime,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Waktu Berakhir:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        if (_startTime == widget.availableTimes.last)
          const Text(
            '60 menit',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade900,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _endTime,
                dropdownColor: const Color(0xFF6F6FDB),
                items: validEndTimes.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    );
                  },
                ).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _endTime = newValue!;
                    _calculatePrice();
                  });
                },
                isExpanded: true,
                iconEnabledColor: Colors.white,
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          'Total Pembayaran: Rp. ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _price,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.week: 'Week',
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.month,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: const CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.white),
        weekendTextStyle: TextStyle(color: Colors.white),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayTextStyle: TextStyle(color: Colors.white),
        outsideTextStyle: TextStyle(color: Colors.white),
        disabledTextStyle: TextStyle(color: Colors.white),
        holidayTextStyle: TextStyle(color: Colors.white),
        markerDecoration: BoxDecoration(color: Colors.white),
      ),
      headerStyle: const HeaderStyle(
        titleTextStyle: TextStyle(color: Colors.white),
        formatButtonTextStyle: TextStyle(color: Colors.white),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Colors.white,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.white,
        ),
      ),
    );
  }

  ElevatedButton _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          try {
            _formId = DateTime.now().millisecondsSinceEpoch.toString();
            Timestamp timestamp = Timestamp.now();
            DocumentReference bookingRef =
                await FirebaseFirestore.instance.collection('penyewaan').add({
              'nama': _name,
              'alamat': _address,
              'waktu': widget.waktu,
              'pukul': widget.pukul,
              'mulai': _startTime,
              'berakhir': _endTime,
              'harga': _price,
              'user_id': widget.user_id,
              'form_id': _formId,
              'timestamp': timestamp,
              'tanggal': _selectedDay,
            });
            String bookingId = bookingRef.id;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PembayaranScreen(
                  price: _price,
                  bookingId: bookingId,
                  user_id: widget.user_id,
                  form_id: _formId,
                ),
              ),
            );
          } catch (e) {
            print('Error submitting form: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error submitting form: $e')),
            );
          }
        }
      },
      child: const Text(
        'Submit',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6F6FDB),
        ),
      ),
    );
  }
}

CalendarFormat _calendarFormat = CalendarFormat.month;
