import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';

/// Patient Lab Results Review Page
///
/// This page displays all lab test results for the currently logged-in patient.
/// Features include:
/// - Patient profile information (name, age, patient ID)
/// - List of lab test results with status indicators (Normal, Abnormal, Positive, Pending)
/// - Test details showing specific findings
/// - Download functionality for lab result documents (when available)
/// - Visual indicators for different test types (blood tests, urinalysis, EKG, etc.)
///
/// The page allows patients to review their lab results, understand their health
/// status, and access downloadable copies of test reports.
class PatientLabResultsReview extends StatefulWidget {
  const PatientLabResultsReview({super.key});

  @override
  State<PatientLabResultsReview> createState() =>
      _PatientLabResultsReviewState();
}

/// State class for Patient Lab Results Review Page
///
/// Manages:
/// - Current navigation index
/// - Patient information
/// - List of lab test results with status and details
/// - UI state and interactions
class _PatientLabResultsReviewState extends State<PatientLabResultsReview> {
  /// Current navigation index (0 for this page)
  int _currentIndex = 0;

  // TODO: Connect Firebase - Fetch from 'patients' collection
  /// Patient profile information
  /// Contains: name, age, patientId, image
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Kyle Smith',
    'age': '25',
    'patientId': 'P-123456',
    'image': '', // todo: Load from Firebase Storage
  };

  // TODO: Connect Firebase - Fetch from 'labResults' collection
  /// List of lab test results for the patient
  /// Each result contains: testName, status (Normal/Abnormal/Positive/Pending),
  /// details (specific findings), image (icon type), downloadUrl (Firebase Storage URL)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _labResults = [
    {
      'testName': 'CBC Test',
      'status': 'Abnormal',
      'details': 'WBC count elevated',
      'image': 'test_tube', // Placeholder for image type
      'downloadUrl': '', // todo: Firebase Storage URL
    },
    {
      'testName': 'Urinalysis',
      'status': 'Normal',
      'details': 'No abnormalities',
      'image': 'medicine_bottle', // Placeholder
      'downloadUrl': '',
    },
    {
      'testName': 'EKG',
      'status': 'Pending',
      'details': 'Awaiting review',
      'image': 'ekg_graph', // Placeholder
      'downloadUrl': '',
    },
    {
      'testName': 'Strep Test',
      'status': 'Positive',
      'details': 'Requires antibiotics',
      'image': 'test_swab', // Placeholder
      'downloadUrl': '',
    },
  ];

  /// Builds the patient lab results review UI with results list and download options.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title and back button
  /// - Patient profile card with name, age, and ID
  /// - Lab results list with status indicators and color coding
  /// - Test details and findings for each result
  /// - Download buttons for available result documents
  /// - Visual icons representing different test types
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient lab results review UI
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
            child:
                _patient['image'] == null || _patient['image'].isEmpty
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
              OutlinedButton.icon(
                onPressed: () {
                  // todo: Connect Firebase - Download lab result from Firebase Storage
                  if (result['downloadUrl'] != null &&
                      result['downloadUrl'].isNotEmpty) {
                    // Implement download logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading...')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No file available')),
                    );
                  }
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // todo: Show more details or navigate to detail page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Showing details for ${result['testName']}',
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Show More',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B46C1)),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Color(0xFF6B46C1),
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
