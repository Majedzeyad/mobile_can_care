import 'package:flutter/material.dart';
import 'home.dart';
import 'patient_list.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'medications.dart';
import 'doctor_detail.dart';
import '../services/doctor_service.dart';

/// Lab Test Request Page (UI Layer)
///
/// This page allows doctors to:
/// - Request new lab tests for patients
/// - View pending lab test requests
/// - Select patient, test type, and urgency
///
/// **Architecture**: Uses PatientService and LabService to handle
/// all Firebase operations, keeping UI separate from data logic.
class LabTestRequest extends StatefulWidget {
  const LabTestRequest({super.key});

  @override
  State<LabTestRequest> createState() => _LabTestRequestState();
}

/// State class for Lab Test Request Page
///
/// Manages:
/// - Form state (patient selection, test type, urgency)
/// - List of available patients
/// - List of pending test requests
/// - Form submission
class _LabTestRequestState extends State<LabTestRequest> {
  // ==================== State Variables ====================

  /// Current selected tab index in bottom navigation
  int _currentIndex = 2; // Lab Tests tab is active

  /// Selected tab: 0 = Pending Results, 1 = Completed Tests
  int _selectedTab = 0;

  /// Selected patient name from dropdown
  String? _selectedPatient;

  /// Selected test type (e.g., "Blood Test", "COVID-19", "Urinalysis")
  String? _selectedTestType;

  /// Selected specific test (e.g., "rapid", "serology" for COVID-19)
  String? _selectedTest;

  /// Selected urgency level ("low", "normal", "high", "urgent")
  String? _selectedUrgency;

  /// Controller for additional notes text field
  final TextEditingController _notesController = TextEditingController();

  // ==================== Data Lists ====================

  /// List of patient names for dropdown selection
  List<String> _patients = [];

  /// Available test types
  List<String> _testTypes = ['Blood Test', 'COVID-19', 'Urinalysis'];

  /// List of pending lab test requests
  List<Map<String, dynamic>> _pendingResults = [];

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads patients and pending requests from Firebase.
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Clean up resources when widget is disposed
  ///
  /// Disposes the notes controller to prevent memory leaks.
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ==================== Data Loading Methods ====================

  /// Load patients and pending lab test requests from Firebase.
  ///
  /// Uses FirebaseService.getPatientNames() to get patient names for the dropdown
  /// and FirebaseService.getPendingLabTestRequests() to get pending requests.
  /// Updates UI state with the fetched data, populating the patient dropdown
  /// and pending results list.
  ///
  /// The method checks if the widget is still mounted before updating state
  /// to prevent errors if the widget is disposed during the async operation.
  /// Displays error messages if loading fails.
  Future<void> _loadData() async {
    try {
      // Use DoctorService to fetch data
      final patients = await DoctorService.instance.getPatientsForDoctor();
      _patients = patients.map((patient) => patient['name'] as String).toList();
      final pendingRequests = await DoctorService.instance.getPendingLabTestRequests();

      if (mounted) {
        setState(() {
          _pendingResults =
              pendingRequests.map((request) {
                return {
                  'id': request['id'],
                  'patient': request['patientName'] ?? 'Unknown',
                  'timestamp': request['formattedDate'] ?? 'Unknown',
                };
              }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  // ==================== Form Submission Methods ====================

  /// Submit a new lab test request.
  ///
  /// Validates that required form inputs are provided (patient and test type),
  /// then creates a new lab test request using FirebaseService.createLabTestRequest().
  ///
  /// **Validation:**
  /// - Patient must be selected
  /// - Test type must be selected
  /// - Patient must exist in the system
  ///
  /// **On Success:**
  /// - Shows success message to the user
  /// - Clears form fields
  /// - Reloads data to display the new request in the pending list
  ///
  /// Displays error messages if validation fails or the operation encounters errors.
  Future<void> _requestTest() async {
    // Validate form inputs
    if (_selectedPatient == null || _selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select patient and test type')),
      );
      return;
    }

    try {
      // Get patient ID from patient name using DoctorService
      final patients = await DoctorService.instance.getPatientsForDoctor();
      final selectedPatientData = patients.firstWhere(
        (p) => p['name'] == _selectedPatient,
        orElse: () => <String, dynamic>{'id': ''},
      );

      if (selectedPatientData.isEmpty || selectedPatientData['id'] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Patient not found')));
        return;
      }

      // Use DoctorService to create lab test request
      await DoctorService.instance.createLabTestRequest({
        'patientName': _selectedPatient,
        'patientId': selectedPatientData['id'],
        'testType': _selectedTestType,
        'test': _selectedTest,
        'urgency': _selectedUrgency ?? 'normal',
        'notes': _notesController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test requested successfully')),
        );

        // Clear form
        setState(() {
          _selectedPatient = null;
          _selectedTestType = null;
          _selectedTest = null;
          _selectedUrgency = null;
          _notesController.clear();
        });

        // Reload data to show new request
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error requesting test: $e')));
      }
    }
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
                      'Lab Test Request',
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
                  decoration: InputDecoration(
                    hintText: 'Search tests...',
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
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedTab == 0
                                  ? const Color(0xFF6B46C1)
                                  : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Pending Results',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedTab == 0 ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedTab == 1
                                  ? const Color(0xFF6B46C1)
                                  : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Completed Tests',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedTab == 1 ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child:
                    _selectedTab == 0
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Select Patient
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedPatient,
                                decoration: const InputDecoration(
                                  labelText: 'Select Patient',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    _patients.map((patient) {
                                      return DropdownMenuItem(
                                        value: patient,
                                        child: Text(patient),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedPatient = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Select Test Type
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedTestType,
                                decoration: const InputDecoration(
                                  labelText: 'Select Test Type',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    _testTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTestType = value;
                                    _selectedTest = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Radio buttons for COVID-19 tests
                            if (_selectedTestType == 'COVID-19')
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    RadioListTile<String>(
                                      title: const Text(
                                        'Rapid Test - COVID-19',
                                      ),
                                      value: 'rapid',
                                      groupValue: _selectedTest,
                                      onChanged: (value) {
                                        setState(() => _selectedTest = value);
                                      },
                                    ),
                                    RadioListTile<String>(
                                      title: const Text(
                                        'Serology Test - COVID-19',
                                      ),
                                      value: 'serology',
                                      groupValue: _selectedTest,
                                      onChanged: (value) {
                                        setState(() => _selectedTest = value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            // Additional Notes
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Additional Notes',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Urgency
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedUrgency,
                                decoration: const InputDecoration(
                                  labelText: 'Urgency',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    ['Low', 'Normal', 'High', 'Urgent'].map((
                                      urgency,
                                    ) {
                                      return DropdownMenuItem(
                                        value: urgency.toLowerCase(),
                                        child: Text(urgency),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedUrgency = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Request Tests button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _requestTest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B46C1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Request Tests',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Pending Results list
                            const Text(
                              'Pending Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._pendingResults.map((result) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'patient name - ${result['patient'] ?? 'Unknown'}',
                                    ),
                                    Text(
                                      result['timestamp'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        )
                        : const Center(
                          child: Text('Completed Tests - todo: Implement'),
                        ),
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
              destination = const PatientList();
              break;
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
