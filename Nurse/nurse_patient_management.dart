import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_publication.dart';
import 'nurse_profile.dart';
import 'nurse_patient_detail.dart';

/// Nurse Patient Management Page
///
/// This page provides comprehensive patient management functionality for nurses.
/// Features include:
/// - Emergency patient alerts with immediate action requirements
/// - New patient notifications
/// - Patient list organized by priority (High, Medium, Routine)
/// - Search functionality to quickly find specific patients
/// - Patient cards showing condition, status, assigned doctor, and nurse
/// - Support for multi-role scenarios (doctors/nurses who are also patients)
/// - Bottom navigation to access other nurse-related pages
///
/// The page helps nurses prioritize patient care and manage their assigned
/// patients efficiently, with special emphasis on emergency situations.
class NursePatientManagement extends StatefulWidget {
  const NursePatientManagement({super.key});

  @override
  State<NursePatientManagement> createState() => _NursePatientManagementState();
}

/// State class for Nurse Patient Management Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Search controller for filtering patients
/// - Emergency patient information
/// - New patient information
/// - Patients organized by priority level
/// - UI interactions and navigation
class _NursePatientManagementState extends State<NursePatientManagement> {
  /// Current selected tab index in bottom navigation bar (Patients tab = 4)
  int _currentIndex = 4;
  
  /// Controller for the search text field to filter patients
  final TextEditingController _searchController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'patients' collection
  // Emergency patient - showing nurse-doctor coordination
  /// Emergency patient requiring immediate attention
  /// Contains critical information: name, age, patientId, condition, message,
  /// assignedDoctor, assignedNurse, room
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _emergencyPatient = {
    'name': 'Adam Khaled',
    'age': '54',
    'patientId': 'P-789012',
    'condition': 'Severe Chest Pain (Possible Heart Attack)',
    'message':
        'Immediate action required. Contact family and prepare for cardiology consult.',
    'assignedDoctor': 'Dr. Robert Smith',
    'assignedNurse': 'Olivia Thompson (You)',
    'room': 'ICU-301',
  };

  // TODO: Connect Firebase - Fetch from 'patients' collection
  // New patient - showing nurse-doctor assignment
  /// Newly assigned patient information
  /// Contains: name, age, patientId, condition, type, assignedDoctor, assignedNurse
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _newPatient = {
    'name': 'Sarah Ahmed',
    'age': '34',
    'patientId': 'P-345678',
    'condition': 'Breast Cancer',
    'type': 'Follow-up for initial consultation and treatment planning.',
    'assignedDoctor': 'Dr. Priya Patel',
    'assignedNurse': 'Olivia Thompson (You)',
  };

  // TODO: Connect Firebase - Fetch from 'patients' collection
  /// Priority section mapping for organizing patients
  /// Maps display names to priority keys: 'High Priority', 'Medium Priority', 'Routine Priority'
  final Map<String, String> _prioritySections = {
    'High Priority': 'high',
    'Medium Priority': 'medium',
    'Routine Priority': 'routine',
  };

