import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addRecentActivity({
    required String title,
    required String category,
    required String type, // 'biochemical' or 'clinical'
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return;
      }

      final String userId = user.uid;
      final Timestamp timestamp = Timestamp.now();

      final recentCollection =
          _firestore.collection('users').doc(userId).collection('recents');

      // 🔍 Check if this title + type combo already exists
      final existing = await recentCollection
          .where('title', isEqualTo: title)
          .where('type', isEqualTo: type)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // ✅ Exists — update the timestamp only
        await existing.docs.first.reference.update({'timestamp': timestamp});
      } else {
        // ➕ New entry
        final recentActivity = {
          'title': title,
          'category': category,
          'type': type,
          'timestamp': timestamp,
          'userId': userId,
        };

        await recentCollection.add(recentActivity);
      }
    } catch (e) {
      throw Exception('Failed to store or update recent activity: $e');
    }
  }

  /// Get recent activities for the current user
  static Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 20,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final String userId = user.uid;

      // Get recent activities ordered by timestamp (most recent first)
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recents')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> recentActivities =
          snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return {
          'id': doc.id,
          'title': data?['title'] ?? '',
          'category': data?['category'] ?? '',
          'type': data?['type'] ?? '',
          'timestamp': data?['timestamp'],
          'userId': data?['userId'] ?? '',
        };
      }).toList();

      return recentActivities;
    } catch (e) {
      throw Exception('Failed to retrieve recent activities: $e');
    }
  }

  static Future<void> updateActivityTimestamp(String title, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recents') // ✅ correct collection
        .where('title', isEqualTo: title)
        .where('type', isEqualTo: type)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      await doc.reference.update({'timestamp': Timestamp.now()});
    } else {}
  }

  /// Clear all recent activities for the current user
  static Future<void> clearRecentActivities() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return;
      }

      final String userId = user.uid;

      // Get all recent activities
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recents')
          .get();

      // Delete all documents in the recents subcollection
      final WriteBatch batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear recent activities: $e');
    }
  }

  /// Remove a specific recent activity
  static Future<void> removeRecentActivity(String activityId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return;
      }

      final String userId = user.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recents')
          .doc(activityId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove recent activity: $e');
    }
  }

  /// Check if user is authenticated
  static bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
