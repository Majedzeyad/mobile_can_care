import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Sample Data Loader for Doctor Folder
///
/// This service loads comprehensive sample data for testing the Doctor folder.
/// It creates realistic data for all collections used by doctors.
class SampleDataLoader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Load all sample data for Doctor folder
  ///
  /// This method creates:
  /// - Doctors (if not exists)
  /// - Patients (assigned to doctors)
  /// - Nurses (for override requests)
  /// - Medications catalog
  /// - Lab test requests
  /// - Lab results
  /// - Prescriptions
  /// - Medical records
  /// - Override requests
  /// - Appointments
  Future<void> loadAllSampleData() async {
    try {
      print('[SampleDataLoader] ========================================');
      print('[SampleDataLoader] Starting to load sample data...');
      print('[SampleDataLoader] ========================================');

      // Get current user (doctor)
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('[SampleDataLoader] ❌ No user logged in');
        throw Exception('No user logged in. Please login first.');
      }

      final doctorId = currentUser.uid;
      print('[SampleDataLoader] ✅ Current doctor ID: $doctorId');
      print('[SampleDataLoader] Current user email: ${currentUser.email}');

      // 1. Create/Update Doctor Profile
      await _createDoctorProfile(doctorId);

      // 2. Create Nurses
      final nurseIds = await _createNurses();

      // 3. Create Patients (assigned to current doctor)
      final patientIds = await _createPatients(doctorId, nurseIds);

      // 4. Create Medications Catalog
      await _createMedications();

      // 5. Create Lab Test Requests
      final labRequestIds = await _createLabTestRequests(doctorId, patientIds);

      // 6. Create Lab Results
      await _createLabResults(doctorId, labRequestIds, patientIds);

      // 7. Create Prescriptions
      await _createPrescriptions(doctorId, patientIds);

      // 8. Create Medical Records
      await _createMedicalRecords(doctorId, patientIds);

      // 9. Create Override Requests
      await _createOverrideRequests(doctorId, nurseIds, patientIds);

      // 10. Create Appointments
      await _createAppointments(doctorId, patientIds);

      print('[SampleDataLoader] ========================================');
      print('[SampleDataLoader] ✅ All sample data loaded successfully!');
      print('[SampleDataLoader] ========================================');
    } catch (e, stackTrace) {
      print('[SampleDataLoader] ========================================');
      print('[SampleDataLoader] ❌ Error loading sample data: $e');
      print('[SampleDataLoader] Error type: ${e.runtimeType}');
      print('[SampleDataLoader] Stack trace: $stackTrace');
      print('[SampleDataLoader] ========================================');
      rethrow;
    }
  }

  /// Create/Update Doctor Profile
  Future<void> _createDoctorProfile(String doctorId) async {
    try {
      final doctorRef = _firestore.collection('doctors').doc(doctorId);
      final doctorDoc = await doctorRef.get();

      if (!doctorDoc.exists) {
        await doctorRef.set({
          'uid': doctorId,
          'name': 'د. أحمد محمد',
          'email': _auth.currentUser?.email ?? 'doctor@example.com',
          'phone': '+966501234567',
          'specialization': 'أورام',
          'department': 'قسم الأورام',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('[SampleDataLoader] ✅ Created doctor profile');
      } else {
        print('[SampleDataLoader] ℹ️ Doctor profile already exists');
      }
    } catch (e) {
      print('[SampleDataLoader] Error creating doctor profile: $e');
      rethrow;
    }
  }

  /// Create Nurses
  Future<List<String>> _createNurses() async {
    final nurseIds = <String>[];
    final nurses = [
      {
        'name': 'ممرضة فاطمة علي',
        'email': 'nurse1@example.com',
        'phone': '+966502345678',
        'department': 'قسم الأورام',
      },
      {
        'name': 'ممرضة سارة أحمد',
        'email': 'nurse2@example.com',
        'phone': '+966503456789',
        'department': 'قسم الأورام',
      },
    ];

    for (final nurseData in nurses) {
      try {
        // Check if nurse exists by email
        final query = await _firestore
            .collection('nurses')
            .where('email', isEqualTo: nurseData['email'])
            .limit(1)
            .get();

        String nurseId;
        if (query.docs.isEmpty) {
          // Create new nurse document
          final docRef = _firestore.collection('nurses').doc();
          nurseId = docRef.id;
          await docRef.set({
            'uid': nurseId,
            ...nurseData,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('[SampleDataLoader] ✅ Created nurse: ${nurseData['name']}');
        } else {
          nurseId = query.docs.first.id;
          print('[SampleDataLoader] ℹ️ Nurse already exists: ${nurseData['name']}');
        }
        nurseIds.add(nurseId);
      } catch (e) {
        print('[SampleDataLoader] Error creating nurse: $e');
      }
    }

    return nurseIds;
  }

  /// Create Patients
  Future<List<String>> _createPatients(
    String doctorId,
    List<String> nurseIds,
  ) async {
    final patientIds = <String>[];

    final patients = [
      {
        'name': 'محمد عبدالله',
        'dob': DateTime(1975, 5, 15),
        'gender': 'ذكر',
        'phone': '+966501111111',
        'diagnosis': 'سرطان الثدي',
        'status': 'نشط',
        'assignedNurseId': nurseIds.isNotEmpty ? nurseIds[0] : null,
      },
      {
        'name': 'فاطمة خالد',
        'dob': DateTime(1980, 8, 22),
        'gender': 'أنثى',
        'phone': '+966502222222',
        'diagnosis': 'سرطان الرئة',
        'status': 'نشط',
        'assignedNurseId': nurseIds.isNotEmpty ? nurseIds[1] : null,
      },
      {
        'name': 'علي حسن',
        'dob': DateTime(1965, 3, 10),
        'gender': 'ذكر',
        'phone': '+966503333333',
        'diagnosis': 'سرطان القولون',
        'status': 'نشط',
        'assignedNurseId': nurseIds.isNotEmpty ? nurseIds[0] : null,
      },
      {
        'name': 'سارة محمود',
        'dob': DateTime(1990, 11, 5),
        'gender': 'أنثى',
        'phone': '+966504444444',
        'diagnosis': 'سرطان الدم',
        'status': 'نشط',
        'assignedNurseId': nurseIds.isNotEmpty ? nurseIds[1] : null,
      },
    ];

    for (final patientData in patients) {
      try {
        // Check if patient exists by name
        final query = await _firestore
            .collection('patients')
            .where('name', isEqualTo: patientData['name'])
            .limit(1)
            .get();

        String patientId;
        if (query.docs.isEmpty) {
          final docRef = _firestore.collection('patients').doc();
          patientId = docRef.id;
          await docRef.set({
            'assignedDoctorId': doctorId,
            'assignedNurseId': patientData['assignedNurseId'],
            'name': patientData['name'],
            'dob': Timestamp.fromDate(patientData['dob'] as DateTime),
            'gender': patientData['gender'],
            'phone': patientData['phone'],
            'diagnosis': patientData['diagnosis'],
            'status': patientData['status'],
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('[SampleDataLoader] ✅ Created patient: ${patientData['name']}');
        } else {
          patientId = query.docs.first.id;
          // Update assigned doctor
          await query.docs.first.reference.update({
            'assignedDoctorId': doctorId,
          });
          print('[SampleDataLoader] ℹ️ Patient already exists: ${patientData['name']}');
        }
        patientIds.add(patientId);
      } catch (e) {
        print('[SampleDataLoader] Error creating patient: $e');
      }
    }

    return patientIds;
  }

  /// Create Medications Catalog
  Future<void> _createMedications() async {
    final medications = [
      {
        'name': 'باراسيتامول',
        'dosage': '500 مجم',
        'category': 'مسكنات',
      },
      {
        'name': 'إيبوبروفين',
        'dosage': '400 مجم',
        'category': 'مسكنات',
      },
      {
        'name': 'مورفين',
        'dosage': '10 مجم',
        'category': 'مسكنات قوية',
      },
      {
        'name': 'أوكسي كودون',
        'dosage': '5 مجم',
        'category': 'مسكنات قوية',
      },
      {
        'name': 'سيتوتوكسيك',
        'dosage': '50 مجم/م²',
        'category': 'علاج كيميائي',
      },
      {
        'name': 'دوكسوروبيسين',
        'dosage': '60 مجم/م²',
        'category': 'علاج كيميائي',
      },
      {
        'name': 'باسيلوكسيماب',
        'dosage': '20 مجم',
        'category': 'مثبطات المناعة',
      },
      {
        'name': 'بريدنيزون',
        'dosage': '5 مجم',
        'category': 'كورتيكوستيرويدات',
      },
    ];

    for (final medData in medications) {
      try {
        final query = await _firestore
            .collection('medications')
            .where('name', isEqualTo: medData['name'])
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          await _firestore.collection('medications').add({
            ...medData,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('[SampleDataLoader] ✅ Created medication: ${medData['name']}');
        } else {
          print('[SampleDataLoader] ℹ️ Medication already exists: ${medData['name']}');
        }
      } catch (e) {
        print('[SampleDataLoader] Error creating medication: $e');
      }
    }
  }

  /// Create Lab Test Requests
  Future<List<String>> _createLabTestRequests(
    String doctorId,
    List<String> patientIds,
  ) async {
    final requestIds = <String>[];
    final testTypes = ['CBC', 'Urinalysis', 'كوفيد-19', 'Blood Chemistry'];

    for (int i = 0; i < patientIds.length && i < 3; i++) {
      try {
        final patientId = patientIds[i];
        final testType = testTypes[i % testTypes.length];

        final docRef = _firestore.collection('mobile_lab_test_requests').doc();
        final requestId = docRef.id;

        await docRef.set({
          'doctorId': doctorId,
          'patientId': patientId,
          'testType': testType,
          'specificTest': testType == 'CBC' ? 'Complete Blood Count' : null,
          'status': i == 0 ? 'pending' : 'completed',
          'createdAt': FieldValue.serverTimestamp(),
        });

        requestIds.add(requestId);
        print('[SampleDataLoader] ✅ Created lab test request for patient $i');
      } catch (e) {
        print('[SampleDataLoader] Error creating lab test request: $e');
      }
    }

    return requestIds;
  }

  /// Create Lab Results
  Future<void> _createLabResults(
    String doctorId,
    List<String> requestIds,
    List<String> patientIds,
  ) async {
    for (int i = 0; i < requestIds.length && i < patientIds.length; i++) {
      try {
        final requestId = requestIds[i];
        final patientId = patientIds[i];

        // Check if result already exists
        final query = await _firestore
            .collection('mobile_lab_results')
            .where('requestId', isEqualTo: requestId)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          await _firestore.collection('mobile_lab_results').add({
            'doctorId': doctorId, // إضافة doctorId لربط النتيجة بالطبيب
            'requestId': requestId,
            'patientId': patientId,
            'testName': 'CBC',
            'results': {
              'testType': 'blood',
              'values': {
                'WBC': '7.5',
                'RBC': '4.8',
                'Hemoglobin': '14.2',
                'Platelets': '250',
              },
            },
            'status': 'completed',
            'doctorNotes': i == 0 ? 'النتائج طبيعية' : null,
            'notesAddedBy': i == 0 ? doctorId : null,
            'notesAddedAt': i == 0 ? FieldValue.serverTimestamp() : null,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('[SampleDataLoader] ✅ Created lab result for request $i (doctorId: $doctorId)');
        } else {
          // Update existing result to include doctorId if missing
          final existingDoc = query.docs.first;
          final existingData = existingDoc.data();
          if (existingData['doctorId'] == null) {
            await existingDoc.reference.update({
              'doctorId': doctorId,
            });
            print('[SampleDataLoader] ✅ Updated existing lab result with doctorId: $doctorId');
          } else {
            print('[SampleDataLoader] ℹ️ Lab result already exists for request $i');
          }
        }
      } catch (e) {
        print('[SampleDataLoader] Error creating lab result: $e');
      }
    }
  }

  /// Create Prescriptions
  Future<void> _createPrescriptions(
    String doctorId,
    List<String> patientIds,
  ) async {
    final medications = ['باراسيتامول', 'إيبوبروفين', 'مورفين'];

    for (int i = 0; i < patientIds.length && i < 3; i++) {
      try {
        final patientId = patientIds[i];
        final medicationName = medications[i % medications.length];

        await _firestore.collection('mobile_prescriptions').add({
          'doctorId': doctorId,
          'patientId': patientId,
          'medicationName': medicationName,
          'dosage': '500 مجم',
          'frequency': 'مرتين يومياً',
          'duration': '7 أيام',
          'instructions': 'يؤخذ بعد الأكل',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('[SampleDataLoader] ✅ Created prescription for patient $i');
      } catch (e) {
        print('[SampleDataLoader] Error creating prescription: $e');
      }
    }
  }

  /// Create Medical Records
  Future<void> _createMedicalRecords(
    String doctorId,
    List<String> patientIds,
  ) async {
    final categories = ['تشخيص', 'علاج', 'جراحة'];
    final descriptions = [
      'تشخيص أولي: سرطان الثدي في المرحلة الثانية',
      'خطة علاجية: جلسات كيميائي متعددة',
      'عملية جراحية: استئصال الورم',
    ];

    for (int i = 0; i < patientIds.length && i < 3; i++) {
      try {
        final patientId = patientIds[i];

        await _firestore.collection('mobile_medical_records').add({
          'doctorId': doctorId,
          'patientId': patientId,
          'category': categories[i % categories.length],
          'description': descriptions[i % descriptions.length],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('[SampleDataLoader] ✅ Created medical record for patient $i');
      } catch (e) {
        print('[SampleDataLoader] Error creating medical record: $e');
      }
    }
  }

  /// Create Override Requests
  Future<void> _createOverrideRequests(
    String doctorId,
    List<String> nurseIds,
    List<String> patientIds,
  ) async {
    if (nurseIds.isEmpty || patientIds.isEmpty) {
      print('[SampleDataLoader] ⚠️ No nurses or patients to create override requests');
      return;
    }

    for (int i = 0; i < 2 && i < nurseIds.length && i < patientIds.length; i++) {
      try {
        final nurseId = nurseIds[i];
        final patientId = patientIds[i];

        // Check if request already exists
        final query = await _firestore
            .collection('mobile_override_requests')
            .where('doctorId', isEqualTo: doctorId)
            .where('nurseId', isEqualTo: nurseId)
            .where('patientId', isEqualTo: patientId)
            .where('status', isEqualTo: 'pending')
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          await _firestore.collection('mobile_override_requests').add({
            'doctorId': doctorId,
            'nurseId': nurseId,
            'patientId': patientId,
            'medicationName': 'مورفين',
            'currentDosage': '5 مجم',
            'requestedDosage': '10 مجم',
            'reason': 'المريض يعاني من ألم شديد ويحتاج جرعة أعلى',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('[SampleDataLoader] ✅ Created override request $i');
        } else {
          print('[SampleDataLoader] ℹ️ Override request already exists $i');
        }
      } catch (e) {
        print('[SampleDataLoader] Error creating override request: $e');
      }
    }
  }

  /// Create Appointments
  Future<void> _createAppointments(
    String doctorId,
    List<String> patientIds,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Create appointments for today and next few days
    for (int i = 0; i < patientIds.length && i < 3; i++) {
      try {
        final patientId = patientIds[i];
        final appointmentDate = today.add(Duration(days: i));
        final dateString = '${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}';
        final timeString = '${9 + i}:00';

        // Get patient name
        final patientDoc = await _firestore.collection('patients').doc(patientId).get();
        final patientName = patientDoc.data()?['name'] ?? 'مريض';

        // Check if appointment already exists
        final query = await _firestore
            .collection('web_appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('patientId', isEqualTo: patientId)
            .where('date', isEqualTo: dateString)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          await _firestore.collection('web_appointments').add({
            'doctorId': doctorId,
            'patientId': patientId,
            'patientName': patientName,
            'date': dateString,
            'time': timeString,
            'appointmentDate': Timestamp.fromDate(appointmentDate.add(Duration(hours: 9 + i))),
            'status': 'scheduled',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('[SampleDataLoader] ✅ Created appointment for patient $i');
        } else {
          print('[SampleDataLoader] ℹ️ Appointment already exists for patient $i');
        }
      } catch (e) {
        print('[SampleDataLoader] Error creating appointment: $e');
      }
    }
  }
}
