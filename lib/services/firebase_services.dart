import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/nurse_model.dart';
import '../models/patient_model.dart';
import '../models/lab_test_request_model.dart';
import '../models/lab_result_model.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';
import '../models/override_request_model.dart';
import '../models/post_model.dart';
import '../models/group_chat_model.dart';
import '../models/group_chat_message_model.dart';
import 'sample_data_loader.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CENTRALIZED FIREBASE SERVICES
/// ═══════════════════════════════════════════════════════════════════════════
///
/// This service centralizes ALL Firebase operations in one place.
/// It replaces all direct Firebase calls throughout the application.
///
/// **Architecture Benefits:**
/// - Single source of truth for all Firebase operations
/// - Easier testing and mocking
/// - Consistent error handling
/// - Better code organization and maintainability
/// - Centralized logging and analytics
/// - Easier Firebase SDK updates
///
/// **Usage Pattern:**
/// ```dart
/// // Before (scattered throughout app):
/// await FirebaseAuth.instance.signInWithEmailAndPassword(...);
/// await FirebaseFirestore.instance.collection('users').doc(uid).get();
///
/// // After (centralized):
/// await FirebaseServices().signInWithEmail(...);
/// await FirebaseServices().getUserProfile(uid);
/// ```
///
/// **Service Organization:**
/// 1. Authentication Services
/// 2. User Profile Services
/// 3. Doctor Services
/// 4. Nurse Services
/// 5. Patient Services
/// 6. Responsible Party Services
/// 7. Shared Medical Services (Lab Results, Prescriptions, Medical Records)
/// 8. Utility Methods
///
/// ═══════════════════════════════════════════════════════════════════════════

class FirebaseServices {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SINGLETON PATTERN
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static FirebaseServices? _instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Private constructor for singleton pattern
  FirebaseServices._();

  /// Get singleton instance
  static FirebaseServices get instance {
    _instance ??= FirebaseServices._();
    return _instance!;
  }

  /// Factory constructor (alternative access method)
  factory FirebaseServices() => instance;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. AUTHENTICATION SERVICES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get currently authenticated Firebase user
  ///
  /// **Returns:** Current [User] object or null if not authenticated
  ///
  /// **Usage:**
  /// ```dart
  /// final user = FirebaseServices().currentUser;
  /// if (user != null) {
  ///   print('Logged in as: ${user.email}');
  /// }
  /// ```
  User? get currentUser => _auth.currentUser;

