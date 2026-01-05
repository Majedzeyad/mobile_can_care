import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';
import '../models/medical_record_model.dart';
import '../models/lab_result_model.dart';
import '../models/prescription_model.dart';

/// Service class for handling responsible person-related Firestore operations.
///
/// This service provides methods for:
/// - Fetching patients under the responsible person's care
/// - Managing medical records for assigned patients
/// - Accessing lab results for assigned patients
/// - Viewing prescriptions and medications for assigned patients
/// - Managing appointments for assigned patients
/// - Handling transportation requests for assigned patients
///
/// All operations interact with Firebase Firestore to fetch real-time data.
class ResponsibleService {
  static final ResponsibleService _instance = ResponsibleService._internal();
  factory ResponsibleService() => _instance;
  ResponsibleService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get patients assigned to this responsible person
  Future<List<PatientModel>> getPatientsForResponsible() async {
    try {
      final uid = currentUserId;
      if (uid == null) return [];

      final querySnapshot = await _firestore
          .collection('patients')
          .where('responsiblePartyId', isEqualTo: uid)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => PatientModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching patients for responsible: $e');
      return [];
    }
  }

  /// Get a specific patient's details
  Future<PatientModel?> getPatientDetails(String patientId) async {
    try {
      final docSnapshot =
          await _firestore.collection('patients').doc(patientId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return PatientModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      print('Error fetching patient details: $e');
      return null;
    }
  }

  /// Get medical records for a specific patient
  Future<List<MedicalRecordModel>> getMedicalRecordsForPatient(
      String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('mobile_medical_records')
          .where('patientId', isEqualTo: patientId)
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

  /// Get lab results for a specific patient
  Future<List<LabResultModel>> getLabResultsForPatient(String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('mobile_lab_results')
          .where('patientId', isEqualTo: patientId)
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

  /// Get prescriptions for a specific patient
  Future<List<PrescriptionModel>> getPrescriptionsForPatient(
      String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('mobile_prescriptions')
          .where('patientId', isEqualTo: patientId)
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

  /// Get active prescriptions for a specific patient
  Future<List<PrescriptionModel>> getActivePrescriptionsForPatient(
      String patientId) async {
    try {
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
      print('Error fetching active prescriptions: $e');
      return [];
    }
  }

  /// Get appointments for a specific patient
  Future<List<Map<String, dynamic>>> getAppointmentsForPatient(
      String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
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

  /// Get transportation requests for a specific patient
  Future<List<Map<String, dynamic>>> getTransportationRequestsForPatient(
      String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('transportation_requests')
          .where('patientId', isEqualTo: patientId)
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

  /// Create transportation request for a patient
  Future<bool> createTransportationRequestForPatient({
    required String patientId,
    required String pickupLocation,
    required String destination,
    required DateTime requestedTime,
    String? notes,
  }) async {
    try {
      final patient = await getPatientDetails(patientId);
      if (patient == null) return false;

      await _firestore.collection('transportation_requests').add({
        'patientId': patientId,
        'patientName': patient.name,
        'responsiblePartyId': currentUserId,
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

  /// Get dashboard statistics for responsible person
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final patients = await getPatientsForResponsible();
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
          .where('appointmentDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
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
      print('Error fetching dashboard stats: $e');
      return {
        'totalPatients': 0,
        'upcomingAppointments': 0,
        'activeMedications': 0,
        'pendingLabResults': 0,
      };
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

