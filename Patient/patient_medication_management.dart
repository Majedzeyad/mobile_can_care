import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_publication.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';

/// Patient Medication Management Page
///
/// This page provides medication management functionality for patients.
/// Features include:
/// - Next dosage reminder showing the upcoming medication, dosage, and time
/// - Complete medication list with expandable details
/// - Search functionality to find specific medications
/// - Medication cards showing name, dosage, and instructions
/// - Expandable medication cards for detailed information
///
/// The page helps patients track their medications, remember dosage schedules,
/// and access medication information when needed.
class PatientMedicationManagement extends StatefulWidget {
  const PatientMedicationManagement({super.key});

  @override
  State<PatientMedicationManagement> createState() =>
      _PatientMedicationManagementState();
}

/// State class for Patient Medication Management Page
///
/// Manages:
/// - Current navigation index
/// - Search controller for filtering medications
/// - Next dosage reminder information
/// - List of current medications with expandable state
/// - UI state and interactions
class _PatientMedicationManagementState
    extends State<PatientMedicationManagement> {
  /// Current navigation index (1 for medications page)
  int _currentIndex = 1;
  
  /// Controller for the search text field to filter medications
  final TextEditingController _searchController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'prescriptions' collection
  /// Information about the next scheduled medication dosage
  /// Contains: medication (name), dosage (amount), time (when to take)
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _nextDosage = {
    'medication': 'Cyclophosphamide',
    'dosage': '50mg',
    'time': '10:00 am',
  };

  // TODO: Connect Firebase - Fetch from 'prescriptions' collection
  /// List of current medications prescribed to the patient
  /// Each medication contains: name, dosage, expanded (boolean for expandable state)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _medications = [
    {'name': 'Cyclophosphamide', 'dosage': '50mg', 'expanded': false},
    {'name': 'Dexamethasone', 'dosage': '4mg', 'expanded': false},
    {'name': 'Morphine', 'dosage': '10mg', 'expanded': false},
    {'name': 'Paclitaxel', 'dosage': '100mg', 'expanded': false},
    {'name': 'Ondansetron', 'dosage': '8mg', 'expanded': false},
  ];

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the patient medication management UI with reminders and medication list.
  ///
  /// Creates an interface including:
  /// - Status bar simulation at the top
  /// - Header with page title, back button, and search functionality
  /// - Next dosage reminder card highlighting the upcoming medication
  /// - Medication list with expandable cards for detailed information
  /// - Search functionality to filter medications
  /// - Medication cards showing name, dosage, and expandable details
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient medication management UI
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
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Next dosage banner
                    _buildNextDosageBanner(),
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
                          // todo: Filter medications by search query
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // My Medications heading
                    const Text(
                      'My Medications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Medication list
                    ..._medications.map((med) => _buildMedicationItem(med)),
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

  Widget _buildNextDosageBanner() {
    return Container(
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
            child: Text(
              'Next Dosage ${_nextDosage['medication']} :${_nextDosage['dosage']} at ${_nextDosage['time']}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${medication['name']} :${medication['dosage']}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                medication['expanded'] = !medication['expanded'];
              });
              // todo: Show medication details
            },
            child: const Row(
              children: [
                Text(
                  'Show More',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B46C1)),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF6B46C1)),
              ],
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
            // Already on Medications page
            return;
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
