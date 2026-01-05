import 'package:flutter/material.dart';
import 'home.dart';
import 'patient_list.dart';
import 'medical_records.dart';
import 'medications.dart';
import 'doctor_detail.dart';
import '../services/doctor_service.dart';

/// Lab Results Review Page (UI Layer)
///
/// This page allows doctors to:
/// - View all lab results for a patient
/// - Add notes to pending lab results
/// - View details of completed lab results
///
/// **Architecture**: Uses PatientService and LabService to handle
/// all Firebase operations, keeping UI separate from data logic.
class LabResultsReview extends StatefulWidget {
  const LabResultsReview({super.key});

  @override
  State<LabResultsReview> createState() => _LabResultsReviewState();
}

/// State class for Lab Results Review Page
///
/// Manages:
/// - Current patient information
/// - List of lab results
/// - Notes dialog state
class _LabResultsReviewState extends State<LabResultsReview> {
  // ==================== State Variables ====================

  /// Current selected tab index in bottom navigation
  int _currentIndex = 2; // Lab Tests tab is active

  // ==================== Patient Data ====================

  /// Current patient being reviewed
  /// Contains: name, age, patientId
  Map<String, dynamic> _patient = {
    'name': 'Unknown',
    'age': '0',
    'patientId': 'Unknown',
  };

  // ==================== Lab Results Data ====================

  /// List of all lab results for the current patient
  /// Each result contains: id, testName, status, buttonText, icon
  List<Map<String, dynamic>> _labResults = [];

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads patient and lab results from Firebase.
  @override
  void initState() {
    super.initState();
    _loadLabResults();
  }

  // ==================== Helper Methods ====================

  /// Get appropriate icon for a test type
  ///
  /// Returns an icon based on the test name to improve visual recognition.
  ///
  /// @param testName The name of the lab test
  ///
  /// @return IconData The icon to display
  IconData _getIconForTest(String testName) {
    final lowerName = testName.toLowerCase();
    if (lowerName.contains('blood') || lowerName.contains('cbc')) {
      return Icons.bloodtype;
    } else if (lowerName.contains('urine')) {
      return Icons.science;
    } else if (lowerName.contains('ekg') || lowerName.contains('heart')) {
      return Icons.favorite;
    } else if (lowerName.contains('sleep')) {
      return Icons.bedtime;
    }
    return Icons.analytics;
  }

  // ==================== Data Loading Methods ====================

  /// Load lab results for the current patient from Firebase.
  ///
  /// If no patient is currently selected, automatically selects and loads
  /// the first patient assigned to the current doctor using FirebaseService.getPatientsForDoctor().
  /// Uses FirebaseService.getLabResultsForPatient() to fetch lab results from Firebase.
  ///
  /// Updates the UI state with fetched lab results, including status information
  /// and appropriate icons for each test type. Results are formatted with
  /// appropriate button text based on status (pending = "Add Notes", completed = "View Details").
  ///
  /// Displays error messages if loading fails or no patients are found.
  Future<void> _loadLabResults() async {
    try {
      // Get patient ID
      String patientId = _patient['patientId'] ?? '';

      // If no patient selected, get first patient
      if (patientId.isEmpty || patientId == 'Unknown') {
        // Use DoctorService to get patients
        final patients = await DoctorService.instance.getPatientsForDoctor();
        if (patients.isNotEmpty) {
          final firstPatient = patients.first;
          _patient = {
            'name': firstPatient['name'] ?? 'Unknown',
            'age': firstPatient['age']?.toString() ?? '0',
            'patientId': firstPatient['id'] ?? '',
          };
          patientId = _patient['patientId'] as String;
        }
      }

      if (patientId.isEmpty || patientId == 'Unknown') {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No patients found')));
        }
        return;
      }

      // Use DoctorService to fetch lab results
      final results = await DoctorService.instance.getLabResultsForPatient(patientId);

      if (mounted) {
        setState(() {
          _labResults =
              results.map((result) {
                final status = result['status'] ?? 'pending';
                return {
                  'id': result['id'],
                  'testName': result['testName'] ?? 'Unknown Test',
                  'status': status,
                  'buttonText':
                      status == 'pending' ? 'Add Notes' : 'View Details',
                  'icon': _getIconForTest(result['testName'] ?? ''),
                };
              }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lab results: $e')),
        );
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// View detailed information about a lab test result.
  ///
  /// Placeholder method for future test details page implementation.
  /// When implemented, this would navigate to a detailed view showing complete
  /// test results, values, reference ranges, and historical data.
  ///
  /// Currently shows a snackbar message indicating the feature is in development.
  ///
  /// [result] - Map containing test result data (id, testName, status, etc.)
  void _viewTestDetails(Map<String, dynamic> result) {
    // todo: Navigate to test details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${result['testName']}')),
    );
  }

  /// Add notes to a pending lab test result.
  ///
  /// Displays a dialog allowing the doctor to enter notes or comments for a
  /// pending lab test result. Uses FirebaseService.addNotesToLabResult() to save
  /// notes to Firebase, which also marks the result as 'completed' and sets a timestamp.
  ///
  /// The dialog includes a text field for note entry and Cancel/Save buttons.
  /// If the user saves notes, displays a success message and reloads results;
  /// otherwise silently cancels the operation.
  ///
  /// [testResult] - Map containing test result data (id, testName, status, etc.)
  Future<void> _addNotes(Map<String, dynamic> testResult) async {
    final notesController = TextEditingController();

    // Show dialog for entering notes
    final dialogResult = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Notes'),
            content: TextField(
              controller: notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter notes...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    // If user confirmed and entered notes, save them
    if (dialogResult == true && notesController.text.isNotEmpty) {
      try {
        // Use DoctorService to add notes
        await DoctorService.instance.addNotesToLabResult(
          testResult['id'],
          notesController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notes added successfully')),
          );
          // Reload results to show updated status
          _loadLabResults();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding notes: $e')));
        }
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
                      'Lab Results Review',
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
            // Patient info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  Text(
                    _patient['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_patient['age']} years | ${_patient['patientId']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Lab results list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _labResults.length,
                itemBuilder: (context, index) {
                  final result = _labResults[index];
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
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            result['icon'] as IconData,
                            size: 30,
                            color: const Color(0xFF6B46C1),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                result['status'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (result['buttonText'] == 'Add Notes') {
                              _addNotes(result);
                            } else {
                              _viewTestDetails(result);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(result['buttonText']),
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
              destination = const PatientList();
              break;
            case 2:
              // Already on Lab Tests page
              return;
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
