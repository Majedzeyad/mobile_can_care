import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_profile.dart';

/// Nurse Medical Record Page
///
/// This page displays comprehensive medical record information for a patient from
/// the nurse's perspective. Features include:
/// - Patient profile information (name, ID, age, gender, allergies, assigned doctor and nurse)
/// - Current diagnosis and treatment plan
/// - Medical history (chronic conditions, previous surgeries, family history)
/// - Lifestyle information
/// - Lab results with values, status indicators, and review information
/// - Search functionality to find specific records
///
/// The page helps nurses access detailed patient information needed for care
/// coordination, monitoring treatment progress, and reviewing test results.
class NurseMedicalRecord extends StatefulWidget {
  const NurseMedicalRecord({super.key});

  @override
  State<NurseMedicalRecord> createState() => _NurseMedicalRecordState();
}

/// State class for Nurse Medical Record Page
///
/// Manages:
/// - Current navigation index
/// - Search controller for filtering records
/// - Patient information
/// - Diagnosis and treatment plan data
/// - Medical history information
/// - Lab results list
/// - UI state and interactions
class _NurseMedicalRecordState extends State<NurseMedicalRecord> {
  /// Current navigation index (3 for medical records)
  int _currentIndex = 3;
  
  /// Controller for the search text field to filter medical records
  final TextEditingController _searchController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'patients' collection
  // Patient: Sarah Ahmed (P-345678) - Breast Cancer patient
  // Assigned to Dr. Priya Patel and Nurse Olivia Thompson
  /// Patient profile information
  /// Contains: name, patientId, nationalId, age, gender, allergies,
  /// assignedDoctor, assignedNurse, image
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Sarah Ahmed',
    'patientId': 'P-345678',
    'nationalId': '2000156936',
    'age': '34',
    'gender': 'Female',
    'allergies': 'None',
    'assignedDoctor': 'Dr. Priya Patel',
    'assignedNurse': 'Olivia Thompson (You)',
    'image': '', // todo: Load from Firebase Storage
  };

  // TODO: Connect Firebase - Fetch from 'medicalRecords' collection
  // Diagnosis made by doctor, record maintained by nurse
  /// Current diagnosis information with treatment plan
  /// Contains: condition, dateDiagnosed, diagnosedBy (doctor), treatmentPlan,
  /// monitoredBy (nurse)
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _diagnosis = {
    'condition': 'Breast Cancer (Stage 2)',
    'dateDiagnosed': 'January 10, 2024',
    'diagnosedBy': 'Dr. Priya Patel',
    'treatmentPlan': 'Chemotherapy + Radiation',
    'monitoredBy': 'Olivia Thompson (You)',
  };

  // TODO: Connect Firebase - Fetch from 'medicalRecords' collection
  /// Medical history information with record tracking
  /// Contains: chronicConditions, previousSurgeries, familyHistory,
  /// recordedBy (doctor), lastUpdated, updatedBy (nurse)
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _medicalHistory = {
    'chronicConditions': 'None',
    'previousSurgeries': 'Breast Lumpectomy (January 25, 2024)',
    'familyHistory':
        'Mother (Breast Cancer at age 52), Maternal Aunt (Ovarian Cancer)',
    'recordedBy': 'Dr. Priya Patel',
    'lastUpdated': 'February 1, 2024',
    'updatedBy': 'Olivia Thompson (You)',
  };

  /// Lifestyle information (smoking status, exercise habits, diet, etc.)
  /// Currently using dummy data, should be fetched from Firebase in production
  final String _lifestyle =
      'Non-smoker, Moderate exercise (3x/week), Healthy diet';

  // TODO: Connect Firebase - Fetch from 'labResults' collection
  // Lab results ordered by doctor, reviewed by nurse
  /// List of lab test results with review tracking
  /// Each result contains: test, value, status, orderedBy (doctor),
  /// reviewedBy (nurse), date
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _labResults = [
    {
      'test': 'White Blood Cell Count (WBC)',
      'value': '3,200/µL',
      'status': 'Low - Common After Chemo',
      'orderedBy': 'Dr. Priya Patel',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': 'February 10, 2024',
    },
    {
      'test': 'Hemoglobin',
      'value': '10.5 g/dL',
      'status': 'Slightly Low - Monitor For Fatigue',
      'orderedBy': 'Dr. Priya Patel',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': 'February 10, 2024',
    },
    {
      'test': 'CA 15-3 (Tumor Marker)',
      'value': '28 U/mL',
      'status': 'Elevated - Continue Monitoring',
      'orderedBy': 'Dr. Priya Patel',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': 'February 10, 2024',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:53',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_4_bar,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.battery_full,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Medical Records',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B46C1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF6B46C1)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Q Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        // todo: Filter medical records by search query
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Patient summary card
                    _buildPatientSummaryCard(),
                    const SizedBox(height: 16),
                    // Diagnosis card
                    _buildDiagnosisCard(),
                    const SizedBox(height: 16),
                    // Medical history card
                    _buildMedicalHistoryCard(),
                    const SizedBox(height: 16),
                    // Lifestyle card
                    _buildLifestyleCard(),
                    const SizedBox(height: 16),
                    // Lab results card
                    _buildLabResultsCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildPatientSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child:
                _patient['image'] != null && _patient['image'].isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        _patient['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                    : const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoText('Name', _patient['name']),
                const SizedBox(height: 4),
                _buildInfoText('National Id', _patient['nationalId']),
                const SizedBox(height: 4),
                _buildInfoText('Age', _patient['age']),
                const SizedBox(height: 4),
                _buildInfoText('Gender', _patient['gender']),
                const SizedBox(height: 4),
                _buildInfoText('Allergies', _patient['allergies']),
                const SizedBox(height: 4),
                _buildInfoText('Dr.', _patient['doctor']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Text('$label: $value', style: const TextStyle(fontSize: 12));
  }

  Widget _buildDiagnosisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnosis:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Condition: ${_diagnosis['condition']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Date Diagnosed: ${_diagnosis['dateDiagnosed']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Current Treatment Plan: ${_diagnosis['treatmentPlan']}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical History:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Chronic Conditions: ${_medicalHistory['chronicConditions']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Previous Surgeries: ${_medicalHistory['previousSurgeries']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Family History: ${_medicalHistory['familyHistory']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text('Lifestyle: $_lifestyle', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLifestyleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(_lifestyle, style: const TextStyle(fontSize: 14))],
      ),
    );
  }

  Widget _buildLabResultsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Lab Test Results:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._labResults.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result['test']}: ${result['value']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '(${result['status']})',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        // Navigate to different pages based on index
        Widget? destination;
        switch (index) {
          case 0:
            destination = const NurseDashboard();
            break;
          case 1:
            destination = const NurseAppointmentManagement();
            break;
          case 2:
            destination = const NurseMedicationManagement();
            break;
          case 3:
            // Already on Record (Medical Record) page
            return;
          case 4:
            destination = const NurseProfile();
            break;
        }

        if (destination != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination!),
          );
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6B46C1),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Record'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
