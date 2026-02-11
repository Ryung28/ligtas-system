import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardFirestore {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final DashboardFirestore _instance = DashboardFirestore._internal();

  factory DashboardFirestore() {
    return _instance;
  }

  DashboardFirestore._internal();

  Future<String> getUserName() async {
    try {
      User? user = _auth.currentUser;
      print('Current User ID: ${user?.uid}');

      if (user != null) {
        // First try to find user by Firebase UID
        var userQuery = await _firestore
            .collection('users')
            .where('firebaseUID', isEqualTo: user.uid)
            .get();

        print('Query results count: ${userQuery.docs.length}');

        DocumentSnapshot? userDoc;
        if (userQuery.docs.isNotEmpty) {
          userDoc = userQuery.docs.first;
        } else {
          // Try to find by email
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();
              
          if (userQuery.docs.isNotEmpty) {
            userDoc = userQuery.docs.first;
          }
        }

        if (userDoc != null) {
          final userData = userDoc.data() as Map<String, dynamic>;
          print('Found user data: $userData');

          String displayName = '';
          
          // Try displayName first
          if (userData['displayName'] != null) {
            displayName = userData['displayName'].toString();
          }
          
          // Then try firstName + lastName
          if (displayName.isEmpty) {
            final firstName = userData['firstName']?.toString() ?? '';
            final lastName = userData['lastName']?.toString() ?? '';
            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              displayName = '$firstName $lastName'.trim();
            }
          }
          
          // Finally try username
          if (displayName.isEmpty && userData['username'] != null) {
            displayName = userData['username'].toString();
          }

          return displayName.isNotEmpty ? displayName : 'User';
        }
      }
      
      print('No user data found, returning default name');
      return 'User';
    } catch (e) {
      print('Error in getUserName: $e');
      return 'User';
    }
  }

  Future<String?> getUserPhotoUrl() async {
    try {
      User? user = _auth.currentUser;
      print('Getting photo URL for user: ${user?.uid}');
      
      if (user != null) {
        print('Fetching user document from Firestore...');
        var userQuery = await _firestore
            .collection('users')
            .where('firebaseUID', isEqualTo: user.uid)
            .get();

        if (userQuery.docs.isEmpty) {
          print('No user found by firebaseUID, trying email lookup');
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          
          // Try photoURL first
          final photoUrl = userData['photoURL'];
          if (photoUrl != null && photoUrl.toString().isNotEmpty) {
            print('Found photoURL in Firestore: $photoUrl');
            return photoUrl.toString();
          }
          
          if (user.photoURL != null && user.photoURL!.isNotEmpty) {
            print('Using Firebase Auth photoURL: ${user.photoURL}');
            return user.photoURL;
          }
        }
        
        print('No photo URL found, using default avatar');
        return 'https://www.gravatar.com/avatar/${user.uid}?d=identicon';
      }
      print('No authenticated user found');
      return null;
    } catch (e) {
      print('Error getting user photo URL: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      print('Getting user data for ID: ${user?.uid}');
      
      if (user != null) {
        // Try firebaseUID first
        var userQuery = await _firestore
            .collection('users')
            .where('firebaseUID', isEqualTo: user.uid)
            .get();

        if (userQuery.docs.isEmpty) {
          // Try email as fallback
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          print('Full user data: $userData');
          
          // Ensure all required fields are present
          return {
            ...userData,
            'displayName': userData['displayName'] ?? '',
            'email': userData['email'] ?? '',
            'photoURL': userData['photoURL'] ?? '',
            'firebaseUID': userData['firebaseUID'] ?? user.uid,
          };
        }
      }
      return null;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  bool isUserLoggedIn() {
    final user = _auth.currentUser;
    print('Is user logged in: ${user != null}');
    return user != null;
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}