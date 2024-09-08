import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream untuk mendapatkan penyewaan berdasarkan user_id
  Stream<List<Map<String, dynamic>>> getPenyewaan(String userId) {
    return _db.collection('penyewaan').where('user_id', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Method untuk mengambil jadwal berdasarkan waktu (siang, sore, malam)
  Stream<List<Map<String, dynamic>>> getJadwal(String waktu) {
    return _db
        .collection('jadwal')
        .where('waktu', isEqualTo: waktu)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id, // tambahkan ID dokumen untuk mempermudah update dan delete
                  'pukul': doc['pukul'],
                  'harga': doc['harga'],
                })
            .toList());
  }

  // Method untuk menambah jadwal
  Future<void> addJadwal(String waktu, String pukul, int harga) {
    return _db.collection('jadwal').add({
      'waktu': waktu,
      'pukul': pukul,
      'harga': harga,
    });
  }

  // Method untuk menghapus jadwal
  Future<void> deleteJadwal(String id) {
    return _db.collection('jadwal').doc(id).delete();
  }

  // Method untuk memperbarui jadwal
  Future<void> updateJadwal(String id, String pukul, int harga) {
    return _db.collection('jadwal').doc(id).update({
      'pukul': pukul,
      'harga': harga,
    });
  }

  // Method untuk mendapatkan jadwal sekali saja
  Future<List<Map<String, dynamic>>> getJadwalOnce(String waktu) async {
    final snapshot = await _db
        .collection('jadwal')
        .where('waktu', isEqualTo: waktu)
        .orderBy('pukul')
        .get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'pukul': doc['pukul'],
              'harga': doc['harga'],
            })
        .toList();
  }

  getSchedule(String time) {}

  getStatus(String title, jadwal) {}

  getAllJadwal() {}
}