  /// Get current user's UID
  ///
  /// **Returns:** User ID string or null if not authenticated
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of authentication state changes
  ///
  /// **Returns:** Stream that emits [User] or null on auth state changes
  ///
  /// **Usage:**
  /// ```dart
  /// FirebaseServices().authStateChanges.listen((user) {
  ///   if (user == null) {
  ///     // User is signed out
  ///   } else {
  ///     // User is signed in
  ///   }
  /// });
  /// ```
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  ///
  /// **Parameters:**
  /// - [email]: User's email address (will be trimmed)
  /// - [password]: User's password
  ///
  /// **Returns:** [UserCredential] containing user info and auth tokens
  ///
  /// **Throws:**
  /// - [FirebaseAuthException] for various auth errors:
  ///   - `user-not-found`: No user with this email
  ///   - `wrong-password`: Incorrect password
  ///   - `invalid-email`: Invalid email format
  ///   - `user-disabled`: Account has been disabled
  ///
  /// **Usage:**
  /// ```dart
  /// try {
  ///   final credential = await FirebaseServices().signInWithEmail(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   print('Signed in: ${credential.user?.email}');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Error: ${e.message}');
  /// }
  /// ```
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create new user account with email and password
  ///
  /// **Parameters:**
  /// - [email]: New user's email address (will be trimmed)
  /// - [password]: Password for the account (minimum 6 characters)
  ///
  /// **Returns:** [UserCredential] for the newly created account
  ///
  /// **Throws:**
  /// - [FirebaseAuthException]:
  ///   - `email-already-in-use`: Email is already registered
  ///   - `weak-password`: Password is too weak
  ///   - `invalid-email`: Invalid email format
  ///
  /// **Usage:**
  /// ```dart
  /// try {
  ///   final credential = await FirebaseServices().createAccount(
  ///     email: 'newuser@example.com',
  ///     password: 'SecurePass123',
  ///   );
  ///   // Create user profile in Firestore after this
  /// } catch (e) {
  ///   print('Signup failed: $e');
  /// }
  /// ```
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out current user
  ///
  /// **Returns:** Future that completes when sign out is successful
  ///
  /// **Usage:**
  /// ```dart
  /// await FirebaseServices().signOut();
  /// // Navigate to login page after this
  /// ```
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  ///
  /// **Parameters:**
  /// - [email]: Email address to send reset link to
  ///
  /// **Throws:**
  /// - [FirebaseAuthException]:
  ///   - `user-not-found`: No account with this email
  ///   - `invalid-email`: Invalid email format
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. USER PROFILE SERVICES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get user profile from Firestore
  ///
  /// **Parameters:**
  /// - [uid]: User ID to fetch profile for
  ///
  /// **Returns:** [UserModel] or null if not found
  ///
  /// **Usage:**
  /// ```dart
  /// final user = await FirebaseServices().getUserProfile('user123');
  /// if (user != null) {
  ///   print('Role: ${user.activeRole}');
  /// }
  /// ```
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      print('[FirebaseServices] Fetching user profile for UID: $uid');
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists) {
        print('[FirebaseServices] User document not found for UID: $uid');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('[FirebaseServices] User document data is null for UID: $uid');
        return null;
      }

      print(
        '[FirebaseServices] User profile fetched successfully for UID: $uid',
      );
      return UserModel.fromJson(data, uid);
    } catch (e, stackTrace) {
      print('[FirebaseServices] ERROR fetching user profile for UID $uid: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get user's active role
  ///
  /// **Parameters:**
  /// - [uid]: User ID
  ///
  /// **Returns:** Role string ('doctor', 'nurse', 'patient', 'responsible') or null
  ///
  /// **Usage:**
  /// ```dart
  /// final role = await FirebaseServices().getUserRole('user123');
  /// // Navigate to appropriate dashboard based on role
  /// ```
  Future<String?> getUserRole(String uid) async {
    try {
      print('[FirebaseServices] Getting user role for UID: $uid');
      final user = await getUserProfile(uid);
      final role = user?.activeRole;
      print('[FirebaseServices] User role: $role');
      return role;
    } catch (e) {
      print('[FirebaseServices] ERROR fetching user role for UID $uid: $e');
      return null;
    }
  }

  /// Create or update user profile in Firestore
  ///
  /// **Parameters:**
  /// - [uid]: User ID
  /// - [data]: Map of user data to save
  ///
  /// **Usage:**
  /// ```dart
  /// await FirebaseServices().saveUserProfile('user123', {
  ///   'email': 'user@example.com',
  ///   'activeRole': 'patient',
  ///   'profile': {'name': 'John Doe'},
  /// });
  /// ```
  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. DOCTOR SERVICES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get doctor profile from 'doctors' collection
  ///
  /// **Parameters:**
  /// - [doctorId]: Doctor's UID (defaults to current user)
  ///
  /// **Returns:** [DoctorModel] or null if not found
  Future<DoctorModel?> getDoctorProfile([String? doctorId]) async {
    try {
      doctorId ??= currentUserId;
      if (doctorId == null) return null;

      // Try querying by uid field
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('uid', isEqualTo: doctorId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return DoctorModel.fromJson(doc.data(), doc.id);
      }

      // Try direct document access
      final docSnapshot = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return DoctorModel.fromJson(docSnapshot.data()!, doctorId);
      }

      return null;
    } catch (e) {
      print('[FirebaseServices] Error fetching doctor profile: $e');
      return null;
    }
  }

  /// Get dashboard statistics for doctor
  ///
  /// **Returns:** Map with 'activePatients', 'pendingLabTests', 'recentPrescriptions'
  Future<Map<String, int>> getDoctorDashboardStats([String? doctorId]) async {
    try {
      doctorId ??= currentUserId;
      if (doctorId == null) {
        return {
          'activePatients': 0,
          'pendingLabTests': 0,
          'recentPrescriptions': 0,
        };
      }

      // Count active patients
      final patientsSnapshot = await _firestore
          .collection('patients')
          .where('assignedDoctorId', isEqualTo: doctorId)
          .get();

      // Count pending lab tests
      final pendingLabTestsSnapshot = await _firestore
          .collection('mobile_lab_test_requests')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'pending')
          .get();

      // Count recent prescriptions (last 7 days)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final prescriptionsSnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('doctorId', isEqualTo: doctorId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
          )
          .get();

      return {
        'activePatients': patientsSnapshot.docs.length,
        'pendingLabTests': pendingLabTestsSnapshot.docs.length,
        'recentPrescriptions': prescriptionsSnapshot.docs.length,
      };
    } catch (e) {
      print('[FirebaseServices] Error fetching doctor dashboard stats: $e');
      return {
        'activePatients': 0,
        'pendingLabTests': 0,
        'recentPrescriptions': 0,
      };
    }
  }

  /// Get all patients assigned to a doctor
  ///
  /// **Returns:** List of patient data maps
  Future<List<Map<String, dynamic>>> getDoctorPatients([
    String? doctorId,
  ]) async {
    try {
      doctorId ??= currentUserId;
      if (doctorId == null) return [];

      final snapshot = await _firestore
          .collection('patients')
          .where('assignedDoctorId', isEqualTo: doctorId)
          .get();

      return snapshot.docs.map((doc) {
        final patient = PatientModel.fromJson(doc.data(), doc.id);
        return {
          'id': patient.id,
          'name': patient.name ?? 'Unknown',
          'diagnosis': patient.diagnosis ?? 'No diagnosis',
          'age': patient.dob != null ? _calculateAge(patient.dob!) : null,
        };
      }).toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching doctor patients: $e');
      return [];
    }
  }

  /// Get pending lab test requests for doctor
  Future<List<Map<String, dynamic>>> getDoctorPendingLabRequests([
    String? doctorId,
  ]) async {
    try {
      doctorId ??= currentUserId;
      if (doctorId == null) return [];

      QuerySnapshot snapshot;
      try {
        // Try with orderBy first
        snapshot = await _firestore
            .collection('mobile_lab_test_requests')
            .where('doctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If index error, try without orderBy
        if (e.toString().contains('index') ||
            e.toString().contains('FAILED_PRECONDITION')) {
          print(
            '[FirebaseServices] Index required for lab requests, fetching without orderBy...',
          );
          snapshot = await _firestore
              .collection('mobile_lab_test_requests')
              .where('doctorId', isEqualTo: doctorId)
              .where('status', isEqualTo: 'pending')
              .get();
        } else {
          rethrow;
        }
      }

      final results = snapshot.docs.map((doc) {
        final request = LabTestRequestModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        return {
          'id': request.id,
          'patientName': request.patientName ?? 'Unknown',
          'formattedDate': request.createdAt != null
              ? '${request.createdAt!.day}/${request.createdAt!.month}/${request.createdAt!.year}'
              : 'Unknown',
          'createdAt': request.createdAt, // For sorting
        };
      }).toList();

      // Sort by date if not already sorted
      results.sort((a, b) {
        final dateA = a['createdAt'] as DateTime?;
        final dateB = b['createdAt'] as DateTime?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      return results.map((r) {
        final result = Map<String, dynamic>.from(r);
        result.remove('createdAt'); // Remove sorting field
        return result;
      }).toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching pending lab requests: $e');
      return [];
    }
  }

  /// Create lab test request
  ///
  /// **Parameters:**
  /// - [patientId]: Patient ID
  /// - [patientName]: Patient name
  /// - [testType]: Type of test
  /// - [test]: Specific test name
  /// - [urgency]: Test urgency level (optional, defaults to 'normal')
  /// - [notes]: Additional notes (optional)
  /// - [doctorId]: Doctor ID (optional, defaults to current user)
  Future<void> createLabTestRequest({
    required String patientId,
    required String patientName,
    required String testType,
    required String test,
    String urgency = 'normal',
    String? notes,
    String? doctorId,
  }) async {
    doctorId ??= currentUserId;
    if (doctorId == null) throw Exception('No user logged in');

    await _firestore.collection('mobile_lab_test_requests').add({
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'testType': testType,
      'test': test,
      'urgency': urgency,
      'notes': notes ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get lab results for doctor
  ///
  /// **Parameters:**
  /// - [doctorId]: Doctor ID (optional, defaults to current user)
  ///
  /// **Returns:** List of lab result data maps with patient information
  Future<List<Map<String, dynamic>>> getDoctorLabResults([
    String? doctorId,
  ]) async {
    try {
      doctorId ??= currentUserId;
      if (doctorId == null) return [];

      // Try to get results directly by doctorId first
      QuerySnapshot resultsSnapshot;
      try {
        resultsSnapshot = await _firestore
            .collection('mobile_lab_results')
            .where('doctorId', isEqualTo: doctorId)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If index error, try without orderBy
        if (e.toString().contains('index') ||
            e.toString().contains('FAILED_PRECONDITION')) {
          print(
            '[FirebaseServices] Index required, fetching without orderBy...',
          );
          resultsSnapshot = await _firestore
              .collection('mobile_lab_results')
              .where('doctorId', isEqualTo: doctorId)
              .get();
        } else {
          rethrow;
        }
      }

      final results = <Map<String, dynamic>>[];

      for (var doc in resultsSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final result = LabResultModel.fromJson(data, doc.id);

          // Get patient name
          String patientName = 'غير معروف';
          if (result.patientId != null) {
            try {
              final patientDoc = await _firestore
                  .collection('patients')
                  .doc(result.patientId!)
                  .get();
              if (patientDoc.exists) {
                patientName =
                    patientDoc.data()?['name'] as String? ?? 'غير معروف';
              }
            } catch (e) {
              print('[FirebaseServices] Error fetching patient name: $e');
            }
          }

          results.add({
            'id': result.id,
            'testName': result.testName ?? result.testType ?? 'تحليل غير محدد',
            'date': result.createdAt != null
                ? '${result.createdAt!.day}/${result.createdAt!.month}/${result.createdAt!.year}'
                : 'غير متوفر',
            'status': result.status == 'completed' ? 'مكتمل' : 'قيد الانتظار',
            'patientName': patientName,
            'patientId': result.patientId,
            'doctorNotes': result.doctorNotes,
            'results': result.results,
            'createdAt': result.createdAt,
          });
        } catch (e) {
          print('[FirebaseServices] Error parsing lab result: $e');
        }
      }

      // Sort by date if not already sorted
      results.sort((a, b) {
        final dateA = a['createdAt'] as DateTime?;
        final dateB = b['createdAt'] as DateTime?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      return results;
    } catch (e) {
      print('[FirebaseServices] Error fetching doctor lab results: $e');
      return [];
    }
  }

  /// Add doctor notes to lab result
  ///
  /// **Parameters:**
  /// - [resultId]: Lab result document ID
  /// - [notes]: Doctor's notes to add
  /// - [doctorId]: Doctor ID (optional, defaults to current user)
  Future<void> addDoctorNotesToLabResult(
    String resultId,
    String notes, [
    String? doctorId,
  ]) async {
    doctorId ??= currentUserId;
    if (doctorId == null) throw Exception('No doctor logged in');

    await _firestore.collection('mobile_lab_results').doc(resultId).update({
      'doctorNotes': notes,
      'notesAddedBy': doctorId,
      'notesAddedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get medical records created by doctor
  Future<List<Map<String, dynamic>>> getDoctorMedicalRecords([
    String? doctorId,
  ]) async {
    try {
      doctorId ??= currentUserId;
      if (doctorId == null) return [];

      // Try query with orderBy first
      try {
        final snapshot = await _firestore
            .collection('mobile_medical_records')
            .where('doctorId', isEqualTo: doctorId)
            .orderBy('createdAt', descending: true)
            .get();

        return snapshot.docs.map((doc) {
          final record = MedicalRecordModel.fromJson(doc.data(), doc.id);
          return {
            'id': record.id,
            'category': record.category ?? 'Unknown',
            'description': record.description ?? 'No description',
            'patientId': record.patientId,
            'createdAt': record.createdAt,
          };
        }).toList();
      } catch (e) {
        // If index error, fetch without orderBy and sort in code
        if (e.toString().contains('index') ||
            e.toString().contains('FAILED_PRECONDITION')) {
          print(
            '[FirebaseServices] Index required for medical records, fetching without orderBy...',
          );
          try {
            final snapshot = await _firestore
                .collection('mobile_medical_records')
                .where('doctorId', isEqualTo: doctorId)
                .get();

            final records = snapshot.docs.map((doc) {
              final record = MedicalRecordModel.fromJson(doc.data(), doc.id);
              return {
                'id': record.id,
                'category': record.category ?? 'Unknown',
                'description': record.description ?? 'No description',
                'patientId': record.patientId,
                'createdAt': record.createdAt,
              };
            }).toList();

            // Sort by createdAt descending in code
            records.sort((a, b) {
              final dateA = a['createdAt'] as DateTime?;
              final dateB = b['createdAt'] as DateTime?;
              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;
              return dateB.compareTo(dateA);
            });

            return records;
          } catch (e2) {
            print(
              '[FirebaseServices] Error in alternative medical records method: $e2',
            );
            return [];
          }
        } else {
          // Re-throw if it's not an index error
          rethrow;
        }
      }
    } catch (e) {
      print('[FirebaseServices] Error fetching doctor medical records: $e');
      return [];
    }
  }

  /// Get all medications from catalog
  ///
  /// **Returns:** List of medication data maps
  Future<List<Map<String, dynamic>>> getAllMedications() async {
    try {
      final snapshot = await _firestore
          .collection('medications')
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Unknown',
          'dosage': data['dosage'] as String? ?? 'No dosage info',
          'category': data['category'] as String? ?? 'غير محدد',
        };
      }).toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching medications: $e');
      return [];
    }
  }

  /// Create medication order
  ///
  /// **Parameters:**
  /// - [medicationId]: ID of medication from catalog
  /// - [medicationName]: Name of medication
  /// - [doctorId]: Doctor ID (optional, defaults to current user)
  Future<void> createMedicationOrder(
    String medicationId,
    String medicationName, [
    String? doctorId,
  ]) async {
    doctorId ??= currentUserId;
    if (doctorId == null) throw Exception('No doctor logged in');

    await _firestore.collection('mobile_medication_orders').add({
      'doctorId': doctorId,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get pending override requests for doctor
  ///
  /// **Returns:** List of override request data with nurse information
  Future<List<Map<String, dynamic>>> getDoctorPendingOverrideRequests([
    String? doctorId,
  ]) async {
    try {
      doctorId ??= currentUserId;
      if (doctorId == null) return [];

      QuerySnapshot snapshot;
      try {
        // Try with orderBy first
        snapshot = await _firestore
            .collection('mobile_override_requests')
            .where('doctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If index error, try without orderBy
        if (e.toString().contains('index') ||
            e.toString().contains('FAILED_PRECONDITION')) {
          print(
            '[FirebaseServices] Index required for override requests, fetching without orderBy...',
          );
          snapshot = await _firestore
              .collection('mobile_override_requests')
              .where('doctorId', isEqualTo: doctorId)
              .where('status', isEqualTo: 'pending')
              .get();
        } else {
          rethrow;
        }
      }

      final requests = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final request = OverrideRequestModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        // Get nurse name
        String nurseName = 'Unknown Nurse';
        if (request.nurseId != null) {
          try {
            final nurseDoc = await _firestore
                .collection('nurses')
                .doc(request.nurseId!)
                .get();
            if (nurseDoc.exists) {
              nurseName =
                  nurseDoc.data()?['name'] as String? ?? 'Unknown Nurse';
            }
          } catch (e) {
            print('[FirebaseServices] Error fetching nurse name: $e');
          }
        }

        requests.add({
          'id': request.id,
          'nurseName': nurseName,
          'description': request.reason ?? 'No description',
          'formattedDate': request.createdAt != null
              ? '${request.createdAt!.day}/${request.createdAt!.month}/${request.createdAt!.year}'
              : 'Unknown',
          'createdAt': request.createdAt, // For sorting
        });
      }

      // Sort by date if not already sorted
      requests.sort((a, b) {
        final dateA = a['createdAt'] as DateTime?;
        final dateB = b['createdAt'] as DateTime?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      // Remove sorting field from results
      return requests.map((r) {
        final result = Map<String, dynamic>.from(r);
        result.remove('createdAt');
        return result;
      }).toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching override requests: $e');
      return [];
    }
  }

  /// Approve override request
  ///
  /// **Parameters:**
  /// - [requestId]: Override request document ID
  /// - [doctorId]: Doctor ID (optional, defaults to current user)
  Future<void> approveOverrideRequest(
    String requestId, [
    String? doctorId,
  ]) async {
    doctorId ??= currentUserId;
    if (doctorId == null) throw Exception('No doctor logged in');

    await _firestore
        .collection('mobile_override_requests')
        .doc(requestId)
        .update({
          'status': 'approved',
          'approvedBy': doctorId,
          'approvedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Reject override request
  ///
  /// **Parameters:**
  /// - [requestId]: Override request document ID
  /// - [doctorId]: Doctor ID (optional, defaults to current user)
  Future<void> rejectOverrideRequest(
    String requestId, [
    String? doctorId,
  ]) async {
    doctorId ??= currentUserId;
    if (doctorId == null) throw Exception('No doctor logged in');

    await _firestore
        .collection('mobile_override_requests')
        .doc(requestId)
        .update({
          'status': 'rejected',
          'rejectedBy': doctorId,
          'rejectedAt': FieldValue.serverTimestamp(),
        });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. NURSE SERVICES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get nurse profile from 'nurses' collection
  ///
  /// **Parameters:**
  /// - [nurseId]: Nurse's UID (defaults to current user)
  ///
  /// **Returns:** [NurseModel] or null if not found
  Future<NurseModel?> getNurseProfile([String? nurseId]) async {
    try {
      nurseId ??= currentUserId;
      if (nurseId == null) return null;

      // Try querying by uid field
      final querySnapshot = await _firestore
          .collection('nurses')
          .where('uid', isEqualTo: nurseId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return NurseModel.fromJson(doc.data(), doc.id);
      }

      // Try direct document access
      final docSnapshot = await _firestore
          .collection('nurses')
          .doc(nurseId)
          .get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return NurseModel.fromJson(docSnapshot.data()!, nurseId);
      }

      return null;
    } catch (e) {
      print('[FirebaseServices] Error fetching nurse profile: $e');
      return null;
    }
  }

  /// Get patients assigned to nurse
  ///
  /// **Returns:** List of patient data maps
  Future<List<Map<String, dynamic>>> getNursePatients([String? nurseId]) async {
    try {
      nurseId ??= currentUserId;
      if (nurseId == null) return [];

      final snapshot = await _firestore
          .collection('patients')
          .where('assignedNurseId', isEqualTo: nurseId)
          .get();

      return snapshot.docs.map((doc) {
        final patient = PatientModel.fromJson(doc.data(), doc.id);
        return {
          'id': patient.id,
          'name': patient.name ?? 'Unknown',
          'diagnosis': patient.diagnosis ?? 'No diagnosis',
          'status': patient.status ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching nurse patients: $e');
      return [];
    }
  }

  /// Create override request (nurse requesting doctor approval)
  ///
  /// **Parameters:**
  /// - [doctorId]: Doctor to send request to
  /// - [patientId]: Patient ID
  /// - [medicationName]: Name of medication
  /// - [currentDosage]: Current dosage amount
  /// - [requestedDosage]: Requested new dosage
  /// - [reason]: Reason for override request
  /// - [nurseId]: Nurse ID (optional, defaults to current user)
  Future<void> createOverrideRequest({
    required String doctorId,
    required String patientId,
    required String medicationName,
    required String currentDosage,
    required String requestedDosage,
    required String reason,
    String? nurseId,
  }) async {
    nurseId ??= currentUserId;
    if (nurseId == null) throw Exception('No nurse logged in');

    await _firestore.collection('mobile_override_requests').add({
      'nurseId': nurseId,
      'doctorId': doctorId,
      'patientId': patientId,
      'medicationName': medicationName,
      'currentDosage': currentDosage,
      'requestedDosage': requestedDosage,
      'reason': reason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get appointments for nurse
  ///
  /// **Returns:** List of appointment data maps
  Future<List<Map<String, dynamic>>> getNurseAppointments([
    String? nurseId,
  ]) async {
    try {
      nurseId ??= currentUserId;
      if (nurseId == null) return [];

      final snapshot = await _firestore
          .collection('appointments')
          .where('nurseId', isEqualTo: nurseId)
          .orderBy('scheduledTime', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'patientName': data['patientName'] as String? ?? 'Unknown',
          'doctorName': data['doctorName'] as String? ?? 'Unknown',
          'scheduledTime': data['scheduledTime'],
          'status': data['status'] as String? ?? 'scheduled',
        };
      }).toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching nurse appointments: $e');
      return [];
    }
  }

  /// Update medication order status
  ///
  /// **Parameters:**
  /// - [orderId]: Medication order document ID
  /// - [status]: New status value
  Future<void> updateMedicationOrderStatus(
    String orderId,
    String status,
  ) async {
    await _firestore.collection('mobile_medication_orders').doc(orderId).update(
      {'status': status, 'updatedAt': FieldValue.serverTimestamp()},
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. PATIENT SERVICES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get patient profile from 'patients' collection
  ///
  /// **Parameters:**
  /// - [patientId]: Patient's UID or document ID (defaults to current user)
  ///
  /// **Returns:** [PatientModel] or null if not found
  Future<PatientModel?> getPatientProfile([String? patientId]) async {
    try {
      patientId ??= currentUserId;
      if (patientId == null) return null;

      // Try querying by uid field
      final querySnapshot = await _firestore
          .collection('patients')
          .where('uid', isEqualTo: patientId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return PatientModel.fromJson(doc.data(), doc.id);
      }

      // Try direct document access
      final docSnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return PatientModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }

      return null;
    } catch (e) {
      print('[FirebaseServices] Error fetching patient profile: $e');
      return null;
    }
  }

  /// Get patient's medical records
  ///
  /// **Parameters:**
  /// - [patientId]: Patient ID (optional, defaults to current user's patient profile)
  ///
  /// **Returns:** List of [MedicalRecordModel] objects
  Future<List<MedicalRecordModel>> getPatientMedicalRecords([
    String? patientId,
  ]) async {
    try {
      if (patientId == null) {
        final patient = await getPatientProfile();
        if (patient == null) return [];
        patientId = patient.id;
      }

      final querySnapshot = await _firestore
          .collection('mobile_medical_records')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MedicalRecordModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching patient medical records: $e');
      return [];
    }
  }

  /// Get patient's lab results
  ///
  /// **Returns:** List of [LabResultModel] objects
  Future<List<LabResultModel>> getPatientLabResults([String? patientId]) async {
    try {
      if (patientId == null) {
        final patient = await getPatientProfile();
        if (patient == null) return [];
        patientId = patient.id;
      }

      final querySnapshot = await _firestore
          .collection('mobile_lab_results')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LabResultModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching patient lab results: $e');
      return [];
    }
  }

  /// Get patient's prescriptions
  ///
  /// **Returns:** List of [PrescriptionModel] objects
  Future<List<PrescriptionModel>> getPatientPrescriptions([
    String? patientId,
  ]) async {
    try {
      if (patientId == null) {
        final patient = await getPatientProfile();
        if (patient == null) return [];
        patientId = patient.id;
      }

      final querySnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching patient prescriptions: $e');
      return [];
    }
  }

  /// Get patient's active prescriptions only
  ///
  /// **Returns:** List of [PrescriptionModel] with status 'pending' or 'active'
  Future<List<PrescriptionModel>> getPatientActivePrescriptions([
    String? patientId,
  ]) async {
    try {
      if (patientId == null) {
        final patient = await getPatientProfile();
        if (patient == null) return [];
        patientId = patient.id;
      }

      final querySnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', isEqualTo: patientId)
          .where('status', whereIn: ['pending', 'active'])
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching active prescriptions: $e');
      return [];
    }
  }

  /// Get patient's appointments
  ///
  /// **Returns:** List of appointment data maps
  Future<List<Map<String, dynamic>>> getPatientAppointments([
    String? patientId,
  ]) async {
    try {
      if (patientId == null) {
        final patient = await getPatientProfile();
        if (patient == null) return [];
        patientId = patient.id;
      }

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching patient appointments: $e');
      return [];
    }
  }

  /// Get patient's transportation requests
  ///
  /// **Returns:** List of transportation request data maps
  Future<List<Map<String, dynamic>>> getPatientTransportationRequests([
    String? patientId,
  ]) async {
    try {
      if (patientId == null) {
        final patient = await getPatientProfile();
        if (patient == null) return [];
        patientId = patient.id;
      }

      final querySnapshot = await _firestore
          .collection('transportation_requests')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching transportation requests: $e');
      return [];
    }
  }

  /// Create transportation request
  ///
  /// **Parameters:**
  /// - [pickupLocation]: Where patient needs to be picked up
  /// - [destination]: Where patient needs to go
  /// - [requestedTime]: When transportation is needed
  /// - [notes]: Additional notes (optional)
  /// - [patientId]: Patient ID (optional, defaults to current user's patient profile)
  ///
  /// **Returns:** True if successful, false otherwise
  Future<bool> createTransportationRequest({
    required String pickupLocation,
    required String destination,
    required DateTime requestedTime,
    String? notes,
    String? patientId,
  }) async {
    try {
      PatientModel? patient;
      if (patientId == null) {
        patient = await getPatientProfile();
        if (patient == null) return false;
        patientId = patient.id;
      } else {
        patient = await getPatientProfile(patientId);
        if (patient == null) return false;
      }

      await _firestore.collection('transportation_requests').add({
        'patientId': patientId,
        'patientName': patient.name,
        'pickupLocation': pickupLocation,
        'destination': destination,
        'requestedTime': Timestamp.fromDate(requestedTime),
        'status': 'pending',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('[FirebaseServices] Error creating transportation request: $e');
      return false;
    }
  }

  /// Mark medication as taken
  ///
  /// **Parameters:**
  /// - [prescriptionId]: Prescription document ID
  /// - [takenAt]: Time when medication was taken
  ///
  /// **Returns:** True if successful, false otherwise
  Future<bool> markMedicationTaken({
    required String prescriptionId,
    required DateTime takenAt,
  }) async {
    try {
      await _firestore
          .collection('mobile_prescriptions')
          .doc(prescriptionId)
          .update({
            'lastTakenAt': Timestamp.fromDate(takenAt),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      print('[FirebaseServices] Error marking medication as taken: $e');
      return false;
    }
  }

  /// Get patient dashboard statistics
  ///
  /// **Returns:** Map with 'upcomingAppointments', 'activeMedications', 'pendingLabResults'
  Future<Map<String, dynamic>> getPatientDashboardStats([
    String? patientId,
  ]) async {
    try {
      if (patientId == null) {
        final patient = await getPatientProfile();
        if (patient == null) return {};
        patientId = patient.id;
      }

      // Count upcoming appointments
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where(
            'appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
          )
          .get();

      // Count active prescriptions
      final prescriptionsSnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', isEqualTo: patientId)
          .where('status', whereIn: ['pending', 'active'])
          .get();

      // Count pending lab results
      final labResultsSnapshot = await _firestore
          .collection('mobile_lab_results')
          .where('patientId', isEqualTo: patientId)
          .where('doctorNotes', isEqualTo: null)
          .get();

      return {
        'upcomingAppointments': appointmentsSnapshot.docs.length,
        'activeMedications': prescriptionsSnapshot.docs.length,
        'pendingLabResults': labResultsSnapshot.docs.length,
      };
    } catch (e) {
      print('[FirebaseServices] Error fetching patient dashboard stats: $e');
      return {};
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. RESPONSIBLE PARTY SERVICES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get all patients assigned to responsible person
  ///
  /// **Parameters:**
  /// - [responsibleId]: Responsible person's UID (defaults to current user)
  ///
  /// **Returns:** List of [PatientModel] objects
  Future<List<PatientModel>> getResponsiblePatients([
    String? responsibleId,
  ]) async {
    try {
      responsibleId ??= currentUserId;
      if (responsibleId == null) return [];

      final querySnapshot = await _firestore
          .collection('patients')
          .where('responsiblePartyId', isEqualTo: responsibleId)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => PatientModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('[FirebaseServices] Error fetching responsible patients: $e');
      return [];
    }
  }

  /// Create transportation request for a patient (by responsible person)
  ///
  /// **Parameters:**
  /// - [patientId]: Patient ID
  /// - [pickupLocation]: Where patient needs to be picked up
  /// - [destination]: Where patient needs to go
  /// - [requestedTime]: When transportation is needed
  /// - [notes]: Additional notes (optional)
  /// - [responsibleId]: Responsible person ID (optional, defaults to current user)
  ///
  /// **Returns:** True if successful, false otherwise
  Future<bool> createTransportationRequestForPatient({
    required String patientId,
    required String pickupLocation,
    required String destination,
    required DateTime requestedTime,
    String? notes,
    String? responsibleId,
  }) async {
    try {
      responsibleId ??= currentUserId;
      final patient = await getPatientProfile(patientId);
      if (patient == null) return false;

      await _firestore.collection('transportation_requests').add({
        'patientId': patientId,
        'patientName': patient.name,
        'responsiblePartyId': responsibleId,
        'pickupLocation': pickupLocation,
        'destination': destination,
        'requestedTime': Timestamp.fromDate(requestedTime),
        'status': 'pending',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('[FirebaseServices] Error creating transportation request: $e');
      return false;
    }
  }

  /// Get dashboard statistics for responsible person
  ///
  /// **Returns:** Map with 'totalPatients', 'upcomingAppointments', 'activeMedications', 'pendingLabResults'
  Future<Map<String, dynamic>> getResponsibleDashboardStats([
    String? responsibleId,
  ]) async {
    try {
      final patients = await getResponsiblePatients(responsibleId);
      final patientIds = patients.map((p) => p.id).toList();

      if (patientIds.isEmpty) {
        return {
          'totalPatients': 0,
          'upcomingAppointments': 0,
          'activeMedications': 0,
          'pendingLabResults': 0,
        };
      }

      // Count upcoming appointments for all patients
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('patientId', whereIn: patientIds)
          .where(
            'appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
          )
          .get();

      // Count active prescriptions for all patients
      final prescriptionsSnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', whereIn: patientIds)
          .where('status', whereIn: ['pending', 'active'])
          .get();

      // Count pending lab results for all patients
      final labResultsSnapshot = await _firestore
          .collection('mobile_lab_results')
          .where('patientId', whereIn: patientIds)
          .where('doctorNotes', isEqualTo: null)
          .get();

      return {
        'totalPatients': patients.length,
        'upcomingAppointments': appointmentsSnapshot.docs.length,
        'activeMedications': prescriptionsSnapshot.docs.length,
        'pendingLabResults': labResultsSnapshot.docs.length,
      };
    } catch (e) {
      print(
        '[FirebaseServices] Error fetching responsible dashboard stats: $e',
      );
      return {
        'totalPatients': 0,
        'upcomingAppointments': 0,
        'activeMedications': 0,
        'pendingLabResults': 0,
      };
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 7. UTILITY METHODS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Search through a list of items by query string
  ///
  /// **Parameters:**
  /// - [list]: List of maps to search through
  /// - [query]: Search query string
  /// - [fields]: List of field names to search in
  ///
  /// **Returns:** Filtered list matching the query
  ///
  /// **Usage:**
  /// ```dart
  /// final patients = [...];
  /// final results = FirebaseServices().searchList(
  ///   list: patients,
  ///   query: 'John',
  ///   fields: ['name', 'email'],
  /// );
  /// ```
  static List<Map<String, dynamic>> searchList({
    required List<Map<String, dynamic>> list,
    required String query,
    required List<String> fields,
  }) {
    if (query.isEmpty) return list;

    final lowerQuery = query.toLowerCase();
    return list.where((item) {
      return fields.any((field) {
        final value = item[field];
        if (value == null) return false;
        return value.toString().toLowerCase().contains(lowerQuery);
      });
    }).toList();
  }

  /// Calculate age from date of birth string
  ///
  /// **Parameters:**
  /// - [dob]: Date of birth as string (format: ISO 8601, e.g., "1990-01-15")
  ///
  /// **Returns:** Age in years, or null if parsing fails
  int? _calculateAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAMPLE DATA LOADER
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads comprehensive sample data for testing the Doctor folder.
  // It creates realistic data for all collections used by doctors.
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load sample data for Doctor folder
  ///
  /// This creates:
  /// - Doctor profile (if not exists)
  /// - Patients assigned to current doctor
  /// - Nurses (for override requests)
  /// - Medications catalog
  /// - Lab test requests and results
  /// - Prescriptions
  /// - Medical records
  /// - Override requests
  /// - Appointments
  ///
  /// **Note:** This method checks for existing data and only creates new records
  /// if they don't already exist to avoid duplicates.
  Future<void> loadSampleDataForDoctor() async {
    final loader = SampleDataLoader();
    await loader.loadAllSampleData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POSTS SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all posts from web_posts collection
  ///
  /// **Returns:** List of PostModel sorted by createdAt (newest first)
  Future<List<PostModel>> getAllPosts() async {
    try {
      final snapshot = await _firestore
          .collection('web_posts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          // Debug: Print image field
          print(
            '[FirebaseServices] Post ${doc.id}: image field = ${data['image']}, type = ${data['image'].runtimeType}',
          );
          return PostModel.fromJson(data, doc.id);
        } catch (e) {
          print('[FirebaseServices] Error parsing post ${doc.id}: $e');
          return PostModel(id: doc.id);
        }
      }).toList();
    } catch (e) {
      // If index error, fetch without orderBy and sort in code
      if (e.toString().contains('index') ||
          e.toString().contains('FAILED_PRECONDITION')) {
        print(
          '[FirebaseServices] Index required for posts, fetching without orderBy...',
        );
        try {
          final snapshot = await _firestore.collection('web_posts').get();
          final posts = snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              // Debug: Print image field
              print(
                '[FirebaseServices] Post ${doc.id}: image field = ${data['image']}, type = ${data['image'].runtimeType}',
              );
              return PostModel.fromJson(data, doc.id);
            } catch (e) {
              print('[FirebaseServices] Error parsing post ${doc.id}: $e');
              return PostModel(id: doc.id);
            }
          }).toList();

          // Sort by createdAt descending in code
          posts.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });

          return posts;
        } catch (e2) {
          print('[FirebaseServices] Error in alternative posts method: $e2');
          return [];
        }
      } else {
        print('[FirebaseServices] Error fetching posts: $e');
        return [];
      }
    }
  }

  /// Like a post (only once per user)
  ///
  /// **Parameters:**
  /// - [postId]: ID of the post to like
  ///
  /// **Returns:** Updated likes count
  Future<int> likePost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final postRef = _firestore.collection('web_posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      // Get current likedBy array (list of user IDs who liked the post)
      final likedBy = (postDoc.data()?['likedBy'] as List?) ?? [];
      final likedByList = List<String>.from(likedBy.map((e) => e.toString()));

      // Check if user already liked the post
      if (likedByList.contains(userId)) {
        // User already liked, return current count
        final currentLikes = (postDoc.data()?['likes'] as int?) ?? 0;
        print('[FirebaseServices] User already liked this post');
        return currentLikes;
      }

      // Add user to likedBy array and increment likes
      likedByList.add(userId);
      final currentLikes = (postDoc.data()?['likes'] as int?) ?? 0;
      final newLikes = currentLikes + 1;

      await postRef.update({'likes': newLikes, 'likedBy': likedByList});

      print('[FirebaseServices] Post liked successfully. New likes: $newLikes');
      return newLikes;
    } catch (e) {
      print('[FirebaseServices] Error liking post: $e');
      rethrow;
    }
  }

  /// Add a comment to a post
  ///
  /// **Parameters:**
  /// - [postId]: ID of the post to comment on
  /// - [commentText]: Text of the comment
  /// - [authorId]: ID of the user making the comment (optional, defaults to current user)
  /// - [authorName]: Name of the user making the comment (optional)
  ///
  /// **Returns:** Updated post with new comment
  Future<void> addCommentToPost({
    required String postId,
    required String commentText,
    String? authorId,
    String? authorName,
  }) async {
    try {
      authorId ??= currentUserId;
      if (authorId == null) {
        throw Exception('No user logged in');
      }

      // Get current user name if not provided
      if (authorName == null) {
        try {
          final userProfile = await getDoctorProfile();
          authorName = userProfile?.name ?? 'مستخدم';
        } catch (e) {
          authorName = 'مستخدم';
        }
      }

      final postRef = _firestore.collection('web_posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      // Get current comments
      final currentComments = (postDoc.data()?['comments'] as List?) ?? [];

      // Add new comment
      // Note: Cannot use FieldValue.serverTimestamp() inside arrays
      // Use Timestamp.now() instead
      final newComment = {
        'text': commentText,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt':
            Timestamp.now(), // Use Timestamp.now() instead of FieldValue.serverTimestamp()
      };

      currentComments.add(newComment);

      // Update post with new comment
      await postRef.update({'comments': currentComments});
    } catch (e) {
      print('[FirebaseServices] Error adding comment: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP CHAT SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all group chats that the current user is a member of
  ///
  /// **Returns:** List of GroupChatModel where user is a member
  Future<List<GroupChatModel>> getUserGroupChats([String? userId]) async {
    try {
      userId ??= currentUserId;
      if (userId == null) return [];

      // Query groups where user is in memberIds array
      final snapshot = await _firestore
          .collection('group_chats')
          .where('memberIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        try {
          return GroupChatModel.fromJson(doc.data(), doc.id);
        } catch (e) {
          print('[FirebaseServices] Error parsing group chat ${doc.id}: $e');
          return GroupChatModel(id: doc.id);
        }
      }).toList();
    } catch (e) {
      // If index error, fetch without orderBy and sort in code
      if (e.toString().contains('index') ||
          e.toString().contains('FAILED_PRECONDITION')) {
        print(
          '[FirebaseServices] Index required for group chats, fetching without orderBy...',
        );
        try {
          final snapshot = await _firestore
              .collection('group_chats')
              .where('memberIds', arrayContains: userId ?? currentUserId ?? '')
              .get();

          final groups = snapshot.docs.map((doc) {
            try {
              return GroupChatModel.fromJson(doc.data(), doc.id);
            } catch (e) {
              print(
                '[FirebaseServices] Error parsing group chat ${doc.id}: $e',
              );
              return GroupChatModel(id: doc.id);
            }
          }).toList();

          // Sort by updatedAt descending in code
          groups.sort((a, b) {
            if (a.updatedAt == null && b.updatedAt == null) return 0;
            if (a.updatedAt == null) return 1;
            if (b.updatedAt == null) return -1;
            return b.updatedAt!.compareTo(a.updatedAt!);
          });

          return groups;
        } catch (e2) {
          print(
            '[FirebaseServices] Error in alternative group chats method: $e2',
          );
          return [];
        }
      } else {
        print('[FirebaseServices] Error fetching user group chats: $e');
        return [];
      }
    }
  }

  /// Get a specific group chat by ID
  ///
  /// **Parameters:**
  /// - [groupId]: ID of the group chat
  ///
  /// **Returns:** GroupChatModel or null if not found
  Future<GroupChatModel?> getGroupChat(String groupId) async {
    try {
      final doc = await _firestore.collection('group_chats').doc(groupId).get();
      if (!doc.exists) return null;
      return GroupChatModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      print('[FirebaseServices] Error fetching group chat: $e');
      return null;
    }
  }

  /// Join a group chat (add user to memberIds)
  ///
  /// **Parameters:**
  /// - [groupId]: ID of the group chat to join
  /// - [userId]: ID of the user joining (optional, defaults to current user)
  ///
  /// **Note:** This should be called when user accepts an invitation
  Future<void> joinGroupChat(String groupId, [String? userId]) async {
    try {
      userId ??= currentUserId;
      if (userId == null) throw Exception('No user logged in');

      final groupRef = _firestore.collection('group_chats').doc(groupId);
      final groupDoc = await groupRef.get();

      if (!groupDoc.exists) {
        throw Exception('Group chat not found');
      }

      final currentMemberIds = List<String>.from(
        groupDoc.data()?['memberIds'] ?? [],
      );

      if (currentMemberIds.contains(userId)) {
        // User is already a member
        return;
      }

      // Add user to memberIds
      currentMemberIds.add(userId);

      await groupRef.update({
        'memberIds': currentMemberIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('[FirebaseServices] Error joining group chat: $e');
      rethrow;
    }
  }

  /// Get messages for a group chat (real-time stream)
  ///
  /// **Parameters:**
  /// - [groupId]: ID of the group chat
  ///
  /// **Returns:** Stream of List<GroupChatMessageModel>
  ///
  /// **Note:**
  /// - Returns ALL messages (past and future) in real-time
  /// - Uses fallback stream without orderBy if index is missing
  /// - Messages are sorted by createdAt (oldest first)
  Stream<List<GroupChatMessageModel>> getGroupChatMessages(String groupId) {
    print(
      '[FirebaseServices] Setting up real-time messages stream for group: $groupId',
    );

    // Listen to ALL messages in the collection for real-time updates (millisecond precision)
    // Filter in code to include both new messages (groupChatId) and legacy messages (groupId or null)
    try {
      final stream = _firestore
          .collection('group_chat_messages')
          .snapshots() // Listen to ALL messages for real-time updates
          .map((snapshot) {
            print(
              '[FirebaseServices] Stream update: Received ${snapshot.docs.length} total messages in collection',
            );

            // Filter messages that match this group (including legacy messages)
            // This merges: my messages + other users messages in real-time
            final filteredDocs = snapshot.docs.where((doc) {
              final data = doc.data();
              final msgGroupChatId = data['groupChatId'];
              final msgGroupId = data['groupId']; // Legacy field

              // Include messages with:
              // 1. Matching groupChatId (new format)
              // 2. Matching groupId (legacy format)
              // 3. Both null (legacy messages for this group)
              final matches =
                  msgGroupChatId == groupId ||
                  msgGroupId == groupId ||
                  (msgGroupChatId == null && msgGroupId == null);

              return matches;
            }).toList();

            print(
              '[FirebaseServices] Stream: Filtered to ${filteredDocs.length} messages for group $groupId (merged: my messages + other users messages)',
            );

            final messages = filteredDocs.map((doc) {
              try {
                final data = doc.data();
                print('[FirebaseServices] Stream: Parsing message ${doc.id}');
                print(
                  '[FirebaseServices] Stream: senderId (raw)="${data['senderId']}" (type: ${data['senderId'].runtimeType})',
                );
                print(
                  '[FirebaseServices] Stream: senderName="${data['senderName']}"',
                );
                print(
                  '[FirebaseServices] Stream: senderRole="${data['senderRole']}"',
                );
                print('[FirebaseServices] Stream: Full data: $data');

                // Ensure groupChatId is set if it's null (for legacy messages)
                if (data['groupChatId'] == null && data['groupId'] == groupId) {
                  data['groupChatId'] = groupId;
                }

                final parsedMessage = GroupChatMessageModel.fromJson(
                  data,
                  doc.id,
                );
                print(
                  '[FirebaseServices] Stream: Parsed - senderId="${parsedMessage.senderId}", senderName="${parsedMessage.senderName}", senderRole="${parsedMessage.senderRole}"',
                );
                return parsedMessage;
              } catch (e) {
                print('[FirebaseServices] Error parsing message ${doc.id}: $e');
                return GroupChatMessageModel(
                  id: doc.id,
                  groupChatId: groupId,
                  senderId: '',
                  senderName: 'مستخدم',
                  senderRole: 'patient',
                  message: '',
                );
              }
            }).toList();

            // IMPORTANT: Sort by createdAt in code (ascending - oldest first)
            // This ensures proper chronological order for all messages
            messages.sort((a, b) {
              if (a.createdAt == null && b.createdAt == null) {
                // If both null, sort by ID as fallback
                return a.id.compareTo(b.id);
              }
              if (a.createdAt == null) return 1; // Null dates go to end
              if (b.createdAt == null) return -1; // Null dates go to end

              // Sort by createdAt (ascending - oldest first)
              final comparison = a.createdAt!.compareTo(b.createdAt!);

              // If same timestamp, sort by ID to ensure consistent order
              if (comparison == 0) {
                return a.id.compareTo(b.id);
              }

              return comparison;
            });

            print(
              '[FirebaseServices] Stream: Returning ${messages.length} sorted messages (chronological order, real-time merged)',
            );

            // Debug: Print first and last message timestamps
            if (messages.isNotEmpty) {
              print(
                '[FirebaseServices] First message: ${messages.first.createdAt}, Last message: ${messages.last.createdAt}',
              );
            }

            return messages;
          })
          .handleError((error, stackTrace) {
            print('[FirebaseServices] Error in messages stream: $error');
            print('[FirebaseServices] Stack trace: $stackTrace');
            // Return empty list on error but log the error
            return <GroupChatMessageModel>[];
          });

      return stream;
    } catch (e) {
      print('[FirebaseServices] Error setting up stream: $e');
      // Return a stream that emits empty list
      return Stream.value(<GroupChatMessageModel>[]);
    }
  }

  /// Debug helper to check messages in collection
  // ignore: unused_element
  Future<void> _debugCheckMessages(String groupId) async {
    try {
      final allMessages = await _firestore
          .collection('group_chat_messages')
          .limit(10)
          .get();

      print(
        '[FirebaseServices] Debug: Found ${allMessages.docs.length} total messages in collection',
      );

      for (var doc in allMessages.docs) {
        final data = doc.data();
        final msgGroupId = data['groupChatId']?.toString() ?? 'null';
        print(
          '[FirebaseServices] Debug: Message ${doc.id} has groupChatId: $msgGroupId (looking for: $groupId)',
        );
      }
    } catch (e) {
      print('[FirebaseServices] Debug check error: $e');
    }
  }

  /// Get messages for a group chat (one-time fetch - fallback method)
  ///
  /// **Parameters:**
  /// - [groupId]: ID of the group chat
  ///
  /// **Returns:** Future<List<GroupChatMessageModel>>
  ///
  /// **Note:** Use this as a fallback if Stream fails
  Future<List<GroupChatMessageModel>> getGroupChatMessagesOnce(
    String groupId,
  ) async {
    try {
      print('[FirebaseServices] Fetching messages once for group: $groupId');

      // Always get all messages and filter in code to include null groupChatId messages
      // This ensures we get all messages including legacy ones with null groupChatId
      print(
        '[FirebaseServices] Fetching all messages to include null groupChatId (legacy messages)...',
      );

      // IMPORTANT: Get ALL messages from database (no limit to get complete history)
      final allMessagesSnapshot = await _firestore
          .collection('group_chat_messages')
          .get(); // Get ALL messages, no limit

      print(
        '[FirebaseServices] Total messages in collection: ${allMessagesSnapshot.docs.length}',
      );

      if (allMessagesSnapshot.docs.isNotEmpty) {
        print(
          '[FirebaseServices] Sample message groupChatId: ${allMessagesSnapshot.docs.first.data()['groupChatId']}',
        );
        print('[FirebaseServices] Looking for groupId: $groupId');
      }

      print(
        '[FirebaseServices] Found ${allMessagesSnapshot.docs.length} total messages in collection',
      );

      // Filter messages that match groupId or have null groupChatId/groupId (legacy messages)
      final docsToProcess = allMessagesSnapshot.docs.where((doc) {
        final data = doc.data();
        final msgGroupChatId = data['groupChatId'];
        final msgGroupId = data['groupId']; // Legacy field
        // Include messages with matching groupChatId/groupId or null (legacy)
        final matches =
            msgGroupChatId == groupId ||
            msgGroupId == groupId ||
            (msgGroupChatId == null && msgGroupId == null);
        if (matches) {
          print(
            '[FirebaseServices] Including message ${doc.id}: groupChatId=$msgGroupChatId, groupId=$msgGroupId, senderId=${data['senderId']}',
          );
        }
        return matches;
      }).toList();

      print(
        '[FirebaseServices] Filtered to ${docsToProcess.length} messages for group $groupId (including null groupChatId)',
      );

      final messages = docsToProcess.map((doc) {
        try {
          final data = doc.data();
          print('[FirebaseServices] Parsing message ${doc.id}');
          print('[FirebaseServices] Message data keys: ${data.keys}');
          print(
            '[FirebaseServices] Message groupChatId: ${data['groupChatId']}',
          );
          print(
            '[FirebaseServices] Message senderId (raw): "${data['senderId']}" (type: ${data['senderId'].runtimeType})',
          );
          print(
            '[FirebaseServices] Message senderName: "${data['senderName']}"',
          );
          print(
            '[FirebaseServices] Message senderRole: "${data['senderRole']}"',
          );
          print('[FirebaseServices] Message message: "${data['message']}"');
          print('[FirebaseServices] Full message data: $data');

          // Ensure groupChatId is set if it's null
          if (data['groupChatId'] == null) {
            data['groupChatId'] = groupId;
            print(
              '[FirebaseServices] Fixed null groupChatId for message ${doc.id}',
            );
          }

          final parsedMessage = GroupChatMessageModel.fromJson(data, doc.id);
          print(
            '[FirebaseServices] Parsed message: senderId="${parsedMessage.senderId}", senderName="${parsedMessage.senderName}", senderRole="${parsedMessage.senderRole}"',
          );
          return parsedMessage;
        } catch (e) {
          print('[FirebaseServices] Error parsing message ${doc.id}: $e');
          print('[FirebaseServices] Message data: ${doc.data()}');
          return GroupChatMessageModel(
            id: doc.id,
            groupChatId: groupId,
            senderId: '',
            senderName: 'مستخدم',
            senderRole: 'patient',
            message: '',
          );
        }
      }).toList();

      // Sort by createdAt in code (ascending - oldest first)
      messages.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      });

      print('[FirebaseServices] Returning ${messages.length} sorted messages');
      return messages;
    } catch (e) {
      print('[FirebaseServices] Error fetching messages once: $e');
      return [];
    }
  }

  /// Send a message to a group chat
  ///
  /// **Parameters:**
  /// - [groupId]: ID of the group chat
  /// - [message]: Message text
  /// - [senderId]: ID of the sender (optional, defaults to current user)
  /// - [senderName]: Name of the sender (optional)
  /// - [senderRole]: Role of the sender ('doctor', 'nurse', 'patient')
  ///
  /// **Returns:** ID of the created message
  Future<String> sendGroupChatMessage({
    required String groupId,
    required String message,
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      senderId ??= currentUserId;
      if (senderId == null) throw Exception('No user logged in');

      // Get sender name and role if not provided
      if (senderName == null || senderRole == null) {
        try {
          // Try to get from doctor profile
          final doctorProfile = await getDoctorProfile();
          if (doctorProfile != null) {
            senderName ??= doctorProfile.name ?? 'طبيب';
            senderRole ??= 'doctor';
          } else {
            // Try to get user role
            try {
              final userRole = await getUserRole(senderId);
              if (userRole == 'nurse') {
                senderRole ??= 'nurse';
                // Try to get nurse name
                try {
                  final nurseDoc = await _firestore
                      .collection('nurses')
                      .doc(senderId)
                      .get();
                  if (nurseDoc.exists) {
                    senderName ??= nurseDoc.data()?['name'] ?? 'ممرض';
                  } else {
                    senderName ??= 'ممرض';
                  }
                } catch (e) {
                  senderName ??= 'ممرض';
                }
              } else {
                senderName ??= 'مستخدم';
                senderRole ??= 'patient';
              }
            } catch (e) {
              senderName ??= 'مستخدم';
              senderRole ??= 'patient';
            }
          }
        } catch (e) {
          senderName ??= 'مستخدم';
          senderRole ??= 'patient';
        }
      }

      // Create message document
      print('[FirebaseServices] ===== SENDING MESSAGE =====');
      print('[FirebaseServices] groupId: $groupId');
      print(
        '[FirebaseServices] senderId (to save): "$senderId" (length: ${senderId.length})',
      );
      print('[FirebaseServices] senderName: "$senderName"');
      print('[FirebaseServices] senderRole: "$senderRole"');
      print('[FirebaseServices] message: "$message"');
      print('[FirebaseServices] currentUserId: "$currentUserId"');
      print(
        '[FirebaseServices] senderId == currentUserId: ${senderId == currentUserId}',
      );

      final messageData = {
        'groupChatId': groupId,
        'senderId': senderId, // CRITICAL: This MUST be the actual sender's ID
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': {senderId: true}, // Mark as read by sender
      };

      print('[FirebaseServices] Message data to save: $messageData');

      final messageRef = await _firestore
          .collection('group_chat_messages')
          .add(messageData);

      print('[FirebaseServices] Message saved with ID: ${messageRef.id}');
      print('[FirebaseServices] ===========================');

      // Update group chat's updatedAt
      await _firestore.collection('group_chats').doc(groupId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return messageRef.id;
    } catch (e) {
      print('[FirebaseServices] Error sending message: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NURSE SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get nurse medications
  Future<List<Map<String, dynamic>>> getNurseMedications([
    String? nurseId,
  ]) async {
    try {
      nurseId ??= currentUserId;
      if (nurseId == null) return [];

      final patients = await getNursePatients(nurseId);
      final patientIds = patients.map((p) => p['id'] as String).toList();

      if (patientIds.isEmpty) return [];

      final snapshot = await _firestore
          .collection('prescriptions')
          .where('patientId', whereIn: patientIds)
          .get();

      return snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList();
    } catch (e) {
      print('[FirebaseServices] Error getting nurse medications: $e');
      return [];
    }
  }

  /// Mark a message as read
  ///
  /// **Parameters:**
  /// - [messageId]: ID of the message
  /// - [userId]: ID of the user (optional, defaults to current user)
  Future<void> markMessageAsRead(String messageId, [String? userId]) async {
    try {
      userId ??= currentUserId;
      if (userId == null) return;

      final messageRef = _firestore
          .collection('group_chat_messages')
          .doc(messageId);
      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) return;

      final readBy = Map<String, bool>.from(messageDoc.data()?['readBy'] ?? {});

      readBy[userId] = true;

      await messageRef.update({'readBy': readBy});
    } catch (e) {
      print('[FirebaseServices] Error marking message as read: $e');
      // Don't throw, this is not critical
    }
  }

  /// Get group chat members with their names
  ///
  /// **Parameters:**
  /// - [groupId]: ID of the group chat
  ///
  /// **Returns:** Map of userId -> userName
  Future<Map<String, String>> getGroupChatMembers(String groupId) async {
    try {
      final group = await getGroupChat(groupId);
      if (group == null) return {};

      final members = <String, String>{};

      for (final memberId in group.memberIds) {
        try {
          // Try to get from doctors
          final doctorDoc = await _firestore
              .collection('doctors')
              .doc(memberId)
              .get();
          if (doctorDoc.exists) {
            members[memberId] = doctorDoc.data()?['name'] ?? 'طبيب';
            continue;
          }

          // Try to get from nurses
          final nurseDoc = await _firestore
              .collection('nurses')
              .doc(memberId)
              .get();
          if (nurseDoc.exists) {
            members[memberId] = nurseDoc.data()?['name'] ?? 'ممرض';
            continue;
          }

          // Try to get from patients
          final patientDoc = await _firestore
              .collection('patients')
              .doc(memberId)
              .get();
          if (patientDoc.exists) {
            members[memberId] = patientDoc.data()?['name'] ?? 'مريض';
            continue;
          }

          // Default
          members[memberId] = 'مستخدم';
        } catch (e) {
          members[memberId] = 'مستخدم';
        }
      }

      return members;
    } catch (e) {
      print('[FirebaseServices] Error getting group members: $e');
      return {};
    }
  }
}
