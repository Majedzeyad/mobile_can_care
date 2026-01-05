// ============================================
// main.dart - Enhanced with Role-Based Navigation
// ============================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'Doctor/home.dart';
import 'Patient/patient_home.dart';
import 'Nurse/nurse_home.dart';
import 'Responsible/responsible_home.dart';
import 'services/firebase_services.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CanCare - Healthcare Management',
      theme: AppTheme.defaultTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firebaseServices.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen('Initializing...');
        }

        // User is authenticated
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: _firebaseServices
                .getUserRole(user.uid)
                .timeout(const Duration(seconds: 10), onTimeout: () => null),
            builder: (context, roleSnapshot) {
              // Loading user role
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen('Loading your dashboard...');
              }

              // Error or timeout - default to patient
              if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                return Theme(
                  data: AppTheme.patientTheme,
                  child: const PatientHome(),
                );
              }

              // Route based on role
              final role = roleSnapshot.data?.toLowerCase().trim();
              return _getHomeScreenForRole(role);
            },
          );
        }

        // User is not authenticated
        return const LoginPage();
      },
    );
  }

  /// Returns the appropriate home screen based on user role
  Widget _getHomeScreenForRole(String? role) {
    switch (role) {
      case 'doctor':
        return Theme(data: AppTheme.doctorTheme, child: const Dashdoctor());

      case 'nurse':
        return Theme(data: AppTheme.nurseTheme, child: const NurseHome());

      case 'patient':
        return Theme(data: AppTheme.patientTheme, child: const PatientHome());

      case 'responsible':
      case 'responsibleparty':
        return Theme(
          data: AppTheme.patientTheme,
          child: const ResponsibleHome(),
        );

      default:
        // Fallback to patient dashboard for unknown roles
        return Theme(data: AppTheme.patientTheme, child: const PatientHome());
    }
  }

  /// Builds a loading screen with message
  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: AppTheme.defaultTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
