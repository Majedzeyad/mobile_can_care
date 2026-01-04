import 'package:flutter/material.dart';
import 'patient_medical_record.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';

/// Patient Profile Page
///
/// This page displays comprehensive patient profile information for the currently
/// logged-in patient. Features include:
/// - Personal information (name, patient ID, national ID, age, gender)
/// - Assigned doctor information
/// - Current medications list with dosage and frequency
/// - Current medical condition/status
/// - Emergency contact information
/// - Medical documents (scans, reports, etc.)
/// - Profile image display
///
/// The page allows patients to view their complete medical profile and access
/// important health information in one place.
class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

/// State class for Patient Profile Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Patient profile data
/// - Medications list
/// - Contact information
/// - Documents list
/// - UI state and interactions
class _PatientProfileState extends State<PatientProfile> {
  /// Current selected tab index in bottom navigation bar (Profile tab = 4)
  int _currentIndex = 4;

  // TODO: Connect Firebase - Fetch patient data from 'patients' collection
  /// Patient profile information containing personal details
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Emily Johnson',
    'patientId': 'C102345',
    'nationalId': '2000458291',
    'age': '56',
    'gender': 'Female',
    'doctor': 'Dr. Ahmed Kareem',
    'image': '', // todo: Load from Firebase Storage
  };

  // TODO: Connect Firebase - Fetch from 'prescriptions' collection
  /// List of current medications prescribed to the patient
  /// Each medication contains: name, dosage, frequency
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Cyclophosphamide',
      'dosage': '50mg',
      'frequency': 'Once daily for 5 days',
    },
    {
      'name': 'Tamoxifen',
      'dosage': '10mg',
      'frequency': 'Daily hormone therapy',
    },
    {
      'name': 'Ondansetron',
      'dosage': '8mg',
      'frequency': 'As needed for nausea',
    },
  ];

  // TODO: Connect Firebase - Fetch from 'medicalRecords' collection
  /// Current medical condition/status description for the patient
  /// Currently using dummy data, should be fetched from Firebase in production
  final String _currentCondition = 'Stable, undergoing chemotherapy (10mg)';

  // TODO: Connect Firebase - Fetch from patient contact info
  /// Emergency contact information
  /// Contains: name, relation, phone, email
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _contact = {
    'name': 'Sarah Johnson',
    'relation': 'Daughter',
    'phone': '+962-77-456-7890',
    'email': 'emilyjohnson@example.com',
  };

  // TODO: Connect Firebase - Fetch from 'documents' collection or Firebase Storage
  /// List of medical documents (scans, reports, etc.) associated with the patient
  /// Each document contains: name, url (Firebase Storage URL)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _documents = [
    {
      'name': 'MRI Scan Report (March 2025)',
      'url': '', // todo: Firebase Storage URL
    },
  ];

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
                    '9:41',
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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile',
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
                    onPressed: () {
                      // Navigate to Publication/Message page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientPublication(),
                        ),
                      );
                    },
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
                    // Patient photo
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child:
                          _patient['image'] != null &&
                              _patient['image'].isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _patient['image'],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 24),
                    // Patient information card
                    _buildPatientInfoCard(),
                    const SizedBox(height: 16),
                    // Active medications card
                    _buildMedicationsCard(),
                    const SizedBox(height: 16),
                    // Current condition card
                    _buildConditionCard(),
                    const SizedBox(height: 16),
                    // Contact information card
                    _buildContactCard(),
                    const SizedBox(height: 16),
                    // Documents card
                    _buildDocumentsCard(),
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

  Widget _buildPatientInfoCard() {
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
          _buildInfoRow('Name', _patient['name']),
          const SizedBox(height: 12),
          _buildInfoRow('Patient ID', '#${_patient['patientId']}'),
          const SizedBox(height: 12),
          _buildInfoRow('National Id', _patient['nationalId']),
          const SizedBox(height: 12),
          _buildInfoRow('Age', _patient['age']),
          const SizedBox(height: 12),
          _buildInfoRow('Gender', _patient['gender']),
          const SizedBox(height: 12),
          _buildInfoRow('Dr.', _patient['doctor']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsCard() {
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
            'Active Medications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._medications.map(
            (med) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${med['name']} (${med['dosage']}) - ${med['frequency']}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard() {
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
            'Current Condition:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(_currentCondition, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // todo: Navigate to medical record page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientMedicalRecord(),
                ),
              );
            },
            icon: const Icon(Icons.description, size: 16),
            label: const Text('medical record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6B46C1),
              side: const BorderSide(color: Color(0xFF6B46C1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
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
            'Contact Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            '${_contact['name']} (${_contact['relation']}) 📞 ${_contact['phone']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text('📧 ${_contact['email']}', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard() {
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
            'Documents & Reports',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._documents.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doc['name'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // todo: Connect Firebase - Download document from Firebase Storage
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      foregroundColor: Colors.white,
                    ),
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
            destination = const PatientMedicalRecord(); // Record page
            break;
          case 4:
            // Already on Profile page
            return;
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
