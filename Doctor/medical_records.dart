import 'package:flutter/material.dart';
import 'home.dart';
import 'patient_list.dart';
import 'lab_results_review.dart';
import 'medications.dart';
import 'doctor_detail.dart';
import '../services/doctor_service.dart';

/// Medical Records Page (UI Layer)
///
/// This page displays all medical records for the current doctor.
/// Features:
/// - List of medical records organized by category
/// - Search functionality to filter records
/// - View record details
///
/// **Architecture**: Uses MedicalRecordService to handle
/// all Firebase operations, keeping UI separate from data logic.
class MedicalRecords extends StatefulWidget {
  const MedicalRecords({super.key});

  @override
  State<MedicalRecords> createState() => _MedicalRecordsState();
}

/// State class for Medical Records Page
///
/// Manages:
/// - List of medical records
/// - Filtered/search results
/// - Search controller
/// - Navigation state
class _MedicalRecordsState extends State<MedicalRecords> {
  // ==================== State Variables ====================

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  /// Current selected tab index in bottom navigation
  int _currentIndex = 3; // Medical Records tab is active

  // ==================== Medical Records Data ====================

  /// Complete list of all medical records (unfiltered)
  List<Map<String, dynamic>> _records = [];

  /// Filtered list of records based on search query
  List<Map<String, dynamic>> _filteredRecords = [];

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads medical records from Firebase via MedicalRecordService.
  @override
  void initState() {
    super.initState();
    _filteredRecords = _records;
    _loadMedicalRecords();
  }

  /// Clean up resources when widget is disposed
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== Helper Methods ====================

  /// Get appropriate icon for a medical record category.
  ///
  /// Returns an icon based on the category name to improve visual recognition
  /// and help doctors quickly identify different types of medical records.
  /// Supports common categories like Diagnosis, Treatment, Surgery, Follow-up,
  /// Immunization, Cardiology, and Radiology.
  ///
  /// [category] - The category name (e.g., "Diagnosis", "Treatment", "Surgery")
  /// Returns: IconData - The icon to display for the category
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'diagnosis':
        return Icons.medical_information;
      case 'treatment':
        return Icons.medication;
      case 'surgery':
        return Icons.healing;
      case 'follow-up':
      case 'followup':
        return Icons.update;
      case 'immunization':
        return Icons.vaccines;
      case 'cardiology':
        return Icons.favorite;
      case 'radiology':
        return Icons.medical_information;
      default:
        return Icons.folder;
    }
  }

  // ==================== Data Loading Methods ====================

  /// Load all medical records for the current doctor from Firebase.
  ///
  /// Uses FirebaseService.getMedicalRecordsForDoctor() to fetch medical records
  /// from Firebase. Updates both _records (complete list) and _filteredRecords
  /// (search results) lists with the fetched data, adding appropriate icons for each category.
  ///
  /// The method checks if the widget is still mounted before updating state
  /// to prevent errors if the widget is disposed during the async operation.
  /// Displays error messages if loading fails.
  Future<void> _loadMedicalRecords() async {
    try {
      // Use DoctorService to fetch medical records
      final records = await DoctorService.instance.getMedicalRecordsForDoctor();

      if (mounted) {
        setState(() {
          _records = records.map((record) {
            return {
              ...record,
              'icon': _getIconForCategory(record['category'] ?? ''),
            };
          }).toList();
          _filteredRecords = _records;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medical records: $e')),
        );
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle search input and filter the medical records list in real-time.
  ///
  /// Filters records by matching the search query against both category names
  /// and descriptions. Uses FirebaseService.searchList() for case-insensitive
  /// search across specified fields. Updates the _filteredRecords state, which
  /// triggers UI rebuild to show only matching records.
  ///
  /// [query] - The search text entered by the user
  void _searchRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _records;
      } else {
        _filteredRecords = DoctorService.searchList(query, _records, [
          'category',
          'description',
        ]);
      }
    });
  }

  /// Navigate to medical record details page.
  ///
  /// Placeholder method for future record details page implementation.
  /// When implemented, this would navigate to a detailed view showing complete
  /// record information, patient history, related documents, and timeline.
  ///
  /// Currently shows a snackbar message indicating the feature is in development.
  ///
  /// [record] - Map containing record data (id, category, description, date, icon)
  void _viewRecordDetails(Map<String, dynamic> record) {
    // todo: Navigate to record details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${record['category']} records')),
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
                      'Medical Records',
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
            // Search bar with filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
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
                        onChanged: _searchRecords,
                        decoration: InputDecoration(
                          hintText: 'Search patients...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
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
                    child: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF6B46C1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search medical records',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Records list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
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
                            record['icon'] as IconData,
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
                                record['category'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _viewRecordDetails(record),
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
              destination = const PatientList();
              break;
            case 2:
              destination = const LabResultsReview();
              break;
            case 3:
              // Already on Medical Records page
              return;
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
