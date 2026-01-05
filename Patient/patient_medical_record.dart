import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import 'patient_profile.dart';

/// Patient Medical Record Page
///
/// This page displays comprehensive medical record information for the currently
/// logged-in patient. Features include:
/// - Patient personal information (name, national ID, age, gender, allergies)
/// - Current diagnosis and treatment plan
/// - Medical history (chronic conditions, previous surgeries, family history)
/// - Lifestyle information
/// - Lab results with values and status indicators
/// - Search functionality to find specific records
///
/// The page provides patients with complete access to their medical history,
/// allowing them to review diagnoses, treatments, and test results in one place.
class PatientMedicalRecord extends StatefulWidget {
  const PatientMedicalRecord({super.key});

  @override
  State<PatientMedicalRecord> createState() => _PatientMedicalRecordState();
}

/// State class for Patient Medical Record Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Search controller for filtering records
/// - Patient information
/// - Diagnosis and treatment plan data
/// - Medical history information
/// - Lab results list
/// - UI state and interactions
class _PatientMedicalRecordState extends State<PatientMedicalRecord> {
  /// Current selected tab index in bottom navigation bar (Records tab = 3)
  int _currentIndex = 3;
  
  /// Controller for the search text field to filter medical records
  final TextEditingController _searchController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'patients' collection
  /// Patient personal information
  /// Contains: name, nationalId, age, gender, allergies, doctor, image
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Emily Johnson',
    'nationalId': '2000156936',
    'age': '56',
    'gender': 'Female',
    'allergies': 'None',
    'doctor': 'Dr. Ahmed Kareem',
    'image': '', // todo: Load from Firebase Storage
  };

  // TODO: Connect Firebase - Fetch from 'medicalRecords' collection
  /// Current diagnosis information
  /// Contains: condition, dateDiagnosed, treatmentPlan
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _diagnosis = {
    'condition': 'Breast Cancer (Stage 2)',
    'dateDiagnosed': 'October 15, 2024',
    'treatmentPlan': 'Chemotherapy',
  };

  // TODO: Connect Firebase - Fetch from 'medicalRecords' collection
  /// Medical history information
  /// Contains: chronicConditions, previousSurgeries, familyHistory
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _medicalHistory = {
    'chronicConditions': 'Hypertension',
    'previousSurgeries': 'Breast Lumpectomy (December 2024)',
    'familyHistory': 'Mother (Breast Cancer), Father (Heart Disease)',
  };

  /// Lifestyle information (smoking status, exercise habits, etc.)
  /// Currently using dummy data, should be fetched from Firebase in production
  final String _lifestyle = 'Non-smoker, Moderate exercise';

  // TODO: Connect Firebase - Fetch from 'labResults' collection
  /// List of lab test results
  /// Each result contains: test, value, status
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _labResults = [
    {
      'test': 'White Blood Cell Count (WBC)',
      'value': '3,200/µL',
      'status': 'Low - Common After Chemo',
    },
    {
      'test': 'Hemoglobin',
      'value': '10.5 g/dL',
      'status': 'Slightly Low - Monitor for Fatigue',
    },
  ];

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the patient medical record UI with comprehensive health information.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title and search functionality
  /// - Patient information card with personal details
  /// - Diagnosis section with condition and treatment plan
  /// - Medical history section (chronic conditions, surgeries, family history)
  /// - Lifestyle information
  /// - Lab results section with test values and status indicators
  /// - Organized sections for easy navigation
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient medical record UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                          'Medical record',
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
                        hintText: 'Search',
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
            destination = const PatientDashboard();
            break;
          case 1:
            destination = const PatientMedicationManagement();
            break;
          case 2:
            destination =
                const PatientPublication(); // Message/Publication page
            break;
          case 3:
            // Already on Record (Medical Record) page
            return;
          case 4:
            destination = const PatientProfile();
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
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Record'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
