import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nurse_model.dart';
import '../models/patient_model.dart';

/// Service for nurse-related Firestore operations
/// This service handles all nurse-specific data operations
class NurseService {
  static NurseService? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NurseService._();

  static NurseService get instance {
    _instance ??= NurseService._();
    return _instance!;
  }

  /// Get current nurse UID
  String? get currentNurseId => _auth.currentUser?.uid;

  /// Get nurse profile from Firestore
  Future<NurseModel?> getNurseProfile() async {
    try {
      final nurseId = currentNurseId;
      if (nurseId == null) return null;

      // Try to find nurse by uid field in nurses collection
      final querySnapshot = await _firestore
          .collection('nurses')
          .where('uid', isEqualTo: nurseId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Try direct document access
        final docSnapshot = await _firestore.collection('nurses').doc(nurseId).get();
        if (!docSnapshot.exists) return null;
        return NurseModel.fromJson(docSnapshot.data()!, nurseId);
      }

      final doc = querySnapshot.docs.first;
      return NurseModel.fromJson(doc.data(), doc.id);
    } catch (e) {
      print('Error fetching nurse profile: $e');
      return null;
    }
  }

  /// Get patients assigned to current nurse
  Future<List<Map<String, dynamic>>> getPatientsForNurse() async {
    try {
      final nurseId = currentNurseId;
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
      print('Error fetching patients: $e');
      return [];
    }
  }

  /// Create override request (nurse requests doctor approval)
  Future<void> createOverrideRequest(Map<String, dynamic> data) async {
    try {
      final nurseId = currentNurseId;
      if (nurseId == null) throw Exception('No nurse logged in');

      await _firestore.collection('mobile_override_requests').add({
        'nurseId': nurseId,
        'doctorId': data['doctorId'],
        'patientId': data['patientId'],
        'medicationName': data['medicationName'],
        'currentDosage': data['currentDosage'],
        'requestedDosage': data['requestedDosage'],
        'reason': data['reason'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating override request: $e');
      rethrow;
    }
  }

  /// Get appointments for nurse
  Future<List<Map<String, dynamic>>> getAppointmentsForNurse() async {
    try {
      final nurseId = currentNurseId;
      if (nurseId == null) return [];

      // Fetch appointments where nurse is assigned
      // Note: You may need to adjust based on your appointments structure
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
      print('Error fetching appointments: $e');
      return [];
    }
  }

  /// Update medication order status
  Future<void> updateMedicationOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('mobile_medication_orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating medication order: $e');
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
}

