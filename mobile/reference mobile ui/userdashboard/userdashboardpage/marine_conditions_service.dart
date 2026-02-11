import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/user_notification_service.dart';

/// Helper service for marine conditions management
class MarineConditionsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _marineConditions =
      _firestore.collection('marine_conditions');

  /// Update marine conditions and notify all users
  static Future<void> updateMarineConditions({
    required Map<String, dynamic> marineData,
    String? adminName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Update marine conditions in Firestore
      await _marineConditions.doc('current').set({
        ...marineData,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': user.uid,
      }, SetOptions(merge: true));

      // Send notification to all users
      try {
        await UserNotificationService.notifyMarineConditionsUpdate(
          marineData: marineData,
          adminName: adminName ?? user.email ?? 'Administrator',
        );
      } catch (e) {
        print('Failed to send marine conditions notification: $e');
      }
    } catch (e) {
      throw Exception('Failed to update marine conditions: $e');
    }
  }

  /// Get current marine conditions
  static Future<Map<String, dynamic>> getCurrentMarineConditions() async {
    try {
      final doc = await _marineConditions.doc('current').get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get marine conditions: $e');
    }
  }

  /// Stream of marine conditions updates
  static Stream<DocumentSnapshot> getMarineConditionsStream() {
    return _marineConditions.doc('current').snapshots();
  }
}
