import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> createUserProfile({
    required String name,
    required String email,
  }) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
      'name': name,
      'email': email,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile() async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    return await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
  }
}