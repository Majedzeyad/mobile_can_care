import 'package:flutter/material.dart';
import 'doctor_detail.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'override_requests.dart';
import 'patient_list.dart';
import 'medications.dart';
import 'lab_test_request.dart';
import '../components/role_switcher.dart';
import '../services/doctor_service.dart';

/// Doctor Dashboard Page (UI Layer)
///
/// This is the main dashboard screen for doctors. It displays:
/// - Dashboard statistics (active patients, pending lab results, recent prescriptions)
/// - Quick action buttons
/// - Search functionality
/// - Bottom navigation to other pages
///
/// **Architecture**: This page uses DashboardService to fetch data,
/// keeping Firebase logic separate from UI code.
class Dashdoctor extends StatefulWidget {
  const Dashdoctor({super.key});

  @override
  State<Dashdoctor> createState() => DdashdoctorState();
}

/// State class for Doctor Dashboard
///
/// Manages:
/// - Dashboard statistics state
/// - Search controller
/// - Navigation state
/// - UI interactions
class DdashdoctorState extends State<Dashdoctor> {
  // ==================== State Variables ====================

  /// Current selected tab index in bottom navigation
  int _currentIndex = 0;

  /// Controller for search text field
  final TextEditingController _searchController = TextEditingController();

  // ==================== Dashboard Statistics ====================

  /// Count of active patients under this doctor's care
  int activePatients = 0;

  /// Count of pending lab test requests awaiting review
  int pendingLabResults = 0;

  /// Count of prescriptions created in the last 7 days
  int recentPrescriptions = 0;

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads dashboard data from Firebase.
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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

  /// Load all dashboard statistics from Firebase.
  ///
  /// Uses DoctorService.getDashboardStats() to fetch:
  /// - Active patients count
  /// - Pending lab results count
  /// - Recent prescriptions count (last 7 days)
  ///
  /// Updates the UI state with the fetched data. Displays error messages if loading fails.
  Future<void> _loadDashboardData() async {
    try {
      // Use DoctorService to fetch all statistics
      final stats = await DoctorService.instance.getDashboardStats();

      // Update UI state with fetched data
      if (mounted) {
        setState(() {
          activePatients = stats['activePatients'] ?? 0;
          pendingLabResults = stats['pendingLabTests'] ?? 0;
          recentPrescriptions = stats['recentPrescriptions'] ?? 0;
        });
      }
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle search input from search bar
  ///
  /// Currently a placeholder. Can be extended to:
  /// - Search patients by name/diagnosis
  /// - Search lab results
  /// - Search prescriptions
  ///
  /// @param query The search text entered by user
  void _searchPatients(String query) {
    // todo: Implement search functionality
    // This could navigate to a search results page
    // or filter data on the current page
  }

  /// Navigate to prescription creation form
  ///
  /// Placeholder for future prescription form implementation.
  /// Will allow doctors to create new prescriptions.
  void _writeNewPrescription() {
    // todo: Navigate to prescription form page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prescription form - to be implemented')),
    );
  }

  /// Navigate to lab results review page
  ///
  /// Opens the page where doctors can review and add notes to lab test results.
  void _reviewTestResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LabResultsReview()),
    );
  }

  /// Navigate to override requests page
  ///
  /// Opens the page where doctors can approve/reject nurse override requests.
  void _overrideNurseActions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OverrideRequests()),
    );
  }

  /// Create a new general request
  ///
  /// Navigates to Lab Test Request page to create a new lab test request.
  void _createNewRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LabTestRequest()),
    );

    /* FIREBASE CODE COMMENTED OUT - Using local data instead
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Create request in Firestore
      await FirebaseFirestore.instance.collection('requests').add({
        'doctorId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'type': 'general',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating request: $e')));
      }
    }
    */
  }

  // ==================== UI Build Methods ====================

  /// Build the main widget tree for the dashboard
  ///
  /// Constructs the complete UI including:
  /// - Status bar simulation
  /// - Header with profile and search
  /// - Dashboard statistics cards
  /// - Quick action buttons
  /// - Bottom navigation bar
  ///
  /// @return Widget The complete dashboard UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar area (simulated)
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
            // Header section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Title
                  Text(
                    'CancerCare - Doctor Dashboard',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Profile and Dashboard bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Dashboard',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const RoleSwitcher(iconColor: Color(0xFF6B46C1)),
                          IconButton(
                            icon: const Icon(
                              Icons.grid_view,
                              color: Color(0xFF6B46C1),
                            ),
                            onPressed: () {
                              // Navigate to Medications page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Medications(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              // Navigate to Doctor Detail/Profile page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DoctorDetail(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
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
                        hintText: 'Search patients or results',
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
                ],
              ),
            ),
            // Metrics section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Active Patients',
                            activePatients.toString(),
                            const Color(0xFF6B46C1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Pending Lab Results',
                            pendingLabResults.toString(),
                            const Color(0xFF6B46C1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Recent Prescriptions card (highlighted and clickable)
                    InkWell(
                      onTap: () {
                        // Navigate to Medications page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Medications(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9D5FF), // Light purple
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6B46C1).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent Prescriptions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recentPrescriptions.toString(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'From last week',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          Icons.edit,
                          'Write New\nPrescription',
                          _writeNewPrescription,
                        ),
                        _buildQuickAction(
                          Icons.folder,
                          'Review Test\nResults',
                          _reviewTestResults,
                        ),
                        _buildQuickAction(
                          Icons.swap_horiz,
                          'Override Nurse\nActions',
                          _overrideNurseActions,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // New Request button
                    InkWell(
                      onTap: _createNewRequest,
                      child: Container(
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
                            Icon(
                              Icons.description,
                              color: const Color(0xFF6B46C1),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'New Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Navigate to different screens based on index
            Widget? destination;
            switch (index) {
              case 0:
                // Already on Home (Dashdoctor)
                return;
              case 1:
                destination = const PatientList();
                break;
              case 2:
                destination = const LabResultsReview();
                break;
              case 3:
                destination = const Medications();
                break;
              case 4:
                destination = const MedicalRecords();
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
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: theme.textTheme.labelSmall,
          unselectedLabelStyle: theme.textTheme.labelSmall,
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
              icon: Icon(Icons.medication),
              label: 'Medications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  /// Build a metric card widget
  ///
  /// Creates a card displaying a single dashboard statistic.
  /// Used for displaying counts like active patients, pending lab results, etc.
  ///
  /// @param title The label for the metric (e.g., "Active Patients")
  /// @param value The numeric value to display
  /// @param color The color theme for the card
  ///
  /// @return Widget A styled card showing the metric
  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a quick action button widget
  ///
  /// Creates a tappable card with an icon and label for quick actions.
  /// Used for actions like "Write Prescription", "Review Test Results", etc.
  ///
  /// @param icon The icon to display
  /// @param label The text label (can be multi-line)
  /// @param onTap Callback function when button is tapped
  ///
  /// @return Widget A styled action button
  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
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
          children: [
            Icon(icon, size: 32, color: const Color(0xFF6B46C1)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B46C1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
