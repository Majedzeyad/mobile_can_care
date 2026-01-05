import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';
import '../models/medical_record_model.dart';
import '../models/lab_result_model.dart';
import '../models/prescription_model.dart';

/// Service class for handling patient-related Firestore operations.
///
/// This service provides methods for:
/// - Fetching patient profile information
/// - Managing medical records
/// - Accessing lab results
/// - Viewing prescriptions and medications
/// - Managing appointments
/// - Handling transportation requests
///
/// All operations interact with Firebase Firestore to fetch real-time data.
class PatientService {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get patient profile for current user
  Future<PatientModel?> getPatientProfile() async {
    try {
      final uid = currentUserId;
      if (uid == null) return null;

      // First try to find patient by uid field
      final querySnapshot = await _firestore
          .collection('patients')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return PatientModel.fromJson(doc.data(), doc.id);
      }

      // If not found by uid, try by document ID
      final docSnapshot = await _firestore.collection('patients').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return PatientModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }

      return null;
    } catch (e) {
      print('Error fetching patient profile: $e');
      return null;
    }
  }

  /// Get patient's medical records
  Future<List<MedicalRecordModel>> getMedicalRecords() async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return [];

      final querySnapshot = await _firestore
          .collection('mobile_medical_records')
          .where('patientId', isEqualTo: patient.id)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MedicalRecordModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching medical records: $e');
      return [];
    }
  }

  /// Get patient's lab results
  Future<List<LabResultModel>> getLabResults() async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return [];

      final querySnapshot = await _firestore
          .collection('mobile_lab_results')
          .where('patientId', isEqualTo: patient.id)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LabResultModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching lab results: $e');
      return [];
    }
  }

  /// Get patient's prescriptions
  Future<List<PrescriptionModel>> getPrescriptions() async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return [];

      final querySnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', isEqualTo: patient.id)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching prescriptions: $e');
      return [];
    }
  }

  /// Get active prescriptions (not completed)
  Future<List<PrescriptionModel>> getActivePrescriptions() async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return [];

      final querySnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', isEqualTo: patient.id)
          .where('status', whereIn: ['pending', 'active'])
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching active prescriptions: $e');
      return [];
    }
  }

  /// Get patient's appointments
  /// Note: Appointments collection structure may need to be defined based on your schema
  Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return [];

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patient.id)
          .orderBy('appointmentDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  /// Get patient's transportation requests
  /// Note: Transportation collection structure may need to be defined based on your schema
  Future<List<Map<String, dynamic>>> getTransportationRequests() async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return [];

      final querySnapshot = await _firestore
          .collection('transportation_requests')
          .where('patientId', isEqualTo: patient.id)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching transportation requests: $e');
      return [];
    }
  }

  /// Create a new transportation request
  Future<bool> createTransportationRequest({
    required String pickupLocation,
    required String destination,
    required DateTime requestedTime,
    String? notes,
  }) async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return false;

      await _firestore.collection('transportation_requests').add({
        'patientId': patient.id,
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
      print('Error creating transportation request: $e');
      return false;
    }
  }

  /// Mark medication as taken
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
      print('Error marking medication as taken: $e');
      return false;
    }
  }

  /// Get patient statistics (for dashboard)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final patient = await getPatientProfile();
      if (patient == null) return {};

      // Count upcoming appointments
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patient.id)
          .where('appointmentDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .get();

      // Count active prescriptions
      final prescriptionsSnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', isEqualTo: patient.id)
          .where('status', whereIn: ['pending', 'active'])
          .get();

      // Count pending lab results
      final labResultsSnapshot = await _firestore
          .collection('mobile_lab_results')
          .where('patientId', isEqualTo: patient.id)
          .where('doctorNotes', isEqualTo: null)
          .get();

      return {
        'upcomingAppointments': appointmentsSnapshot.docs.length,
        'activeMedications': prescriptionsSnapshot.docs.length,
        'pendingLabResults': labResultsSnapshot.docs.length,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {};
    }
  }

  /// Utility method for searching through a list
  List<T> searchList<T>(
    List<T> list,
    String query,
    String Function(T) getSearchableText,
  ) {
    if (query.isEmpty) return list;
    final lowerQuery = query.toLowerCase();
    return list
        .where((item) =>
            getSearchableText(item).toLowerCase().contains(lowerQuery))
        .toList();
  }
}

