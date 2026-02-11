import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admin_notification_service.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/user_notification_service.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/services/activity_recorder.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _complaints =
      _firestore.collection('complaints');
  static final CollectionReference _counters =
      _firestore.collection('counters');
  static final CollectionReference _userNotifications =
      _firestore.collection('user_notifications');

  // Professional report numbering system
  static Future<String> _getNextReportNumber() async {
    final int currentYear = DateTime.now().year;
    final String yearString = currentYear.toString();
    final String departmentCode = 'MG'; // Marine Guard
    final String counterKey = 'reports_$yearString';

    final DocumentReference counterDoc = _counters.doc(counterKey);

    try {
      return await _firestore.runTransaction<String>((transaction) async {
        final snapshot = await transaction.get(counterDoc);

        final int currentCount = snapshot.exists
            ? (snapshot.data() as Map<String, dynamic>)['count'] ?? 0
            : 0;
        final int nextCount = currentCount + 1;

        transaction.set(
            counterDoc,
            {
              'count': nextCount,
              'year': currentYear,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));

        // Format: YYYY + Department + Sequential (3 digits)
        final String sequentialNumber = nextCount.toString().padLeft(3, '0');
        return '$yearString$departmentCode$sequentialNumber';
      });
    } catch (e) {
      throw Exception('Failed to generate report number: $e');
    }
  }

  // Create a new complaint/report with professional ID
  static Future<String> createComplaint({
    required String name,
    required DateTime dateOfBirth,
    required String phone,
    required String email,
    required String address,
    required String complaint,
    required List<String> attachedFiles,
    Map<String, double>? location,
  }) async {
    try {
      final String reportNumber = await _getNextReportNumber();
      final String documentId =
          reportNumber; // Use professional report number as document ID

      // Get current user ID for notifications
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid ?? '';

      await _complaints.doc(documentId).set({
        'reportId': documentId,
        'reportNumber': reportNumber, // Professional report number
        'userId': userId, // Add userId for notification purposes
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'email': email,
        'phone': phone,
        'address': address,
        'complaint': complaint,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
        'attachedFiles': attachedFiles,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'year': DateTime.now().year,
        'department': 'MG', // Marine Guard
        'location': location,
      });

      // Create notification for admin
      await AdminNotificationService.createNotification(
        title: 'New Complaint Submitted',
        message: 'A new complaint has been submitted by $name',
        type: 'complaint',
        referenceId: documentId,
      );

      // Create notification for the user confirming report submission
      if (userId.isNotEmpty) {
        try {
          final expandedContent = '''
📋 **Report Submission Confirmation**

**Report Number:** $reportNumber
**Status:** Pending Review

Your report has been successfully submitted and received by the authorities. 

Please wait for the authority to review and update your report. You will be notified when there are any status updates.

**Submitted:** ${DateTime.now().toString().split(' ')[0]}
''';

          await UserNotificationService.createNotificationForUser(
            userId: userId,
            title: 'Report Sent Successfully',
            message: 'Report sent. Please wait for authority for the update.',
            type: 'report_submission',
            referenceId: documentId,
            expandedContent: expandedContent,
            additionalData: {
              'reportNumber': reportNumber,
              'status': 'Pending',
            },
          );
          debugPrint('✅ Created user notification for report submission: $documentId');
        } catch (e) {
          debugPrint('⚠️ Failed to create user notification for report: $e');
          // Don't throw - user notification is not critical for report submission
        }
      }

      // Record activity for recent activities section and bell notifications
      try {
        await ActivityRecorder.recordComplaintSubmission(
          userId: userId,
          userName: name,
          complaintTitle: complaint,
          complaintId: documentId,
        );
        debugPrint('✅ Complaint submission activity recorded');
      } catch (e) {
        debugPrint('⚠️ Failed to record complaint submission activity: $e');
        // Don't throw - activity recording is not critical for complaint submission
      }

      return documentId;
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  // Initialize counter if it doesn't exist
  static Future<void> initializeCounter() async {
    try {
      final DocumentReference counterDoc = _counters.doc('complaints');

      final snapshot = await counterDoc.get();

      if (!snapshot.exists) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists && (userDoc.data()?['isAdmin'] == true)) {
            await counterDoc.set({
              'count': 0,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    } catch (e) {
      // Add more detailed error logging
      if (e is FirebaseException) {}
    }
  }

  // Get all reports (for admin) with professional ordering
  static Stream<QuerySnapshot> getComplaints() {
    return _complaints
        .orderBy('year', descending: true)
        .orderBy('reportNumber', descending: true)
        .snapshots();
  }

  // Get reports for a specific user with professional ordering
  static Stream<QuerySnapshot> getUserComplaints(String email) {
    return _complaints
        .where('email', isEqualTo: email)
        .orderBy('year', descending: true)
        .orderBy('reportNumber', descending: true)
        .snapshots();
  }

  // Update complaint status
  static Future<void> updateComplaintStatus(
      String complaintId, String newStatus) async {
    try {
      // Get the complaint data first
      final complaintDoc = await _complaints.doc(complaintId).get();
      final complaintData = complaintDoc.data() as Map<String, dynamic>;
      final userId = complaintData['userId'] as String?;
      final userName = complaintData['name'] as String?;

      // Update the complaint status
      await _complaints.doc(complaintId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for the user if userId exists
      if (userId != null && userId.isNotEmpty) {
        try {
          await UserNotificationService.notifyComplaintStatusUpdate(
            userId: userId,
            complaintId: complaintId,
            status: newStatus,
          );
          debugPrint('✅ Sent complaint status notification to user $userId');
        } catch (e) {
          debugPrint('❌ Failed to send complaint notification: $e');
          // Fallback to old method if new service fails
          await _userNotifications.add({
            'userId': userId,
            'title': 'Complaint Status Updated',
            'message':
                'Your complaint (ID: $complaintId) has been updated to: $newStatus',
            'type': 'complaint_status',
            'complaintId': complaintId,
            'status': newStatus,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        debugPrint(
            '⚠️ No userId found for complaint $complaintId, skipping user notification');
      }

      // Create notification for admin
      await AdminNotificationService.createNotification(
        title: 'Status Updated',
        message:
            'Complaint status for $userName has been updated to $newStatus',
        type: 'status_update',
        referenceId: complaintId,
      );
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  // Get user notifications stream
  // 🔥 FIX: Removed orderBy to avoid Firestore index requirement - sorting done in memory
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    // Query without orderBy to avoid requiring a composite index
    // Sorting will be done in memory by the notification bell widget
    return _userNotifications
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Mark user notification as read
  static Future<void> markUserNotificationAsRead(String notificationId) async {
    try {
      await _userNotifications.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Delete user notification
  static Future<void> deleteUserNotification(String notificationId) async {
    try {
      await _userNotifications.doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Get unread user notifications count
  // Composite index needed: user_notifications (userId ASC, isRead ASC)
  static Stream<int> getUnreadUserNotificationsCount(String userId) {
    return _userNotifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete report
  static Future<void> deleteComplaint(String reportId) async {
    try {
      await _complaints.doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Get report statistics
  static Future<Map<String, dynamic>> getComplaintStatistics() async {
    try {
      final QuerySnapshot snapshot = await _complaints.get();
      final total = snapshot.size;

      final pendingQuery =
          await _complaints.where('status', isEqualTo: 'Pending').get();
      final inProgressQuery =
          await _complaints.where('status', isEqualTo: 'In Progress').get();
      final resolvedQuery =
          await _complaints.where('status', isEqualTo: 'Resolved').get();

      return {
        'total': total,
        'pending': pendingQuery.size,
        'inProgress': inProgressQuery.size,
        'resolved': resolvedQuery.size,
      };
    } catch (e) {
      throw Exception('Failed to get report statistics: $e');
    }
  }
}
