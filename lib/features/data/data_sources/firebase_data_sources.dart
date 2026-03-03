import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDataSources {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInAnonimously() async {
    return await auth.signInAnonymously();
  }

  String? getCurrentUid() {
    return auth.currentUser?.uid;
  }

  Future<void> saveToFirestore(Map<String, dynamic> data) async {
    try {
      String? uid = auth.currentUser?.uid;

      if (uid == null) {
        throw Exception("User belum login, tidak bisa simpan data");
      }

      Map<String, dynamic> dataTosave = Map.from(data);
      dataTosave['timestamp'] = FieldValue.serverTimestamp();

      await firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .add(dataTosave);
    } catch (e) {
      throw Exception("Gagal simpan ke firestore: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchFromFirestore(String uid) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        data['id'] = doc.id;

        return data;
      }).toList();
    } catch (e) {
      throw Exception("Gagal mengambil data riwayat!: $e");
    }
  }

  Future<void> deleteFromFirestore(String docId) async {
    try {
      String? uid = auth.currentUser?.uid;

      if (uid == null) {
        throw Exception("User tidak dikenal, tudak bisa hapus data");
      }

      await firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception("Tidak dapat menghapus: $e");
    }
  }
}
