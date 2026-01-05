import 'package:firebase_auth/firebase_auth.dart';

/// Service for Firebase Authentication operations
/// This is the ONLY source of truth for authentication
class AuthService {
  static AuthService? _instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create new user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

