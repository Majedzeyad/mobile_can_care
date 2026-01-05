import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medical_record.dart';
import 'patient_appointment_management.dart';
import 'patient_profile.dart';

/// Patient Home Page
///
/// This is the main navigation container for the patient role in the CancerCare application.
/// It manages bottom navigation between different patient-related pages:
/// - Dashboard: Overview of patient information and health status
/// - Medical Records: View personal medical history and records
/// - Appointments: Manage and view upcoming appointments
/// - Profile: View and edit patient profile information
///
/// The widget uses a bottom navigation bar to switch between these different views,
/// maintaining the selected tab state throughout the session.
class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

/// State class for Patient Home Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Navigation between patient-related pages
/// - UI state for the patient interface
class _PatientHomeState extends State<PatientHome> {
  /// Current selected tab index in bottom navigation bar
  /// 0 = Dashboard, 1 = Medical Records, 2 = Appointments, 3 = Profile
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
        return const PatientDashboard();
      case 1:
        return const PatientMedicalRecord();
      case 2:
        return const PatientAppointmentManagement();
      case 3:
        return const PatientProfile();
      default:
        return const PatientDashboard();
    }
  }

  /// Builds the patient home navigation interface.
  ///
  /// Creates a scaffold with:
  /// - Light grey background for a clean, medical app aesthetic
  /// - Dynamic body content that changes based on selected navigation tab
  /// - Bottom navigation bar with four main sections: Home, Records, Appointments, Profile
  ///
  /// The navigation bar uses the app's purple theme color (0xFF6B46C1) for selected items
  /// and grey for unselected items, providing clear visual feedback for the current page.
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient home navigation scaffold
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
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
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
          'CancerCare - Patient Dashboard',
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
            const Icon(Icons.person, size: 100, color: Color(0xFF6B46C1)),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.email ?? 'Patient'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B46C1),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Patient Dashboard',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Text(
              'Patient features coming soon...',
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
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
    */
  }
}
