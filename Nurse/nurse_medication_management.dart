import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_publication.dart';
import 'nurse_profile.dart';

/// Nurse Medication Management Page
///
/// This page provides comprehensive medication management functionality for nurses.
/// Features include:
/// - Patient selector dropdown to filter medications by patient
/// - Search functionality to find specific medications
/// - Medication list showing dosage, timing, and status (Taken/Upcoming)
/// - Medication administration tracking
/// - Patient-medication relationships with assigned doctor and nurse
/// - Support for multi-role scenarios (nurses/doctors who are also patients)
/// - Medication request submission capability
/// - Bottom navigation to access other nurse-related pages
///
/// The page helps nurses track and administer medications for their assigned
/// patients, ensuring proper medication management and adherence.
class NurseMedicationManagement extends StatefulWidget {
  const NurseMedicationManagement({super.key});

  @override
  State<NurseMedicationManagement> createState() =>
      _NurseMedicationManagementState();
}

/// State class for Nurse Medication Management Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Selected patient for filtering medications
/// - Search controller for filtering medications
/// - List of patients under nurse's care
/// - List of medications with administration details
/// - UI interactions and navigation
class _NurseMedicationManagementState extends State<NurseMedicationManagement> {
  /// Current selected tab index in bottom navigation bar (Medications tab = 2)
  int _currentIndex = 2;
  
  /// Currently selected patient ID for filtering medications
  String? _selectedPatient;
  
  /// Controller for the search text field to filter medications
  final TextEditingController _searchController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'patients' collection
  // Patients under nurse's care, including multi-role users
  /// List of patients assigned to the current nurse
  /// Each patient contains: name, patientId, assignedDoctor, assignedNurse,
  /// and optional isMultiRole flag
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _patients = [
    {
      'name': 'Jane Cooper',
      'patientId': 'P-123456',
      'assignedDoctor': 'Dr. Robert Smith',
      'assignedNurse': 'Olivia Thompson (You)',
    },
    {
      'name': 'Michael Brown',
      'patientId': 'P-234567',
      'assignedDoctor': 'Dr. Priya Patel',
      'assignedNurse': 'Olivia Thompson (You)',
    },
    {
      'name': 'Kyle Smith',
      'patientId': 'P-456789',
      'assignedDoctor': 'Dr. Robert Smith',
      'assignedNurse': 'Olivia Thompson (You)',
    },
    {
      'name': 'Sarah Ahmed',
      'patientId': 'P-345678',
      'assignedDoctor': 'Dr. Priya Patel',
      'assignedNurse': 'Olivia Thompson (You)',
    },
    {
      'name': 'Dr. Priya Patel (Also Patient)',
      'patientId': 'P-DOC-001',
      'assignedDoctor': 'Dr. Emily Chen',
      'assignedNurse': 'Sarah Johnson',
      'isMultiRole': true,
    },
    {
      'name': 'Olivia Thompson (You - Also Patient)',
      'patientId': 'P-NURSE-001',
      'assignedDoctor': 'Dr. Robert Smith',
      'assignedNurse': 'Sarah Johnson',
      'isMultiRole': true,
    },
  ];

  // TODO: Connect Firebase - Fetch from 'medications' collection
  // Medications showing nurse-patient relationships
  // Medications are prescribed by doctors and administered by nurses
  /// List of medications with administration details
  /// Each medication contains: name, dosage, time, status (Taken/Upcoming),
  /// patient, patientId, prescribedBy (doctor), administeredBy (nurse), image
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Metformin',
      'dosage': '850mg, Twice daily',
      'time': '8:00 AM, 8:00 PM with food',
      'status': 'Taken',
      'patient': 'Jane Cooper',
      'patientId': 'P-123456',
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
      'image': '',
    },
    {
      'name': 'Insulin Glargine',
      'dosage': '20 units, Once daily',
      'time': '9:00 PM',
      'status': 'Upcoming',
      'patient': 'Jane Cooper',
      'patientId': 'P-123456',
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
      'image': '',
    },
    {
      'name': 'Amoxicillin',
      'dosage': '500mg, Twice daily',
      'time': '7:00 AM, 7:00 PM',
      'status': 'Taken',
      'patient': 'Kyle Smith',
      'patientId': 'P-456789',
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
      'image': '',
    },
    {
      'name': 'Ibuprofen',
      'dosage': '200mg, As needed',
      'time': 'When pain occurs',
      'status': 'Upcoming',
      'patient': 'Michael Brown',
      'patientId': 'P-234567',
      'prescribedBy': 'Dr. Priya Patel',
      'administeredBy': 'Olivia Thompson (You)',
      'image': '',
    },
    {
      'name': 'Metformin',
      'dosage': '850mg, Once daily',
      'time': '8:00 AM with food',
      'status': 'Missed',
      'patient': 'Dr. Priya Patel',
      'patientId': 'P-DOC-001',
      'prescribedBy': 'Dr. Emily Chen',
      'administeredBy': 'Sarah Johnson',
      'image': '',
      'note': 'Dr. Patel is also a patient',
    },
    {
      'name': 'Lisinopril',
      'dosage': '20mg, Once daily',
      'time': '9:00 AM',
      'status': 'Taken',
      'patient': 'Sarah Ahmed',
      'patientId': 'P-345678',
      'prescribedBy': 'Dr. Priya Patel',
      'administeredBy': 'Olivia Thompson (You)',
      'image': '',
    },
    {
      'name': 'Atorvastatin',
      'dosage': '40mg, Before bedtime',
      'time': '9:30 PM',
      'status': 'Upcoming',
      'patient': 'Jane Cooper',
      'patientId': 'P-123456',
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
      'image': '',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B46C1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medication,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'MedCare',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B46C1),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF6B46C1)),
                    onPressed: () {
                      // todo: Implement search
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient selector
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedPatient ?? 'Select Patient',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedPatient != null
                                      ? Colors.black
                                      : Colors.grey[600],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Submit medication request section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B46C1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Submit Medication Request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nurses can request medication additions or edits for patients. These requests will be reviewed and authorized by a doctor.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // todo: Connect Firebase - Navigate to request page
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B46C1),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Request Medication Change'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter and sort bar
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // todo: Show filter options
                          },
                          icon: const Icon(Icons.filter_list, size: 16),
                          label: const Text('Filter'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            // todo: Show sort options
                          },
                          icon: const Icon(Icons.sort, size: 16),
                          label: const Text('Sort'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Medication list
                    ..._medications.map((med) => _buildMedicationCard(med)),
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

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    Color statusColor;
    switch (medication['status']) {
      case 'Taken':
        statusColor = Colors.grey[700]!;
        break;
      case 'Missed':
        statusColor = Colors.red;
        break;
      case 'Upcoming':
        statusColor = Colors.grey[400]!;
        break;
      default:
        statusColor = Colors.grey;
    }

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medication['dosage'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  medication['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  medication['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    medication['image'] != null &&
                            medication['image'].isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            medication['image'],
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Icon(
                          Icons.medication,
                          color: Colors.grey,
                          size: 24,
                        ),
              ),
            ],
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
            // Already on Medications page
            return;
          case 3:
            destination = const NursePublication(); // Messages/Publication page
            break;
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
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