  // TODO: Connect Firebase - Fetch from 'patients' collection
  // Comprehensive patient list showing nurse-doctor relationships
  // Note: Some patients are also healthcare workers (multi-role)
  /// Patients organized by priority level
  /// Keys: 'high', 'medium', 'routine'
  /// Each patient entry contains: name, age, patientId, condition, status,
  /// assignedDoctor, assignedNurse, image, and optional multi-role indicators
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, List<Map<String, dynamic>>> _patientsByPriority = {
    'high': [
      {
        'name': 'Jane Cooper',
        'age': '45',
        'patientId': 'P-123456',
        'condition': 'Hypertension, Type 2 Diabetes',
        'status': 'Critical',
        'assignedDoctor': 'Dr. Robert Smith',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
      },
      {
        'name': 'Michael Brown',
        'age': '58',
        'patientId': 'P-234567',
        'condition': 'Post-Surgery Recovery',
        'status': 'Monitoring',
        'assignedDoctor': 'Dr. Priya Patel',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
      },
      {
        'name': 'Dr. Priya Patel',
        'age': '42',
        'patientId': 'P-DOC-001',
        'condition': 'Diabetes Type 2 (Also Doctor)',
        'status': 'Stable',
        'assignedDoctor': 'Dr. Emily Chen',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
        'isMultiRole': true,
        'otherRoles': ['Doctor'],
      },
    ],
    'medium': [
      {
        'name': 'Kyle Smith',
        'age': '25',
        'patientId': 'P-456789',
        'condition': 'Fever, Elevated WBC',
        'status': 'Monitoring',
        'assignedDoctor': 'Dr. Robert Smith',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
      },
      {
        'name': 'Emily Carter',
        'age': '38',
        'patientId': 'P-567890',
        'condition': 'Chronic Migraine',
        'status': 'Stable',
        'assignedDoctor': 'Dr. Priya Patel',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
      },
      {
        'name': 'Olivia Thompson',
        'age': '32',
        'patientId': 'P-NURSE-001',
        'condition': 'Routine Annual Checkup (Also Nurse)',
        'status': 'Stable',
        'assignedDoctor': 'Dr. Robert Smith',
        'assignedNurse': 'Sarah Johnson',
        'image': '',
        'isMultiRole': true,
        'otherRoles': ['Nurse'],
      },
    ],
    'routine': [
      {
        'name': 'Alice Johnson',
        'age': '45',
        'patientId': 'P-678901',
        'condition': 'Hypertension',
        'status': 'Stable',
        'assignedDoctor': 'Dr. Robert Smith',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
      },
      {
        'name': 'Charlie Brown',
        'age': '38',
        'patientId': 'P-789012',
        'condition': 'Asthma',
        'status': 'Stable',
        'assignedDoctor': 'Dr. Priya Patel',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
      },
      {
        'name': 'Diana Prince',
        'age': '52',
        'patientId': 'P-890123',
        'condition': 'Migraine',
        'status': 'Stable',
        'assignedDoctor': 'Dr. Emily Chen',
        'assignedNurse': 'Olivia Thompson',
        'image': '',
      },
      {
        'name': 'Dr. Robert Smith',
        'age': '55',
        'patientId': 'P-DOC-002',
        'condition': 'Hypertension (Also Doctor)',
        'status': 'Stable',
        'assignedDoctor': 'Dr. Emily Chen',
        'assignedNurse': 'Sarah Johnson',
        'image': '',
        'isMultiRole': true,
        'otherRoles': ['Doctor', 'Responsible for Patient'],
      },
    ],
  };

  final Map<String, bool> _expandedSections = {
    'high': true,
    'medium': true,
    'routine': true,
  };

  int _currentPage = 1;
  final int _totalPages = 2;

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
                      'My Patients',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search patients...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          // todo: Filter patients by search query
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Emergency banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Emergency',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // todo: Connect Firebase - Call emergency contact
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.phone, size: 16),
                                    SizedBox(width: 4),
                                    Text('Call Now'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_emergencyPatient['name']}, ${_emergencyPatient['age']}, ${_emergencyPatient['condition']} - ${_emergencyPatient['message']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              // todo: Show more details
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'Show More',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // New patient banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B46C1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'New Patient',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_newPatient['name']} - ${_newPatient['age']} years old, ${_newPatient['condition']}, ${_newPatient['type']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Priority sections
                    ..._prioritySections.entries.map((entry) {
                      final priority = entry.value;
                      final patients = _patientsByPriority[priority] ?? [];
                      final count = patients.length;
                      final isExpanded = _expandedSections[priority] ?? false;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedSections[priority] = !isExpanded;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B46C1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${entry.key} ($count)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            ...patients.map(
                              (patient) => _buildPatientCard(
                                patient,
                                priority == 'high' || priority == 'medium'
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      );
                    }),
                    // Pagination
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed:
                              _currentPage > 1
                                  ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                  : null,
                          child: const Text('Previous'),
                        ),
                        Text(
                          'Page $_currentPage of $_totalPages',
                          style: const TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed:
                              _currentPage < _totalPages
                                  ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                  : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
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

  Widget _buildPatientCard(Map<String, dynamic> patient, Color statusColor) {
    return InkWell(
      onTap: () {
        // Navigate to patient detail page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NursePatientDetail()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                  patient['image'] != null && patient['image'].isNotEmpty
                      ? NetworkImage(patient['image'])
                      : null,
              child:
                  patient['image'] == null || patient['image'].isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${patient['age']} years old, ${patient['condition']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                patient['status'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
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
            destination = const NursePublication(); // Message/Publication page
            break;
          case 4:
            // Already on Patients page
            return;
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
