import 'package:booking_cms/services/firestoreservice.dart';
import 'package:booking_cms/widget/widget_admin/custom_appbar.dart';
import 'package:booking_cms/widget/widget_admin/sidebar_admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

TextEditingController pukulController = TextEditingController();
TextEditingController hargaController = TextEditingController();

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _siangJadwal = [];
  List<Map<String, dynamic>> _soreJadwal = [];
  List<Map<String, dynamic>> _malamJadwal = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    try {
      final siangJadwal = await _firestoreService.getJadwalOnce('Siang');
      final soreJadwal = await _firestoreService.getJadwalOnce('Sore');
      final malamJadwal = await _firestoreService.getJadwalOnce('Malam');

      // Logging data
      if (kDebugMode) {
        print('Siang Jadwal: $siangJadwal');
      }
      if (kDebugMode) {
        print('Sore Jadwal: $soreJadwal');
      }
      if (kDebugMode) {
        print('Malam Jadwal: $malamJadwal');
      }

      setState(() {
        _siangJadwal = siangJadwal;
        _soreJadwal = soreJadwal;
        _malamJadwal = malamJadwal;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching jadwal: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
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
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Jadwal Lapangan Minisoccer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildJadwalSection('Siang', _siangJadwal),
                          const SizedBox(height: 20),
                          _buildJadwalSection('Sore', _soreJadwal),
                          const SizedBox(height: 20),
                          _buildJadwalSection('Malam', _malamJadwal),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addJadwalDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJadwalSection(String jenisWaktu, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          jenisWaktu,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            decoration: BoxDecoration(
                          color: const Color.fromARGB(96, 0, 0, 0),
                          borderRadius: BorderRadius.circular(8),
                        ),
            columns: const [
              DataColumn(label: Text('Pukul', style: TextStyle(color: Colors.white))),
              DataColumn(label: Text('Harga (Rp)', style: TextStyle(color: Colors.white))),
              DataColumn(label: Text('Aksi', style: TextStyle(color: Colors.white))),
            ],
            rows: data.map((jadwal) {
              return DataRow(cells: [
                DataCell(
                  Text(jadwal['pukul'] ?? '', style: const TextStyle(color: Colors.white)),
                ),
                DataCell(
                  Text('Rp.${jadwal['harga'] ?? 0}', style: const TextStyle(color: Colors.white)),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
                        onPressed: () {
                          _editJadwalDialog(context, jadwal['id'], jadwal['pukul'] ?? '', jadwal['harga'] ?? 0);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: () {
                          _deleteJadwal(jadwal['id']);
                        },
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _addJadwalDialog(BuildContext context) async {
    String? selectedWaktu;
    String defaultPukul = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Jadwal'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: const Text('Pilih Waktu'),
                    value: selectedWaktu,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedWaktu = newValue!;
                        switch (selectedWaktu) {
                          case 'Siang':
                            defaultPukul = '10:00';
                            break;
                          case 'Sore':
                            defaultPukul = '15:00';
                            break;
                          case 'Malam':
                            defaultPukul = '18:00';
                            break;
                          default:
                            defaultPukul = '';
                        }
                        pukulController.text = defaultPukul;
                      });
                    },
                    items: <String>['Siang', 'Sore', 'Malam']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pukulController,
                    decoration: const InputDecoration(
                      labelText: 'Pukul',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hargaController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final waktu = selectedWaktu ?? '';
                final pukul = pukulController.text;
                final harga = int.tryParse(hargaController.text) ?? 0;

                if (waktu.isNotEmpty && pukul.isNotEmpty && harga > 0) {
                  await _firestoreService.addJadwal(waktu, pukul, harga);
                  Navigator.of(context).pop();
                  _fetchJadwal();
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _editJadwalDialog(BuildContext context, String id, String pukul, int harga) async {
    pukulController.text = pukul;
    hargaController.text = harga.toString();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pukulController,
                decoration: const InputDecoration(
                  labelText: 'Pukul',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final newPukul = pukulController.text;
                final newHarga = int.tryParse(hargaController.text) ?? 0;

                if (newPukul.isNotEmpty && newHarga > 0) {
                  await _firestoreService.updateJadwal(id, newPukul, newHarga);
                  Navigator.of(context).pop();
                  _fetchJadwal();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteJadwal(String id) async {
    await _firestoreService.deleteJadwal(id);
    _fetchJadwal();
  }
}
