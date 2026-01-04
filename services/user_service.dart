import '../models/user_model.dart';
import 'firestore_service.dart';

/// UserService - Provides user data operations
/// Delegates to FirestoreService for all data operations
/// This service acts as a convenience wrapper around FirestoreService
class UserService {
  static UserService? _instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  UserService._();

  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  /// Get user by UID from Firestore
  Future<UserModel?> getUserByUid(String uid) async {
    return await _firestoreService.getUserByUid(uid);
  }

  /// Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    return await _firestoreService.getUserRole(uid);
  }
}

