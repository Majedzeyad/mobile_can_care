import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_patient_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_profile.dart';

/// Nurse Home Page
///
/// This is the main navigation container for the nurse role in the CancerCare application.
/// It manages bottom navigation between different nurse-related pages:
/// - Dashboard: Overview of nurse's schedule, tasks, and quick actions
/// - Patients: Patient management and care coordination
/// - Medications: Medication administration and tracking
/// - Profile: Nurse profile and professional information
///
/// The widget uses a bottom navigation bar to switch between these different views,
/// maintaining the selected tab state throughout the session.
class NurseHome extends StatefulWidget {
  const NurseHome({super.key});

  @override
  State<NurseHome> createState() => _NurseHomeState();
}

/// State class for Nurse Home Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Navigation between nurse-related pages
/// - UI state for the nurse interface
class _NurseHomeState extends State<NurseHome> {
  /// Current selected tab index in bottom navigation bar
  /// 0 = Dashboard, 1 = Patients, 2 = Medications, 3 = Profile
  int _currentIndex = 0;

  /// Get the current page widget based on bottom navigation index.
  ///
  /// Returns the appropriate page widget corresponding to the currently
  /// selected tab in the bottom navigation bar. This method enables seamless
  /// page switching without losing state.
  ///
  /// Returns: Widget - The page widget for the current tab
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const NurseDashboard();
      case 1:
        return const NursePatientManagement();
      case 2:
        return const NurseMedicationManagement();
      case 3:
        return const NurseProfile();
      default:
        return const NurseDashboard();
    }
  }

  /// Builds the nurse home navigation interface.
  ///
  /// Creates a scaffold with:
  /// - Light grey background for a clean, medical app aesthetic
  /// - Dynamic body content that changes based on selected navigation tab
  /// - Bottom navigation bar with four main sections: Home, Patients, Medications, Profile
  ///
  /// The navigation bar uses the app's purple theme color (0xFF6B46C1) for selected items
  /// and grey for unselected items, providing clear visual feedback for the current page.
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete nurse home navigation scaffold
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: theme.textTheme.labelSmall,
        unselectedLabelStyle: theme.textTheme.labelSmall,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );

    /* FIREBASE CODE COMMENTED OUT - Using local data instead
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'CancerCare - Nurse Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        actions: [
          const RoleSwitcher(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_hospital,
              size: 100,
              color: Color(0xFF6B46C1),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.email ?? 'Nurse'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B46C1),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Nurse Dashboard',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Text(
              'Nurse features coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6B46C1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
    */
  }
}
