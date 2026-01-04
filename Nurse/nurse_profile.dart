import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_publication.dart';
import 'nurse_patient_management.dart';

/// Nurse Profile Page
///
/// This page displays comprehensive profile information for the currently logged-in nurse.
/// Features include:
/// - Personal information (name, role, user ID, patient ID for multi-role users)
/// - Contact information (email, phone, department, shift schedule)
/// - Assigned doctors list (showing doctors the nurse works with)
/// - Patients under care (list of patients assigned to the nurse)
/// - Recent publications/posts from the healthcare community
/// - Language preferences
/// - Profile image display
///
/// Supports multi-role scenarios where nurses may also be patients, displaying
/// both nurse and patient information where applicable.
class NurseProfile extends StatefulWidget {
  const NurseProfile({super.key});

  @override
  State<NurseProfile> createState() => _NurseProfileState();
}

/// State class for Nurse Profile Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Nurse profile data
/// - Contact information
/// - Assigned doctors list
/// - Patients under care list
/// - Publications and language preferences
/// - UI state and interactions
class _NurseProfileState extends State<NurseProfile> {
  /// Current selected tab index in bottom navigation bar (Profile tab = 5)
  int _currentIndex = 5;

  // TODO: Connect Firebase - Fetch from 'nurses' collection
  // Nurse: Olivia Thompson - Also registered as patient (multi-role user)
  /// Nurse profile information including personal details and multi-role support
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _nurse = {
    'name': 'Olivia Thompson',
    'role': 'Oncology Nurse',
    'userId': 'NC-48276',
    'patientId': 'P-NURSE-001', // Also a patient
    'phone': '+1-555-987-6543',
    'image': '', // todo: Load from Firebase Storage
    'roles': ['Nurse', 'Patient'], // Multi-role user
  };

  // todo: Connect Firebase - Fetch from 'nurses' collection
  final Map<String, dynamic> _contact = {
    'email': 'olivia.thompson@hospital.com',
    'phone': '+1-555-987-6543',
    'department': 'Oncology Unit, Floor 3',
    'shift': 'Day Shift (7 AM - 7 PM)',
  };

  // todo: Connect Firebase - Fetch assigned doctors
  // Doctors this nurse works with
  final List<Map<String, dynamic>> _assignedDoctors = [
    {
      'name': 'Dr. Robert Smith',
      'specialty': 'Cardiology',
      'doctorId': 'DOC-001',
      'isAlsoPatient': true, // Dr. Smith is also a patient
      'patientId': 'P-DOC-002',
    },
    {
      'name': 'Dr. Priya Patel',
      'specialty': 'Oncology',
      'doctorId': 'DOC-002',
      'isAlsoPatient': true, // Dr. Patel is also a patient
      'patientId': 'P-DOC-001',
    },
    {
      'name': 'Dr. Emily Chen',
      'specialty': 'Internal Medicine',
      'doctorId': 'DOC-003',
      'isAlsoPatient': false,
    },
  ];

  // todo: Connect Firebase - Fetch from 'patients' collection
  // Patients under this nurse's care
  final int _patientsUnderCare = 12;
  final List<Map<String, dynamic>> _patientList = [
    {'name': 'Jane Cooper', 'patientId': 'P-123456', 'condition': 'Diabetes'},
    {
      'name': 'Michael Brown',
      'patientId': 'P-234567',
      'condition': 'Post-Surgery',
    },
    {'name': 'Kyle Smith', 'patientId': 'P-456789', 'condition': 'Fever'},
    {
      'name': 'Sarah Ahmed',
      'patientId': 'P-345678',
      'condition': 'Breast Cancer',
    },
    {
      'name': 'Dr. Priya Patel',
      'patientId': 'P-DOC-001',
      'condition': 'Diabetes (Also Doctor)',
    },
    {
      'name': 'Olivia Thompson',
      'patientId': 'P-NURSE-001',
      'condition': 'Routine Checkup (You)',
    },
  ];

  // todo: Connect Firebase - Fetch from 'publications' collection
  final String _lastPost =
      'For cancer patients, try including more antioxidants like blueberries and green tea. Shared by Dr. Priya Patel.';

  // todo: Connect Firebase - Fetch languages
  final List<String> _languages = ['Arabic', 'English', 'French'];

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
                    // Profile card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                _nurse['image'] != null &&
                                        _nurse['image'].isNotEmpty
                                    ? NetworkImage(_nurse['image'])
                                    : null,
                            child:
                                _nurse['image'] == null ||
                                        _nurse['image'].isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nurse['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nurse['role'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'User ID: ${_nurse['userId']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nurse['phone'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Contact Information
                    _buildSection('Contact Information', [
                      _buildInfoRow(Icons.mail, _contact['email']),
                      _buildInfoRow(Icons.phone, _contact['phone']),
                      _buildInfoRow(Icons.business, _contact['department']),
                    ]),
                    const SizedBox(height: 16),
                    // Assigned Doctors
                    _buildSection('Assigned Doctors', [
                      Text(
                        _assignedDoctors.join(', '),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Patients Under Care
                    _buildSection('Patients Under Care', [
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFF6B46C1),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Currently monitoring $_patientsUnderCare patients',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Last Seen Post
                    _buildSection('Last Seen Post', [
                      Row(
                        children: [
                          const Icon(
                            Icons.article,
                            color: Color(0xFF6B46C1),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _lastPost,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Languages
                    _buildSection('Languages', [
                      Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: Color(0xFF6B46C1),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _languages.join(', '),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ]),
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

  Widget _buildSection(String title, List<Widget> children) {
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B46C1), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
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
            destination = const NursePublication(); // Message/Publication page
            break;
          case 4:
            destination = const NursePatientManagement();
            break;
          case 5:
            // Already on Account/Profile page
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
