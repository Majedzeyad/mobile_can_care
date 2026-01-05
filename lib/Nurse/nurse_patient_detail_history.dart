import 'package:flutter/material.dart';

/// Nurse Patient Detail History Page
///
/// This page displays comprehensive medical history for a patient from the nurse's
/// perspective. Features include:
/// - Patient profile information
/// - Medical history sections with expandable details (diagnosis, treatment, lifestyle)
/// - Current status sections with expandable details (medications, lab results)
/// - Documents section with access to patient documents
///
/// The page helps nurses review patient medical history, understand current status,
/// and access relevant documentation for informed patient care.
class NursePatientDetailHistory extends StatefulWidget {
  const NursePatientDetailHistory({super.key});

  @override
  State<NursePatientDetailHistory> createState() =>
      _NursePatientDetailHistoryState();
}

/// State class for Nurse Patient Detail History Page
///
/// Manages:
/// - Current navigation index
/// - Patient information
/// - Expanded state for medical history sections
/// - Medical history data (diagnosis, treatment, lifestyle)
/// - Expanded state for current status sections
/// - Current status data (medications, lab results)
/// - Documents list
/// - UI state and interactions
class _NursePatientDetailHistoryState extends State<NursePatientDetailHistory> {
  /// Current navigation index (4 for this page)
  int _currentIndex = 4;

  // TODO: Connect Firebase - Fetch from 'patients' collection
  /// Patient profile information
  /// Contains: name, patientId, age, image
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Jane Cooper',
    'patientId': 'P-123456',
    'age': '45 years',
    'image': '', // todo: Load from Firebase Storage
  };

  // TODO: Connect Firebase - Fetch from 'medicalRecords' collection
  /// Map tracking which medical history sections are expanded
  /// Keys: 'diagnosis', 'treatment', 'lifestyle'
  /// Currently using dummy data, should be managed based on user interactions
  final Map<String, bool> _expandedHistory = {
    'diagnosis': false,
    'treatment': false,
    'lifestyle': false,
  };

  /// Medical history data
  /// Contains: diagnosis, treatmentHistory, lifestyle
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _medicalHistory = {
    'diagnosis': 'Hypertension, Type 2 Diabetes',
    'treatmentHistory': 'Insulin, Metformin',
    'lifestyle': 'Non-smoker, Moderate Exercise',
  };

  // TODO: Connect Firebase - Fetch from 'prescriptions' and 'labResults' collections
  /// Map tracking which current status sections are expanded
  /// Keys: 'medications', 'labResults'
  /// Currently using dummy data, should be managed based on user interactions
  final Map<String, bool> _expandedStatus = {
    'medications': false,
    'labResults': false,
  };

  /// Current status data
  /// Contains: activeMedications, recentLabResults
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _currentStatus = {
    'activeMedications': 'Amoxicillin - 500mg, Ibuprofen - 200mg',
    'recentLabResults': 'CBC, Urinalysis',
  };

  // TODO: Connect Firebase - Fetch from 'documents' collection
  /// List of patient documents
  /// Each document contains: title, icon
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _documents = [
    {'title': 'Consent Forms', 'icon': Icons.description},
    {'title': 'Admission Records', 'icon': Icons.folder},
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
                    '9:50',
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
                      'Patient Details',
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
            // Patient summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _patient['image'] != null &&
                                _patient['image'].isNotEmpty
                            ? NetworkImage(_patient['image'])
                            : null,
                    child:
                        _patient['image'] == null || _patient['image'].isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _patient['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_patient['patientId']} | ${_patient['age']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medical History
                    const Text(
                      'Medical History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableItem(
                      'Diagnosis',
                      Icons.medical_services,
                      _medicalHistory['diagnosis'],
                      'diagnosis',
                    ),
                    const SizedBox(height: 8),
                    _buildExpandableItem(
                      'Treatment History',
                      Icons.medication,
                      _medicalHistory['treatmentHistory'],
                      'treatment',
                    ),
                    const SizedBox(height: 8),
                    _buildExpandableItem(
                      'Lifestyle and Habits',
                      Icons.fitness_center,
                      _medicalHistory['lifestyle'],
                      'lifestyle',
                    ),
                    const SizedBox(height: 24),
                    // Current Status
                    const Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableItem(
                      'Active Medications',
                      Icons.medication,
                      _currentStatus['activeMedications'],
                      'medications',
                    ),
                    const SizedBox(height: 8),
                    _buildExpandableItem(
                      'Recent Lab Results',
                      Icons.science,
                      _currentStatus['recentLabResults'],
                      'labResults',
                    ),
                    const SizedBox(height: 24),
                    // Documents
                    const Text(
                      'Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._documents.map((doc) => _buildDocumentItem(doc)),
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

  Widget _buildExpandableItem(
    String title,
    IconData icon,
    String content,
    String key,
  ) {
    final isExpanded = _expandedHistory[key] ?? _expandedStatus[key] ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (_expandedHistory.containsKey(key)) {
                  _expandedHistory[key] = !isExpanded;
                } else {
                  _expandedStatus[key] = !isExpanded;
                }
              });
            },
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6B46C1), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(content, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(document['icon'], color: const Color(0xFF6B46C1), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              document['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // todo: Navigate to document details
            },
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
        // todo: Navigate to different pages
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
