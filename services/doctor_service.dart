import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';
import '../models/patient_model.dart';
import '../models/lab_test_request_model.dart';
import '../models/lab_result_model.dart';
import '../models/medical_record_model.dart';
import '../models/override_request_model.dart';

/// Service for doctor-related Firestore operations
/// This service handles all doctor-specific data operations
class DoctorService {
  static DoctorService? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DoctorService._();

  static DoctorService get instance {
    _instance ??= DoctorService._();
    return _instance!;
  }

  /// Get current doctor UID
  String? get currentDoctorId => _auth.currentUser?.uid;

  /// Get doctor profile from Firestore
  Future<DoctorModel?> getDoctorProfile() async {
    try {
      final doctorId = currentDoctorId;
      if (doctorId == null) return null;

      // Try to find doctor by uid field in doctors collection
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('uid', isEqualTo: doctorId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Try direct document access
        final docSnapshot = await _firestore.collection('doctors').doc(doctorId).get();
        if (!docSnapshot.exists) return null;
        return DoctorModel.fromJson(docSnapshot.data()!, doctorId);
      }

      final doc = querySnapshot.docs.first;
      return DoctorModel.fromJson(doc.data(), doc.id);
    } catch (e) {
      print('Error fetching doctor profile: $e');
      return null;
    }
  }

  /// Get dashboard statistics for current doctor
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final doctorId = currentDoctorId;
      if (doctorId == null) {
        return {'activePatients': 0, 'pendingLabTests': 0, 'recentPrescriptions': 0};
      }

      // Get active patients count
      final patientsSnapshot = await _firestore
          .collection('patients')
          .where('assignedDoctorId', isEqualTo: doctorId)
          .get();

      final activePatients = patientsSnapshot.docs.length;

      // Get pending lab test requests count
      final pendingLabTestsSnapshot = await _firestore
          .collection('mobile_lab_test_requests')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'pending')
          .get();

      final pendingLabTests = pendingLabTestsSnapshot.docs.length;

      // Get recent prescriptions (last 7 days)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final prescriptionsSnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('doctorId', isEqualTo: doctorId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      final recentPrescriptions = prescriptionsSnapshot.docs.length;

      return {
        'activePatients': activePatients,
        'pendingLabTests': pendingLabTests,
        'recentPrescriptions': recentPrescriptions,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {'activePatients': 0, 'pendingLabTests': 0, 'recentPrescriptions': 0};
    }
  }

  /// Get all patients assigned to current doctor
  Future<List<Map<String, dynamic>>> getPatientsForDoctor() async {
    try {
      final doctorId = currentDoctorId;
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
      print('Error fetching patients: $e');
      return [];
    }
  }

  /// Get pending lab test requests for current doctor
  Future<List<Map<String, dynamic>>> getPendingLabTestRequests() async {
    try {
      final doctorId = currentDoctorId;
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
      print('Error fetching pending lab test requests: $e');
      return [];
    }
  }

  /// Create a new lab test request
  Future<void> createLabTestRequest(Map<String, dynamic> data) async {
    try {
      final doctorId = currentDoctorId;
      if (doctorId == null) throw Exception('No doctor logged in');

      await _firestore.collection('mobile_lab_test_requests').add({
        'doctorId': doctorId,
        'patientId': data['patientId'],
        'patientName': data['patientName'],
        'testType': data['testType'],
        'test': data['test'],
        'urgency': data['urgency'] ?? 'normal',
        'notes': data['notes'] ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating lab test request: $e');
      rethrow;
    }
  }

  /// Get lab results for a patient
  Future<List<Map<String, dynamic>>> getLabResultsForPatient(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('mobile_lab_results')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final result = LabResultModel.fromJson(doc.data(), doc.id);
        return {
          'id': result.id,
          'testName': result.testName ?? 'Unknown Test',
          'status': result.status,
        };
      }).toList();
    } catch (e) {
      print('Error fetching lab results: $e');
      return [];
    }
  }

  /// Add notes to a lab result
  Future<void> addNotesToLabResult(String resultId, String notes) async {
    try {
      final doctorId = currentDoctorId;
      if (doctorId == null) throw Exception('No doctor logged in');

      await _firestore.collection('mobile_lab_results').doc(resultId).update({
        'doctorNotes': notes,
        'notesAddedBy': doctorId,
        'notesAddedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding notes to lab result: $e');
      rethrow;
    }
  }

  /// Get medical records for current doctor
  Future<List<Map<String, dynamic>>> getMedicalRecordsForDoctor() async {
    try {
      final doctorId = currentDoctorId;
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
      print('Error fetching medical records: $e');
      return [];
    }
  }

  /// Get all medications (from a medications catalog if it exists)
  Future<List<Map<String, dynamic>>> getAllMedications() async {
    try {
      // If you have a medications collection, fetch from there
      // Otherwise return empty list or predefined list
      final snapshot = await _firestore.collection('medications').limit(100).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Unknown',
          'dosage': data['dosage'] as String? ?? 'No dosage info',
        };
      }).toList();
    } catch (e) {
      // If medications collection doesn't exist, return empty list
      print('Error fetching medications: $e');
      return [];
    }
  }

  /// Create medication order
  Future<void> createMedicationOrder(String medicationId, String medicationName) async {
    try {
      final doctorId = currentDoctorId;
      if (doctorId == null) throw Exception('No doctor logged in');

      await _firestore.collection('mobile_medication_orders').add({
        'doctorId': doctorId,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating medication order: $e');
      rethrow;
    }
  }

  /// Get pending override requests for current doctor
  Future<List<Map<String, dynamic>>> getPendingOverrideRequests() async {
    try {
      final doctorId = currentDoctorId;
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
            final nurseDoc = await _firestore.collection('nurses').doc(request.nurseId!).get();
            if (nurseDoc.exists) {
              nurseName = nurseDoc.data()?['name'] as String? ?? 'Unknown Nurse';
            }
          } catch (e) {
            print('Error fetching nurse name: $e');
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
      print('Error fetching override requests: $e');
      return [];
    }
  }

  /// Approve override request
  Future<void> approveOverrideRequest(String requestId) async {
    try {
      final doctorId = currentDoctorId;
      if (doctorId == null) throw Exception('No doctor logged in');

      await _firestore.collection('mobile_override_requests').doc(requestId).update({
        'status': 'approved',
        'approvedBy': doctorId,
        'approvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error approving override request: $e');
      rethrow;
    }
  }

  /// Get pending transfer requests (for incoming requests)
  Future<List<Map<String, dynamic>>> getPendingTransferRequests() async {
    try {
      final doctorId = currentDoctorId;
      if (doctorId == null) return [];

      // This would depend on your transfer requests structure
      // For now, returning empty list as structure is not fully defined in export
      return [];
    } catch (e) {
      print('Error fetching transfer requests: $e');
      return [];
    }
  }

  /// Accept transfer request
  Future<void> acceptTransferRequest(String requestId) async {
    try {
      // Implementation depends on transfer request structure
      print('Accept transfer request: $requestId');
    } catch (e) {
      print('Error accepting transfer request: $e');
      rethrow;
    }
  }

  /// Reject transfer request
  Future<void> rejectTransferRequest(String requestId) async {
    try {
      // Implementation depends on transfer request structure
      print('Reject transfer request: $requestId');
    } catch (e) {
      print('Error rejecting transfer request: $e');
      rethrow;
    }
  }

  /// Utility: Search list by query
  static List<Map<String, dynamic>> searchList(
    String query,
    List<Map<String, dynamic>> list,
    List<String> fields,
  ) {
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

  /// Calculate age from date of birth
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

