import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // CREATE USER PROFILE
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

  // GET USER PROFILE
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

  // ADD BOOKMARK
  Future<void> addBookmark({
    required String title,
    required String description,
  }) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .set({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // REMOVE BOOKMARK
  Future<void> removeBookmark({
    required String title,
  }) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .delete();
  }

  // CHECK IF ARTICLE IS BOOKMARKED
  Future<bool> isBookmarked({
    required String title,
  }) async {
    User? user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    DocumentSnapshot bookmark = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .get();

    return bookmark.exists;
  }

  // GET ALL BOOKMARKS
  Stream<QuerySnapshot> getBookmarks() {
    User? user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}