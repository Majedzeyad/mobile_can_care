import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service for fetching user data from Firestore
/// This is the ONLY source of truth for user data after authentication
class FirestoreService {
  static FirestoreService? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._();

  static FirestoreService get instance {
    _instance ??= FirestoreService._();
    return _instance!;
  }

  /// Fetch user document from Firestore using UID
  /// Returns null if user document doesn't exist
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      print('Fetching user document from Firestore for UID: $uid');
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (!docSnapshot.exists) {
        print('User document does not exist in Firestore for UID: $uid');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('User document exists but data is null for UID: $uid');
        return null;
      }

      print('User document fetched successfully for UID: $uid');
      return UserModel.fromJson(data, uid);
    } catch (e, stackTrace) {
      print('ERROR fetching user from Firestore for UID $uid: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      print('Getting user role for UID: $uid');
      final user = await getUserByUid(uid);
      final role = user?.activeRole;
      print('User role retrieved: $role for UID: $uid');
      return role;
    } catch (e, stackTrace) {
      print('ERROR fetching user role for UID $uid: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}

