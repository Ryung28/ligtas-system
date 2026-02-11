import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/user_notification_service.dart';

/// Repository class for handling Ocean Education data.
/// This separates data handling logic from the UI for better architecture.
class OceanEducationRepository {
  final FirebaseFirestore _firestore;

  // Collection reference for ocean education data
  final String _collectionPath = 'ocean_education';

  // Singleton instance
  static final OceanEducationRepository _instance =
      OceanEducationRepository._internal(FirebaseFirestore.instance);

  // Factory constructor for the singleton
  factory OceanEducationRepository() => _instance;

  // Internal constructor for the singleton
  OceanEducationRepository._internal(this._firestore);

  /// Fetch content for a specific category
  /// Returns the most recent content item for the category
  /// Ensures exact category name matching (trimmed, case-sensitive)
  Future<Map<String, dynamic>?> getContentByCategory(String category) async {
    try {
      // Trim whitespace from category name to ensure exact matching
      final trimmedCategory = category.trim();
      
      // Query for content matching the exact category name
      // Note: Firestore queries are case-sensitive, so category names must match exactly
      QuerySnapshot snapshot;
      try {
        // Try with orderBy first (requires index)
        snapshot = await _firestore
            .collection(_collectionPath)
            .where('category', isEqualTo: trimmedCategory)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
      } catch (e) {
        // If index doesn't exist, fall back to unordered query
        // Then sort client-side
        debugPrint('⚠️ Index not available, using client-side sorting for category: "$trimmedCategory"');
        final allDocs = await _firestore
            .collection(_collectionPath)
            .where('category', isEqualTo: trimmedCategory)
            .get();
        
        // Sort by timestamp client-side (most recent first)
        final sortedDocs = allDocs.docs.toList()
          ..sort((a, b) {
            final aTime = a.data()['timestamp'] as Timestamp?;
            final bTime = b.data()['timestamp'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // Descending order
          });
        
        // Create a new QuerySnapshot-like structure
        // Use the first document from sorted list
        if (sortedDocs.isNotEmpty) {
          final firstDoc = sortedDocs.first;
          // Return the data directly since we can't create QuerySnapshot
          final contentData = firstDoc.data();
          // Verify the category matches exactly (safety check)
          final contentCategory = (contentData['category'] as String? ?? '').trim();
          if (contentCategory != trimmedCategory) {
            debugPrint('⚠️ Category mismatch: Expected "$trimmedCategory", got "$contentCategory"');
            return null;
          }
          debugPrint('✅ Found content for category "$trimmedCategory": "${contentData['title']}"');
          return contentData;
        }
        
        debugPrint('ℹ️ No content found for category: "$trimmedCategory"');
        return null;
      }

      if (snapshot.docs.isNotEmpty) {
        final contentData = snapshot.docs.first.data() as Map<String, dynamic>;
        // Verify the category matches exactly (safety check)
        final contentCategory = (contentData['category'] as String? ?? '').trim();
        if (contentCategory != trimmedCategory) {
          // Category mismatch - this shouldn't happen but log it
          debugPrint('⚠️ Category mismatch: Expected "$trimmedCategory", got "$contentCategory"');
          debugPrint('   Content title: "${contentData['title']}"');
          debugPrint('   This content will be skipped - category name must match exactly');
          return null;
        }
        debugPrint('✅ Found content for category "$trimmedCategory": "${contentData['title']}"');
        return contentData;
      }

      debugPrint('ℹ️ No content found for category: "$trimmedCategory"');
      return null;
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to fetch content for category "$category": $e');
    }
  }
  
  /// Get all content items for a category (for future use if needed)
  Future<List<Map<String, dynamic>>> getAllContentByCategory(String category) async {
    try {
      final trimmedCategory = category.trim();
      
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('category', isEqualTo: trimmedCategory)
          .get();
      
      // Sort by timestamp (most recent first)
      final sortedDocs = snapshot.docs.toList()
        ..sort((a, b) {
          final aTime = a.data()['timestamp'] as Timestamp?;
          final bTime = b.data()['timestamp'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
      
      return sortedDocs.map((doc) {
        final data = doc.data();
        // Verify category matches
        final contentCategory = (data['category'] as String? ?? '').trim();
        if (contentCategory != trimmedCategory) {
          debugPrint('⚠️ Skipping content with mismatched category: "$contentCategory" != "$trimmedCategory"');
          return null;
        }
        return data;
      }).where((data) => data != null).cast<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception('Failed to fetch all content for category "$category": $e');
    }
  }

  /// Save content for a specific category
  Future<void> saveContent({
    required String category,
    required String title,
    required String content,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('category', isEqualTo: category)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Update existing record
        await _firestore
            .collection(_collectionPath)
            .doc(snapshot.docs.first.id)
            .update({
          'title': title,
          'content': content,
          'lastModified': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new record
        await _firestore.collection(_collectionPath).add({
          'category': category,
          'title': title,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Send notification to all users about new content
        try {
          final user = FirebaseAuth.instance.currentUser;
          await UserNotificationService.notifyNewEducationContent(
            category: category,
            title: title,
            adminName: user?.email ?? 'Administrator',
          );
        } catch (e) {
          // Continue execution even if notification fails
          print('Failed to send education content notification: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to save content for category "$category": $e');
    }
  }

  /// Get default content for a category if no data is available in Firestore
  /// Returns empty/minimal content - no hardcoded defaults
  Map<String, String> getDefaultContent(String category) {
    // Return minimal placeholder content instead of hardcoded defaults
    // This ensures admins must create content through the admin panel
    return {
      'title': category,
      'content': 'Content for this category is being prepared. Please check back soon!',
    };
  }
}
