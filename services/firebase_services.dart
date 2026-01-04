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

      final snapshot = await _firestore
          .collection('mobile_lab_test_requests')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final request = LabTestRequestModel.fromJson(doc.data(), doc.id);
        return {
          'id': request.id,
          'patientName': request.patientName ?? 'Unknown',
          'formattedDate': request.createdAt != null
              ? '${request.createdAt!.day}/${request.createdAt!.month}/${request.createdAt!.year}'
              : 'Unknown',
        };
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
        };
      }).toList();
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

      final snapshot = await _firestore
          .collection('mobile_override_requests')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final requests = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final request = OverrideRequestModel.fromJson(doc.data(), doc.id);

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
        });
      }

      return requests;
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
}
