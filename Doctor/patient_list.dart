import 'package:flutter/material.dart';
import 'home.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'medications.dart';
import 'doctor_detail.dart';
import '../services/doctor_service.dart';

/// Patient List Page (UI Layer)
///
/// This page displays a list of all patients assigned to the current doctor.
/// Features:
/// - List of patients with name and diagnosis
/// - Search functionality to filter patients
/// - View patient details button
/// - Bottom navigation bar
///
/// **Architecture**: Uses PatientService to fetch and search patients,
/// keeping Firebase logic separate from UI.
class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

/// State class for Patient List Page
///
/// Manages:
/// - List of patients
/// - Filtered/search results
/// - Search controller
/// - Navigation state
class _PatientListState extends State<PatientList> {
  // ==================== State Variables ====================

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  /// Current selected tab index in bottom navigation
  int _currentIndex = 1; // Patients tab is active

  // ==================== Patient Data ====================

  /// Complete list of all patients (unfiltered)
  List<Map<String, dynamic>> _patients = [];

  /// Filtered list of patients based on search query
  List<Map<String, dynamic>> _filteredPatients = [];

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads patient list from Firebase via PatientService.
  @override
  void initState() {
    super.initState();
    _filteredPatients = _patients;
    _loadPatients();
  }

  /// Clean up resources when widget is disposed
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== Data Loading Methods ====================

  /// Load all patients for the current doctor from Firebase.
  ///
  /// Uses DoctorService.getPatientsForDoctor() to fetch patients assigned to the current doctor.
  /// Updates both _patients and _filteredPatients lists with the fetched data.
  /// Shows error message if loading fails.
  Future<void> _loadPatients() async {
    try {
      // Use DoctorService to fetch patients
      final patients = await DoctorService.instance.getPatientsForDoctor();

      if (mounted) {
        setState(() {
          _patients = patients;
          _filteredPatients = patients;
        });
      }
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading patients: $e')));
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle search input and filter patient list.
  ///
  /// Filters the patient list based on patient name or diagnosis using local filtering.
  /// Uses DoctorService.searchList() for case-insensitive search across specified fields.
  ///
  /// @param query The search text entered by user
  void _searchPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = DoctorService.searchList(query, _patients, [
          'name',
          'diagnosis',
        ]);
      }
    });
  }

  /// Navigate to patient details page
  ///
  /// Placeholder for future patient details page implementation.
  /// Will show detailed information about the selected patient.
  ///
  /// @param patient Map containing patient data (id, name, diagnosis, etc.)
  void _viewPatientDetails(Map<String, dynamic> patient) {
    // todo: Navigate to patient details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${patient['name']}')),
    );
  }

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
                      'Patient List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF6B46C1)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
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
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchPatients,
                  decoration: InputDecoration(
                    hintText: 'Search patients...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Patient list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = _filteredPatients[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                patient['diagnosis'] ?? 'No diagnosis',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _viewPatientDetails(patient),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navigate to different pages based on index
          Widget? destination;
          switch (index) {
            case 0:
              destination = const Dashdoctor();
              break;
            case 1:
              // Already on Patients page
              return;
            case 2:
              destination = const LabResultsReview();
              break;
            case 3:
              destination = const MedicalRecords();
              break;
            case 4:
              destination = const Medications();
              break;
            case 5:
              destination = const DoctorDetail();
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
            icon: Icon(Icons.accessible),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Lab Tests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Medical Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
