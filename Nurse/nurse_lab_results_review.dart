import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_patient_management.dart';
import 'nurse_profile.dart';
import 'nurse_publication.dart';

/// Nurse Lab Results Review Page
///
/// This page allows nurses to review lab test results for patients. Features include:
/// - Patient profile information with assigned doctor and nurse
/// - List of lab test results with status indicators (Normal, Abnormal, Positive, Pending)
/// - Test details showing specific findings and values
/// - Doctor-nurse coordination information (who ordered vs. who reviewed)
/// - Override and note-taking capabilities for nurses
/// - Download functionality for lab result documents (when available)
/// - Support for multi-role scenarios (doctors who are also patients)
///
/// The page helps nurses review and manage lab results, take appropriate actions,
/// and coordinate with doctors on patient care decisions.
class NurseLabResultsReview extends StatefulWidget {
  const NurseLabResultsReview({super.key});

  @override
  State<NurseLabResultsReview> createState() => _NurseLabResultsReviewState();
}

/// State class for Nurse Lab Results Review Page
///
/// Manages:
/// - Current navigation index
/// - Patient information
/// - List of lab test results with review and override capabilities
/// - UI state and interactions
class _NurseLabResultsReviewState extends State<NurseLabResultsReview> {
  /// Current navigation index (0 for this page)
  int _currentIndex = 0;

  // TODO: Connect Firebase - Fetch from 'patients' collection
  // Patient with assigned doctor and nurse
  /// Patient profile information
  /// Contains: name, age, patientId, assignedDoctor, assignedNurse, image
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Kyle Smith',
    'age': '25',
    'patientId': 'P-456789',
    'assignedDoctor': 'Dr. Robert Smith',
    'assignedNurse': 'Olivia Thompson (You)',
    'image': '', // todo: Load from Firebase Storage
  };

  // TODO: Connect Firebase - Fetch from 'labResults' collection
  // Lab results showing doctor-nurse-patient relationships
  // Tests are ordered by doctors, reviewed by nurses
  /// List of lab test results with review and action tracking
  /// Each result contains: testName, status, details, orderedBy (doctor),
  /// reviewedBy (nurse), date, image (icon type), downloadUrl, buttonText (Override/Add Note),
  /// optional note
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _labResults = [
    {
      'testName': 'CBC Test',
      'status': 'Abnormal',
      'details': 'WBC count elevated (12.5 x 10^9/L, normal: 4.0-11.0)',
      'orderedBy': 'Dr. Robert Smith',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': '2024-02-14',
      'image': 'test_tube', // Placeholder for image type
      'downloadUrl': '', // todo: Firebase Storage URL
      'buttonText': 'Override',
    },
    {
      'testName': 'Urinalysis',
      'status': 'Normal',
      'details':
          'No abnormalities detected. All parameters within normal range.',
      'orderedBy': 'Dr. Robert Smith',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': '2024-02-14',
      'image': 'medicine_bottle', // Placeholder
      'downloadUrl': '',
      'buttonText': 'Add Note',
    },
    {
      'testName': 'Blood Glucose',
      'status': 'Abnormal',
      'details':
          'Fasting glucose: 180 mg/dL (normal: 70-100). Patient: Jane Cooper (P-123456)',
      'orderedBy': 'Dr. Robert Smith',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': '2024-02-15',
      'image': 'test_tube',
      'downloadUrl': '',
      'buttonText': 'Override',
    },
    {
      'testName': 'EKG',
      'status': 'Pending',
      'details':
          'Awaiting cardiology review. Patient: Dr. Priya Patel (P-DOC-001)',
      'orderedBy': 'Dr. Emily Chen',
      'reviewedBy': 'Sarah Johnson',
      'date': '2024-02-15',
      'image': 'ekg_graph', // Placeholder
      'downloadUrl': '',
      'buttonText': 'Override',
      'note': 'Dr. Patel is also a patient',
    },
    {
      'testName': 'Strep Test',
      'status': 'Positive',
      'details':
          'Group A Streptococcus detected. Requires antibiotics. Patient: Kyle Smith',
      'orderedBy': 'Dr. Robert Smith',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': '2024-02-15',
      'image': 'test_swab', // Placeholder
      'downloadUrl': '',
      'buttonText': 'Add Note',
    },
    {
      'testName': 'HbA1c',
      'status': 'Abnormal',
      'details': 'HbA1c: 8.5% (target: <7%). Patient: Jane Cooper (P-123456)',
      'orderedBy': 'Dr. Robert Smith',
      'reviewedBy': 'Olivia Thompson (You)',
      'date': '2024-02-15',
      'image': 'test_tube',
      'downloadUrl': '',
      'buttonText': 'Override',
    },
  ];

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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Lab Results Review',
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
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Patient profile card
                    _buildPatientProfileCard(),
                    const SizedBox(height: 24),
                    // Lab results list
                    ..._labResults.map((result) => _buildLabResultCard(result)),
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

  Widget _buildPatientProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                _patient['image'] != null && _patient['image'].isNotEmpty
                ? NetworkImage(_patient['image'])
                : null,
            child: _patient['image'] == null || _patient['image'].isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patient['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_patient['age']} years | ${_patient['patientId']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultCard(Map<String, dynamic> result) {
    IconData iconData;
    Color statusColor;

    // Determine icon and color based on status
    switch (result['status'].toLowerCase()) {
      case 'abnormal':
        iconData = Icons.science;
        statusColor = Colors.orange;
        break;
      case 'positive':
        iconData = Icons.medication;
        statusColor = Colors.red;
        break;
      case 'pending':
        iconData = Icons.pending;
        statusColor = Colors.blue;
        break;
      default:
        iconData = Icons.check_circle;
        statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result['testName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${result['status']}',
                      style: TextStyle(fontSize: 14, color: statusColor),
                    ),
                  ],
                ),
              ),
              // Image placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getImageIcon(result['image']),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result['details'],
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  if (result['buttonText'] == 'Override') {
                    // todo: Connect Firebase - Override lab result
                  } else {
                    // todo: Connect Firebase - Add note to lab result
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Text(result['buttonText']),
              ),
              GestureDetector(
                onTap: () {
                  // todo: Connect Firebase - Download lab result from Firebase Storage
                  if (result['downloadUrl'] != null &&
                      result['downloadUrl'].isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading...')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No file available')),
                    );
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.download, size: 16, color: Color(0xFF6B46C1)),
                    SizedBox(width: 4),
                    Text(
                      'Download',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B46C1)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getImageIcon(String imageType) {
    switch (imageType) {
      case 'test_tube':
        return Icons.science;
      case 'medicine_bottle':
        return Icons.medication;
      case 'ekg_graph':
        return Icons.favorite;
      case 'test_swab':
        return Icons.medical_services;
      default:
        return Icons.image;
    }
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
            destination = const NursePublication(); // Message/Publication page
            break;
          case 4:
            destination = const NursePatientManagement();
            break;
          case 5:
            destination = const NurseProfile(); // Account/Profile
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
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}
