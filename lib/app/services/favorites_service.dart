import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Service to handle favorites functionality for clinical diagnosis and biochemical emergencies
class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add item to favorites
  static Future<bool> addToFavorites({
    required String itemId,
    required String title,
    required String category,
    required FavoriteType type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login to add favorites');
        return false;
      }

      final favoriteData = {
        'itemId': itemId,
        'title': title,
        'category': category,
        'type': type.toString(),
        'addedAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        ...?additionalData,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(itemId)
          .set(favoriteData);

      // Get.snackbar('Success', 'Added to favorites');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add to favorites');
      return false;
    }
  }

  /// Remove item from favorites
  static Future<bool> removeFromFavorites(String itemId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login to manage favorites');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(itemId)
          .delete();

      // Get.snackbar('Success', 'Removed from favorites');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove from favorites');
      return false;
    }
  }

  /// Check if item is in favorites
  static Future<bool> isFavorite(String itemId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(itemId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get all favorites
  static Future<List<FavoriteItem>> getAllFavorites() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FavoriteItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get favorites by type
  static Future<List<FavoriteItem>> getFavoritesByType(
      FavoriteType type) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .where('type', isEqualTo: type.toString())
          .orderBy('addedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FavoriteItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Toggle favorite status
  static Future<bool> toggleFavorite({
    required String itemId,
    required String title,
    required String category,
    required FavoriteType type,
    Map<String, dynamic>? additionalData,
  }) async {
    final isFav = await isFavorite(itemId);

    if (isFav) {
      return await removeFromFavorites(itemId);
    } else {
      return await addToFavorites(
        itemId: itemId,
        title: title,
        category: category,
        type: type,
        additionalData: additionalData,
      );
    }
  }

  /// Stream of favorites for real-time updates
  static Stream<List<FavoriteItem>> getFavoritesStream() {
    final User? user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteItem.fromFirestore(doc))
            .toList());
  }

  /// Generate unique ID for items
  static String generateItemId(
      String title, String category, FavoriteType type) {
    return '${type.toString()}_${category}_$title'
        .replaceAll('/', '_') // Replace forward slashes
        .replaceAll('\\', '_') // Replace backslashes
        .replaceAll(' ', '_') // Replace spaces
        .replaceAll('(', '_') // Replace parentheses
        .replaceAll(')', '_')
        .replaceAll('[', '_') // Replace square brackets
        .replaceAll(']', '_')
        .replaceAll('{', '_') // Replace curly brackets
        .replaceAll('}', '_')
        .replaceAll('&', '_') // Replace ampersands
        .replaceAll('#', '_') // Replace hash symbols
        .replaceAll('?', '_') // Replace question marks
        .replaceAll('=', '_') // Replace equals signs
        .replaceAll('+', '_') // Replace plus signs
        .replaceAll('%', '_') // Replace percent signs
        .replaceAll('@', '_') // Replace at symbols
        .replaceAll('!', '_') // Replace exclamation marks
        .replaceAll("'", '_') // Replace single quotes
        .replaceAll('"', '_') // Replace double quotes
        .replaceAll(':', '_') // Replace colons
        .replaceAll(';', '_') // Replace semicolons
        .replaceAll(',', '_') // Replace commas
        .replaceAll('.', '_') // Replace periods
        .replaceAll('<', '_') // Replace less than
        .replaceAll('>', '_') // Replace greater than
        .replaceAll('|', '_') // Replace pipe symbols
        .replaceAll('*', '_') // Replace asterisks
        .replaceAll(
            RegExp(r'_{2,}'), '_') // Replace multiple underscores with single
        .toLowerCase();
  }
}

/// Enum for favorite types
enum FavoriteType {
  clinicalDiagnosis,
  biochemicalEmergency,
  clinicalPresentations,
}

/// Enum for favorite path types
enum FavoritePathType {
  category,
  item,
}

/// Model for favorite items
class FavoriteItem {
  final String itemId;
  final String title;
  final String category;
  final FavoriteType type;
  final FavoritePathType pathType;
  final DateTime addedAt;
  final String userId;
  final Map<String, dynamic>? additionalData;

  FavoriteItem({
    required this.itemId,
    required this.title,
    required this.category,
    required this.type,
    required this.pathType,
    required this.addedAt,
    required this.userId,
    this.additionalData,
  });

  factory FavoriteItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FavoriteItem(
      itemId: data['itemId'] ?? doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      type: FavoriteType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => FavoriteType.clinicalDiagnosis,
      ),
      pathType: FavoritePathType.values.firstWhere(
        (e) => e.toString() == data['pathType'],
        orElse: () =>
            FavoritePathType.item, // Default to item for backward compatibility
      ),
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      additionalData: data['additionalData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'title': title,
      'category': category,
      'type': type.toString(),
      'pathType': pathType.toString(),
      'addedAt': Timestamp.fromDate(addedAt),
      'userId': userId,
      'additionalData': additionalData,
    };
  }
}

/// Extension to get display name for favorite types
extension FavoriteTypeExtension on FavoriteType {
  String get displayName {
    switch (this) {
      case FavoriteType.clinicalDiagnosis:
        return 'Clinical Diagnosis';
      case FavoriteType.biochemicalEmergency:
        return 'Biochemical Emergency';
      case FavoriteType.clinicalPresentations:
        return 'Clinical Presentations';
    }
  }
}
