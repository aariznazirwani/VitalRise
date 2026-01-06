import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser({
    required String id,
    required String name,
    required int age,
  }) async {
    await _db.collection('users').doc(id).set({
      'name': name,
      'age': age,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUsers() {
    return _db.collection('users').snapshots();
  }

  // Beneficiary methods
  Future<void> addBeneficiary({
    required String name,
    required String aadhar,
    required String dob,
    String? phone,
  }) async {
    await _db.collection('beneficiaries').add({
      'name': name,
      'aadhar': aadhar,
      'dob': dob,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getBeneficiaries() {
    return _db
        .collection('beneficiaries')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteBeneficiary(String id) async {
    await _db.collection('beneficiaries').doc(id).delete();
  }
}
