import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _userNotifications =
      _firestore.collection('user_notifications');
  static final CollectionReference _users = _firestore.collection('users');

  /// Create a notification for all users with expanded content
  static Future<void> createNotificationForAllUsers({
    required String title,
    required String message,
    required String type,
    String? referenceId,
    String? expandedContent,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Get all user IDs
      final usersSnapshot = await _users.get();
      final List<String> userIds =
          usersSnapshot.docs.map((doc) => doc.id).toList();

      // Create notifications for all users
      final batch = _firestore.batch();

      for (String userId in userIds) {
        final notificationRef = _userNotifications.doc();
        batch.set(notificationRef, {
          'userId': userId,
          'title': title,
          'message': message,
          'type': type,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'referenceId': referenceId,
          'expandedContent': expandedContent ?? '',
          'additionalData': additionalData ?? {},
        });
      }

      await batch.commit();
      debugPrint('✅ Created ${userIds.length} notifications for type: $type');

      // Send push notification for ban period updates
      if (type == 'ban_period') {
        try {
          final List<Future<void>> pushNotificationFutures = [];

          for (String userId in userIds) {
            final userDoc = await _users.doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              final firebaseUID = userData['firebaseUID'] as String?;

              if (firebaseUID != null) {
                // Push notification functionality can be added here when available
                debugPrint('📱 Would send push notification to $firebaseUID');
              }
            }
          }

          // Send push notifications in parallel (non-blocking)
          if (pushNotificationFutures.isNotEmpty) {
            Future.wait(pushNotificationFutures).catchError((e) {
              debugPrint('⚠️ Some push notifications failed: $e');
              return <void>[];
            });
            debugPrint(
                '📱 Queued ${pushNotificationFutures.length} push notifications');
          }
        } catch (e) {
          debugPrint('❌ Failed to send push notifications: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error creating notifications for all users: $e');
      throw Exception('Failed to create notifications for all users: $e');
    }
  }

  /// Create a notification for a specific user with expanded content
  static Future<void> createNotificationForUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
    String? expandedContent,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _userNotifications.add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'referenceId': referenceId,
        'expandedContent': expandedContent ?? '',
        'additionalData': additionalData ?? {},
      });

      // Send push notification
      try {
        final userDoc = await _users.doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final firebaseUID = userData['firebaseUID'] as String?;

          if (firebaseUID != null) {
            // Push notification functionality can be added here when available
            debugPrint('📱 Would send push notification to $firebaseUID');
          }
        }
      } catch (e) {
        debugPrint('❌ Failed to send push notification: $e');
      }
    } catch (e) {
      debugPrint('❌ Error creating notification for user: $e');
      throw Exception('Failed to create notification for user: $e');
    }
  }

  /// Create ban period notifications for all users
  static Future<void> createBanPeriodNotifications({
    required String title,
    required String message,
    required String category,
    required String adminName,
    required List<String> actionItems,
  }) async {
    try {
      // Get all user IDs
      final usersSnapshot = await _users.get();
      final List<String> userIds =
          usersSnapshot.docs.map((doc) => doc.id).toList();

      // Create expanded content
      final expandedContent = '''Ban Period Information

Category: $category
Title: $title

Details:
$message

Action Items:
${actionItems.map((item) => '• $item').join('\n')}

Effective Date: ${DateTime.now().toString().split(' ')[0]}''';

      // Create notifications for all users
      final batch = _firestore.batch();
      int notificationsCreated = 0;

      for (String userId in userIds) {
        final notificationRef = _userNotifications.doc();
        batch.set(notificationRef, {
          'userId': userId,
          'title': title,
          'message': message,
          'type': 'ban_period_update',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'expandedContent': expandedContent,
          'additionalData': {
            'category': category,
            'adminName': adminName,
            'actionItems': actionItems,
          },
        });
        notificationsCreated++;
      }

      await batch.commit();
      debugPrint('✅ Created $notificationsCreated ban period notifications');

      // Send push notifications in parallel (non-blocking)
      final List<Future<void>> pushNotificationFutures = [];

      for (String userId in userIds) {
        final userDoc = await _users.doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final firebaseUID = userData['firebaseUID'] as String?;

          if (firebaseUID != null) {
            // Push notification functionality can be added here when available
            debugPrint('📱 Would send push notification to $firebaseUID');
          }
        }
      }

      // Send push notifications in parallel (non-blocking)
      if (pushNotificationFutures.isNotEmpty) {
        Future.wait(pushNotificationFutures).catchError((e) {
          debugPrint('⚠️ Some push notifications failed: $e');
          return <void>[];
        });
        debugPrint(
            '📱 Queued ${pushNotificationFutures.length} push notifications');
      }
    } catch (e) {
      debugPrint('❌ Error creating ban period notifications: $e');
      throw Exception('Failed to create ban period notifications: $e');
    }
  }

  /// Example: Create a marine conditions notification with expanded content
  static Future<void> createMarineConditionsNotification({
    required String userId,
    required String title,
    required String message,
    required String detailedConditions,
    required String safetyRecommendations,
  }) async {
    final expandedContent = '''
🌊 **Detailed Marine Conditions:**

$detailedConditions

⚠️ **Safety Recommendations:**

$safetyRecommendations

📅 **Last Updated:** ${DateTime.now().toString().split(' ')[0]}
''';

    await createNotificationForUser(
      userId: userId,
      title: title,
      message: message,
      type: 'marine_conditions',
      expandedContent: expandedContent,
    );
  }

  /// Example: Create a system announcement with expanded content
  static Future<void> createSystemAnnouncement({
    required String title,
    required String message,
    required String fullAnnouncement,
    required List<String> actionItems,
  }) async {
    final expandedContent = '''
📢 **System Announcement:**

$fullAnnouncement

📋 **Action Items:**
${actionItems.map((item) => '• $item').join('\n')}

📅 **Effective Date:** ${DateTime.now().toString().split(' ')[0]}
''';

    await createNotificationForAllUsers(
      title: title,
      message: message,
      type: 'system_announcement',
      expandedContent: expandedContent,
    );
  }

  /// Create a test notification with expanded content for debugging
  static Future<void> createTestNotificationWithExpandedContent({
    required String userId,
  }) async {
    final expandedContent = '''
🌊 **Detailed Marine Conditions:**

Current wave height: 2.5-3.0 meters
Wind speed: 15-20 knots from the northeast
Water temperature: 24°C
Visibility: Good (10+ km)

⚠️ **Safety Recommendations:**

• Avoid shallow areas near reefs
• Use appropriate safety equipment
• Check weather updates every 2 hours
• Inform someone of your location

📅 **Last Updated:** ${DateTime.now().toString().split(' ')[0]}
''';

    await createNotificationForUser(
      userId: userId,
      title: 'Marine Conditions Update',
      message: 'Current conditions require extra caution',
      type: 'marine_conditions',
      expandedContent: expandedContent,
    );
  }

  /// Notify all users about marine conditions update
  static Future<void> notifyMarineConditionsUpdate({
    required Map<String, dynamic> marineData,
    required String adminName,
  }) async {
    final expandedContent = '''
🌊 **Current Marine Conditions:**

Wave Height: ${marineData['waveHeight'] ?? 'N/A'}
Wind Speed: ${marineData['windSpeed'] ?? 'N/A'}
Water Temperature: ${marineData['waterTemperature'] ?? 'N/A'}
Visibility: ${marineData['visibility'] ?? 'N/A'}

⚠️ **Safety Recommendations:**

${marineData['safetyRecommendations'] ?? 'Please exercise caution and follow standard safety protocols.'}

📅 **Updated by:** $adminName
🕒 **Last Updated:** ${DateTime.now().toString().split(' ')[0]}
''';

    await createNotificationForAllUsers(
      title: 'Marine Conditions Update',
      message: 'Marine conditions have been updated',
      type: 'marine_conditions',
      expandedContent: expandedContent,
    );
  }

  /// Notify all users about new education content
  static Future<void> notifyNewEducationContent({
    required String category,
    required String title,
    required String adminName,
  }) async {
    debugPrint('🔔 [USER NOTIFICATION SERVICE] notifyNewEducationContent called');
    debugPrint('   Category: $category');
    debugPrint('   Title: $title');
    debugPrint('   Admin: $adminName');
    
    final expandedContent = '''New Educational Content Available

Category: $category
Title: $title

What's New:
Fresh educational content has been added to help you learn more about marine conservation and ocean education.

How to Access:
Visit the Ocean Education section in your dashboard to explore the new content.

Added by: $adminName
Published: ${DateTime.now().toString().split(' ')[0]}''';

    try {
      await createNotificationForAllUsers(
        title: 'New Education Content',
        message: 'New $category content has been added: $title',
        type: 'education_content',
        expandedContent: expandedContent,
      );
      debugPrint('✅ [USER NOTIFICATION SERVICE] Education notifications created successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [USER NOTIFICATION SERVICE] Error creating education notifications: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Notify user about complaint status update
  static Future<void> notifyComplaintStatusUpdate({
    required String userId,
    required String complaintId,
    required String status,
  }) async {
    // Customize message based on status
    String title;
    String message;
    String statusDescription;
    
    switch (status.toLowerCase()) {
      case 'resolved':
        title = 'Report Resolved';
        message = 'Your report has been resolved by the authority.';
        statusDescription = 'Your report has been successfully resolved and the issue has been addressed.';
        break;
      case 'in progress':
        title = 'Report In Progress';
        message = 'Your report is now being investigated.';
        statusDescription = 'The authority has started investigating your report. You will be notified of any updates.';
        break;
      case 'pending':
        title = 'Report Status Updated';
        message = 'Your report status has been updated to Pending.';
        statusDescription = 'Your report is pending review by the authority.';
        break;
      default:
        title = 'Report Status Updated';
        message = 'Your report status has been updated to $status.';
        statusDescription = 'Your report has been reviewed and its status has been updated.';
    }
    
    final expandedContent = '''
📋 **Report Status Update:**

**Report ID:** $complaintId
**New Status:** $status

📝 **What This Means:**
$statusDescription

You can view the full details in your reports section.

📅 **Updated:** ${DateTime.now().toString().split(' ')[0]}
''';

    await createNotificationForUser(
      userId: userId,
      title: title,
      message: message,
      type: 'complaint_status',
      referenceId: complaintId,
      expandedContent: expandedContent,
      additionalData: {
        'reportId': complaintId,
        'status': status,
      },
    );
  }

  /// Notify all users about ban period update
  static Future<void> notifyBanPeriodUpdate({
    required DateTime startDate,
    required DateTime endDate,
    required String? adminName,
  }) async {
    final title = 'Ban Period Update';
    final message =
        'A new ban period has been announced from ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}';
    final category = 'Ban Period';
    final actionItems = [
      'Review the ban period details',
      'Check affected areas',
      'Plan activities accordingly',
      'Stay updated with any changes',
    ];

    await createBanPeriodNotifications(
      title: title,
      message: message,
      category: category,
      adminName: adminName ?? 'Administrator',
      actionItems: actionItems,
    );
  }

  /// Test ban period notification
  static Future<void> testBanPeriodNotification() async {
    await createBanPeriodNotifications(
      title: 'Test Ban Period Notification',
      message: 'This is a test notification for ban period updates',
      category: 'Test Category',
      adminName: 'System',
      actionItems: [
        'Review the notification',
        'Test the expansion functionality',
        'Verify all features work correctly',
      ],
    );
  }
}
