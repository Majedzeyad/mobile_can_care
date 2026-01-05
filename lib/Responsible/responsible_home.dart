import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/role_switcher.dart';
import '../services/firebase_services.dart';
import '../pages/login_page.dart';

/// Responsible Person Home Page
///
/// This is the main dashboard screen for users with the "Responsible" role.
/// Responsible persons are typically family members or guardians who manage
/// health information for patients who cannot manage it themselves.
///
/// Current features:
/// - Welcome message with user email display
/// - Role switcher for users with multiple roles
/// - Logout functionality
/// - Placeholder for future responsible person features
///
/// **Future Features** (coming soon):
/// - View patient information they are responsible for
/// - Manage appointments for patients
/// - Access medical records (with appropriate permissions)
/// - Medication management for patients
class ResponsibleHome extends StatefulWidget {
  const ResponsibleHome({super.key});

  @override
  State<ResponsibleHome> createState() => _ResponsibleHomeState();
}

/// State class for Responsible Home Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - UI state and user interactions
/// - Logout functionality
class _ResponsibleHomeState extends State<ResponsibleHome> {
  /// Current selected tab index in bottom navigation bar
  int _currentIndex = 0;

  /// Builds the responsible person dashboard UI.
  ///
  /// Creates a scaffold with:
  /// - AppBar with title, role switcher, and logout button
  /// - Centered welcome content with icon and user email
  /// - Bottom navigation bar (placeholder navigation items)
  ///
  /// The page currently displays a placeholder message indicating that
  /// responsible person features are coming soon.
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete responsible person dashboard UI
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'CancerCare - Responsible Dashboard',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          const RoleSwitcher(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await FirebaseServices.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.family_restroom,
              size: 100,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.email ?? 'Responsible Person'}',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Responsible for Patient Dashboard',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Responsible person features coming soon...',
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
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: theme.textTheme.labelSmall,
        unselectedLabelStyle: theme.textTheme.labelSmall,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'Records',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
