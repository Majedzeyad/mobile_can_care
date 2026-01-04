import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import 'home.dart';
import 'patient_list.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'medications.dart';

/// Doctor Detail Page (UI Layer)
///
/// This page displays the current doctor's profile information.
/// Features:
/// - Personal information (name, age, gender, blood type, etc.)
/// - Professional information (specialization, experience)
/// - Contact information
/// - Documents download (placeholder)
///
/// **Architecture**: Uses DoctorService to handle
/// all Firebase operations, keeping UI separate from data logic.
class DoctorDetail extends StatefulWidget {
  const DoctorDetail({super.key});

  @override
  State<DoctorDetail> createState() => _DoctorDetailState();
}

/// State class for Doctor Detail Page
///
/// Manages:
/// - Doctor profile data
/// - Navigation state
class _DoctorDetailState extends State<DoctorDetail> {
  // ==================== State Variables ====================

  /// Current selected tab index in bottom navigation
  int _currentIndex = 0;

  // ==================== Doctor Profile Data ====================

  /// Doctor profile information
  /// Contains: name, doctorId, nationalId, age, gender, bloodType,
  /// nationality, specialization, experience, contactName, phone, email
  Map<String, dynamic> _doctor = {
    'name': 'Unknown',
    'doctorId': 'Unknown',
    'nationalId': 'Unknown',
    'age': '0',
    'gender': 'Unknown',
    'bloodType': 'Unknown',
    'nationality': 'Unknown',
    'specialization': 'Unknown',
    'experience': 'No experience information available.',
    'contactName': 'Unknown',
    'phone': 'Unknown',
    'email': 'Unknown',
  };

  // ==================== Lifecycle Methods ====================

  /// Initialize the widget state
  ///
  /// Called when the widget is first created.
  /// Loads doctor profile from Firebase via DoctorService.
  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();
  }

  // ==================== Data Loading Methods ====================

  /// Load doctor profile information from Firebase.
  ///
  /// Fetches the current doctor's profile using DoctorService.getDoctorProfile().
  /// Updates the _doctor state map with the fetched data if successful.
  /// Displays appropriate error or warning messages if the profile doesn't exist
  /// or if the loading operation fails.
  ///
  /// The method checks if the widget is still mounted before updating state to
  /// prevent errors if the widget is disposed during the async operation.
  Future<void> _loadDoctorDetails() async {
    try {
      // Use DoctorService to fetch doctor profile
      final doctorModel = await DoctorService.instance.getDoctorProfile();
      if (doctorModel != null && mounted) {
        setState(() {
          _doctor = {
            'name': doctorModel.name ?? 'Unknown',
            'doctorId': doctorModel.uid,
            'nationalId': 'N/A',
            'age': 'N/A',
            'gender': 'N/A',
            'bloodType': 'N/A',
            'nationality': 'N/A',
            'specialization': doctorModel.specialization ?? 'Unknown',
            'experience': 'N/A',
            'contactName': 'N/A',
            'phone': doctorModel.phone ?? 'N/A',
            'email': doctorModel.email ?? 'N/A',
          };
        });
      } else if (mounted) {
        // Profile doesn't exist yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Doctor profile not found. Please complete your profile.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading doctor details: $e')),
        );
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle document download action.
  ///
  /// Placeholder method for future document download functionality.
  /// When implemented, this would integrate with Firebase Storage to download
  /// doctor-related documents (certificates, licenses, etc.).
  /// Currently shows a snackbar message indicating the feature is in development.
  void _downloadDocuments() {
    // TODO: Implement document download using Firebase Storage
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading documents...')));
  }

  /// Builds the doctor detail/profile UI.
  ///
  /// Creates a scrollable interface displaying the doctor's complete profile
  /// information including:
  /// - Personal information section (name, age, gender, blood type, nationality)
  /// - Professional information section (specialization, experience)
  /// - Contact information section (phone, email, emergency contact)
  /// - Documents section (placeholder for document downloads)
  /// - Bottom navigation bar for accessing other doctor pages
  ///
  /// The UI uses cards and organized sections for clear presentation of information.
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete doctor detail page UI
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
                      'Doctors Detail',
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Doctor Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person, size: 50),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Name', _doctor['name']),
                          _buildInfoRow('Doctor ID', _doctor['doctorId']),
                          _buildInfoRow('National id', _doctor['nationalId']),
                          _buildInfoRow('Age', _doctor['age']),
                          _buildInfoRow('Gender', _doctor['gender']),
                          _buildInfoRow('Blood Type', _doctor['bloodType']),
                          _buildInfoRow('Nationality', _doctor['nationality']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Specialization Card
                    _buildSectionCard(
                      'Specialization',
                      _doctor['specialization'],
                    ),
                    const SizedBox(height: 16),
                    // Experience Card
                    _buildSectionCard('Experience', _doctor['experience']),
                    const SizedBox(height: 16),
                    // Contact Information Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(_doctor['contactName']),
                          const SizedBox(height: 8),
                          Text(_doctor['phone']),
                          const SizedBox(height: 8),
                          Text(_doctor['email']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Documents & Reports Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                            'Documents & Reports',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('All information details'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _downloadDocuments,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B46C1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Download'),
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
              // Already on Profile page
              return;
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
