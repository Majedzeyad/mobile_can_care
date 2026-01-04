import 'package:flutter/material.dart';
import 'home.dart';
import 'patient_list.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'medications.dart';
import 'doctor_detail.dart';
import '../services/doctor_service.dart';

/// Override Requests Page (UI Layer)
///
/// This page displays override requests from nurses asking doctors
/// to approve medication dosage overrides.
/// Features:
/// - List of pending override requests
/// - Select request to view details
/// - Approve/reject override functionality
/// - Search functionality
///
/// **Architecture**: Uses RequestService to handle
/// all Firebase operations, keeping UI separate from data logic.
class OverrideRequests extends StatefulWidget {
  const OverrideRequests({super.key});

  @override
  State<OverrideRequests> createState() => _OverrideRequestsState();
}

/// State class for Override Requests Page
///
/// Manages:
/// - List of override requests
/// - Filtered/search results
/// - Selected request for details view
/// - Search controller
/// - Navigation state
class _OverrideRequestsState extends State<OverrideRequests> {
  // ==================== State Variables ====================

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  /// Current selected tab index in bottom navigation
  int _currentIndex = 0;

  // ==================== Override Requests Data ====================

  /// Complete list of all override requests (unfiltered)
  List<Map<String, dynamic>> _requests = [];

  /// Filtered list of requests based on search query
  List<Map<String, dynamic>> _filteredRequests = [];

  /// Currently selected request to show details
  Map<String, dynamic>? _selectedRequest;

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads override requests from Firebase via RequestService.
  @override
  void initState() {
    super.initState();
    _filteredRequests = _requests;
    _loadOverrideRequests();
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

  /// Load all pending override requests from Firebase.
  ///
  /// Uses FirebaseService.getPendingOverrideRequests() to fetch override requests
  /// from Firebase. Updates both _requests (complete list) and _filteredRequests
  /// (search results) lists with the fetched data.
  ///
  /// The method checks if the widget is still mounted before updating state
  /// to prevent errors if the widget is disposed during the async operation.
  /// Displays error messages if loading fails.
  Future<void> _loadOverrideRequests() async {
    try {
      // Use DoctorService to fetch override requests
      final requests = await DoctorService.instance.getPendingOverrideRequests();

      if (mounted) {
        setState(() {
          _requests =
              requests.map((request) {
                return {
                  'id': request['id'],
                  'name': request['nurseName'] ?? 'Unknown Nurse',
                  'timestamp': request['formattedDate'] ?? 'Unknown',
                  'description': request['description'] ?? 'No description',
                };
              }).toList();
          _filteredRequests = _requests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading override requests: $e')),
        );
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle search input and filter the override requests list in real-time.
  ///
  /// Filters requests by matching the search query against nurse names.
  /// The search is case-insensitive and updates the _filteredRequests state,
  /// which triggers UI rebuild to show only matching requests.
  /// If the query is empty, shows all requests.
  ///
  /// [query] - The search text entered by the user
  void _searchRequests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRequests = _requests;
      } else {
        _filteredRequests =
            _requests
                .where(
                  (req) => (req['name'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  /// Select an override request to view its details.
  ///
  /// Updates the _selectedRequest state with the chosen request's information,
  /// which causes the UI to display a details card showing full request information
  /// and approval options.
  ///
  /// [request] - Map containing request data (id, name, description, timestamp)
  void _selectRequest(Map<String, dynamic> request) {
    setState(() {
      _selectedRequest = {
        'id': request['id'],
        'name': request['name'],
        'description':
            request['description'] ??
            'This request is for the last dosage of Immunosupp...',
        'status': 'Pending',
      };
    });
  }

  /// Approve an override request and create the override.
  ///
  /// Validates that a request is selected, then uses FirebaseService.approveOverrideRequest()
  /// to approve the request. This creates an override record in the 'overrides' collection,
  /// updates the request status to 'approved', and sets approval timestamps.
  ///
  /// On success, clears the selection, shows a success message, and reloads
  /// the requests list to remove the approved request.
  ///
  /// Displays error messages if no request is selected or if the operation fails.
  Future<void> _createNewOverride() async {
    if (_selectedRequest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a request first')),
      );
      return;
    }

    try {
      // Use DoctorService to approve override request
      await DoctorService.instance.approveOverrideRequest(_selectedRequest!['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Override created successfully')),
        );

        // Clear selection and reload
        setState(() {
          _selectedRequest = null;
        });

        // Reload requests to remove approved one
        _loadOverrideRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating override: $e')));
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
                      'Override Requests',
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
                  onChanged: _searchRequests,
                  decoration: InputDecoration(
                    hintText: 'Search override...',
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
            // Requests list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ..._filteredRequests.map((request) {
                      return InkWell(
                        onTap: () => _selectRequest(request),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                _selectedRequest?['name'] == request['name']
                                    ? Border.all(
                                      color: const Color(0xFF6B46C1),
                                      width: 2,
                                    )
                                    : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                request['name'] ?? 'Unknown',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                request['timestamp'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    // Request details card
                    if (_selectedRequest != null)
                      Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nurse Requesting Override',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedRequest!['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${_selectedRequest!['status']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _createNewOverride,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B46C1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Create new override'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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
