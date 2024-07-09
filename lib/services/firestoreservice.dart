import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream untuk mendapatkan penyewaan berdasarkan user_id
  Stream<List<Map<String, dynamic>>> getPenyewaan(String userId) {
    return _db.collection('penyewaan').where('user_id', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  getJadwal(String waktu) {}
}
