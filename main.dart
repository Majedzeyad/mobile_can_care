import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/doctor_dashboard.dart';
import 'pages/patient_dashboard.dart';
import 'pages/nurse_dashboard.dart';
import 'pages/responsible_dashboard.dart';
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
      theme: AppTheme.defaultTheme, // Default theme for login/auth
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          print('User authenticated: ${user.email} with UID: ${user.uid}');
          return FutureBuilder<String?>(
            future: _firebaseServices
                .getUserRole(user.uid)
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    print(
                      'TIMEOUT: Fetching user role exceeded 10 seconds for UID: ${user.uid}',
                    );
                    return null;
                  },
                ),
            builder: (context, roleSnapshot) {
              print(
                'FutureBuilder state: ${roleSnapshot.connectionState}, hasError: ${roleSnapshot.hasError}, hasData: ${roleSnapshot.hasData}',
              );

              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Loading your dashboard...'),
                        const SizedBox(height: 8),
                        Text(
                          'UID: ${user.uid}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (roleSnapshot.hasError) {
                print('ERROR in FutureBuilder: ${roleSnapshot.error}');
                print('Error details: ${roleSnapshot.error.toString()}');
                // On error, default to patient dashboard
                return const PatientDashboard();
              }

              final role = roleSnapshot.data?.toLowerCase();
              print(
                'SUCCESS: User role fetched from FutureBuilder: "$role" for UID: ${user.uid}',
              );

              // Route to appropriate dashboard based on role with theme
              switch (role) {
                case 'doctor':
                  print('Routing to DoctorDashboard');
                  return Theme(
                    data: AppTheme.doctorTheme,
                    child: const DoctorDashboard(),
                  );
                case 'patient':
                  print('Routing to PatientDashboard');
                  return Theme(
                    data: AppTheme.patientTheme,
                    child: const PatientDashboard(),
                  );
                case 'nurse':
                  print('Routing to NurseDashboard');
                  return Theme(
                    data: AppTheme.nurseTheme,
                    child: const NurseDashboard(),
                  );
                case 'responsible':
                case 'responsibleparty':
                  print('Routing to ResponsibleDashboard');
                  return Theme(
                    data: AppTheme
                        .patientTheme, // Use patient theme for responsible
                    child: const ResponsibleDashboard(),
                  );
                default:
                  // Fallback to patient dashboard if role is unknown or null
                  print(
                    'FALLBACK: Unknown or null role ("$role"), defaulting to PatientDashboard',
                  );
                  return Theme(
                    data: AppTheme.patientTheme,
                    child: const PatientDashboard(),
                  );
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
