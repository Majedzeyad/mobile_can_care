import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import 'home.dart';
import 'patient_list.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'doctor_detail.dart';

/// Medications Page (UI Layer)
///
/// This page displays all available medications that doctors can order.
/// Features:
/// - List of all medications with name and dosage
/// - Search functionality to find medications
/// - Order medication button
///
/// **Architecture**: Uses MedicationService to handle
/// all Firebase operations, keeping UI separate from data logic.
class Medications extends StatefulWidget {
  const Medications({super.key});

  @override
  State<Medications> createState() => _MedicationsState();
}

/// State class for Medications Page
///
/// Manages:
/// - List of medications
/// - Filtered/search results
/// - Search controller
/// - Navigation state
class _MedicationsState extends State<Medications> {
  // ==================== State Variables ====================

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  /// Current selected tab index in bottom navigation
  int _currentIndex = 0;

  // ==================== Medications Data ====================

  /// Complete list of all medications (unfiltered)
  List<Map<String, dynamic>> _medications = [];

  /// Filtered list of medications based on search query
  List<Map<String, dynamic>> _filteredMedications = [];

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads medications from Firebase via MedicationService.
  @override
  void initState() {
    super.initState();
    _filteredMedications = _medications;
    _loadMedications();
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

  /// Load all available medications from Firebase.
  ///
  /// Uses FirebaseService.getAllMedications() to fetch medications from the medications catalog.
  /// Updates both _medications (complete list) and _filteredMedications
  /// (search results) lists with the fetched data.
  /// Displays error messages if loading fails.
  ///
  /// The method checks if the widget is still mounted before updating state
  /// to prevent errors if the widget is disposed during the async operation.
  Future<void> _loadMedications() async {
    try {
      // Use DoctorService to fetch medications
      final medications = await DoctorService.instance.getAllMedications();

      if (mounted) {
        setState(() {
          _medications = medications;
          _filteredMedications = medications;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medications: $e')),
        );
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle search input and filter the medication list in real-time.
  ///
  /// Filters the medication list based on the search query by matching
  /// against medication names. Uses FirebaseService.searchList() to perform
  /// case-insensitive search across specified fields.
  ///
  /// Updates _filteredMedications state, which triggers UI rebuild to show
  /// only matching medications.
  ///
  /// [query] - The search text entered by the user
  void _searchMedications(String query) {
    setState(() {
      // Use DoctorService search method
      _filteredMedications = DoctorService.searchList(query, _medications, [
        'name',
      ]);
    });
  }

  /// Create an order for a medication.
  ///
  /// Uses FirebaseService.createMedicationOrder() to create a medication order in Firestore,
  /// linking the medication to the current doctor. The order is created with 'pending' status
  /// and a server timestamp.
  ///
  /// Displays success or error messages via SnackBar to inform the user of
  /// the operation result.
  ///
  /// [medication] - Map containing medication data (id, name, dosage)
  Future<void> _orderMedication(Map<String, dynamic> medication) async {
    try {
      // Use DoctorService to create medication order
      await DoctorService.instance.createMedicationOrder(
        medication['id'],
        medication['name'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ordered ${medication['name']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ordering medication: $e')),
        );
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
                      'Medications',
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
                  onChanged: _searchMedications,
                  decoration: InputDecoration(
                    hintText: 'Search medications...',
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
            // Medications list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredMedications.length,
                itemBuilder: (context, index) {
                  final medication = _filteredMedications[index];
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
                          child: const Icon(
                            Icons.medication,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                medication['dosage'] ?? 'No dosage info',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _orderMedication(medication),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Order'),
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
              destination = const MedicalRecords();
              break;
            case 4:
              // Already on Medications page
              return;
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
