import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/article.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --------------------------------------------------
  // USER PROFILE
  // --------------------------------------------------

  Future<void> createUserProfile({
    required String name,
    required String email,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
  }

  // --------------------------------------------------
  // ARTICLES
  // --------------------------------------------------

  /// Get all articles from Firestore
  Stream<List<Article>> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Article.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// Get articles belonging to a particular category
  Stream<List<Article>> getArticlesByCategory(
    String category,
  ) {
    return _firestore
        .collection('articles')
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Article.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  // --------------------------------------------------
  // BOOKMARKS
  // --------------------------------------------------

  Future<void> addBookmark({
    required String title,
    required String description,
    required String content,
    required String category,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .set({
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark({
    required String title,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .delete();
  }

  Future<bool> isBookmarked({
    required String title,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .get();

    return document.exists;
  }

  Stream<List<Map<String, dynamic>>> getBookmarks() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  ...doc.data(),
                },
              )
              .toList(),
        );
  }
}