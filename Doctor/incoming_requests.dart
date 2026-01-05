import 'package:flutter/material.dart';
import 'home.dart';
import 'patient_list.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'medications.dart';
import 'doctor_detail.dart';
import '../services/doctor_service.dart';

/// Incoming Requests Page (UI Layer)
///
/// This page displays transfer requests from other doctors/nurses
/// to transfer patients to the current doctor.
/// Features:
/// - List of pending transfer requests
/// - Accept/reject request functionality
/// - Search functionality
///
/// **Architecture**: Uses RequestService to handle
/// all Firebase operations, keeping UI separate from data logic.
class IncomingRequests extends StatefulWidget {
  const IncomingRequests({super.key});

  @override
  State<IncomingRequests> createState() => _IncomingRequestsState();
}

/// State class for Incoming Requests Page
///
/// Manages:
/// - List of transfer requests
/// - Filtered/search results
/// - Search controller
/// - Navigation state
class _IncomingRequestsState extends State<IncomingRequests> {
  // ==================== State Variables ====================

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  /// Current selected tab index in bottom navigation
  int _currentIndex = 4; // Settings tab is active

  // ==================== Transfer Requests Data ====================

  /// Complete list of all transfer requests (unfiltered)
  List<Map<String, dynamic>> _requests = [];

  /// Filtered list of requests based on search query
  List<Map<String, dynamic>> _filteredRequests = [];

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads transfer requests from Firebase via RequestService.
  @override
  void initState() {
    super.initState();
    _filteredRequests = _requests;
    _loadIncomingRequests();
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

  /// Load all pending transfer requests from Firebase.
  ///
  /// Uses FirebaseService.getPendingTransferRequests() to fetch transfer requests
  /// from Firebase. Updates both _requests (complete list) and _filteredRequests
  /// (search results) lists with the fetched data.
  ///
  /// The method checks if the widget is still mounted before updating state
  /// to prevent errors if the widget is disposed during the async operation.
  /// Displays error messages if loading fails.
  Future<void> _loadIncomingRequests() async {
    try {
      // Use DoctorService to fetch transfer requests
      final requests = await DoctorService.instance
          .getPendingTransferRequests();

      if (mounted) {
        setState(() {
          _requests = requests.map((request) {
            return {
              'id': request['id'],
              'name': request['patientName'] ?? 'Unknown',
              'type': request['requestType'] ?? 'transfer request',
              'isNew': !(request['isRead'] ?? false),
              'timestamp': request['formattedDate'] ?? 'Unknown',
            };
          }).toList();
          _filteredRequests = _requests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading requests: $e')));
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle search input and filter the transfer requests list in real-time.
  ///
  /// Filters requests by matching the search query against patient names.
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
        _filteredRequests = _requests
            .where(
              (req) => (req['name'] ?? '').toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  /// Accept a transfer request from another healthcare provider.
  ///
  /// Uses FirebaseService.acceptTransferRequest() to update the request status
  /// to 'accepted' in Firestore, which also transfers the patient record to the
  /// current doctor and sets timestamps.
  ///
  /// On success, removes the request from the list and shows a success message.
  /// Displays error messages if the operation fails.
  ///
  /// [request] - Map containing request data (id, name, type, timestamp, etc.)
  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    try {
      // Use DoctorService to accept the request
      await DoctorService.instance.acceptTransferRequest(request['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Accepted ${request['name']}\'s request')),
        );

        // Remove from list
        setState(() {
          _requests.remove(request);
          _filteredRequests = _requests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error accepting request: $e')));
      }
    }
  }

  /// Reject a transfer request from another healthcare provider.
  ///
  /// Uses FirebaseService.rejectTransferRequest() to update the request status
  /// to 'rejected' in Firestore, which also sets 'rejectedBy' and 'rejectedAt'
  /// timestamp fields.
  ///
  /// On success, removes the request from the list and shows a success message.
  /// Displays error messages if the operation fails.
  ///
  /// [request] - Map containing request data (id, name, type, timestamp, etc.)
  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    try {
      // Use DoctorService to reject the request
      await DoctorService.instance.rejectTransferRequest(request['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rejected ${request['name']}\'s request')),
        );

        // Remove from list
        setState(() {
          _requests.remove(request);
          _filteredRequests = _requests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rejecting request: $e')));
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
                      'Incoming Requests',
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
                    hintText: 'Search requests...',
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = _filteredRequests[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: request['isNew']
                          ? const Color(0xFFE9D5FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: request['isNew']
                          ? Border.all(color: const Color(0xFF6B46C1), width: 2)
                          : null,
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
                          child: const Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (request['isNew'])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B46C1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'New Request',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (request['isNew']) const SizedBox(height: 4),
                              Text(
                                '${request['name']} ${request['type']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request['timestamp'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.check, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Accept'),
                                ],
                              ),
                              onTap: () => _acceptRequest(request),
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.close, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Reject'),
                                ],
                              ),
                              onTap: () => _rejectRequest(request),
                            ),
                          ],
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
