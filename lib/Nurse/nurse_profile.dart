import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_publication.dart';
import 'nurse_patient_management.dart';
import '../services/firebase_services.dart';

/// Nurse Profile Page
///
/// This page displays comprehensive profile information for the currently logged-in nurse.
/// Features include:
/// - Personal information (name, role, user ID, patient ID for multi-role users)
/// - Contact information (email, phone, department, shift schedule)
/// - Assigned doctors list (showing doctors the nurse works with)
/// - Patients under care (list of patients assigned to the nurse)
/// - Recent publications/posts from the healthcare community
/// - Language preferences
/// - Profile image display
///
/// Supports multi-role scenarios where nurses may also be patients, displaying
/// both nurse and patient information where applicable.
class NurseProfile extends StatefulWidget {
  const NurseProfile({super.key});

  @override
  State<NurseProfile> createState() => _NurseProfileState();
}

/// State class for Nurse Profile Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Nurse profile data
/// - Contact information
/// - Assigned doctors list
/// - Patients under care list
/// - Publications and language preferences
/// - UI state and interactions
class _NurseProfileState extends State<NurseProfile> {
  int _currentIndex = 5;

  // Firebase Integration
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  bool _isLoading = true;
  Map<String, dynamic> _nurse = {};
  Map<String, dynamic> _contact = {};
  List<Map<String, dynamic>> _assignedDoctors = [];
  int _patientsUnderCare = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);

      final nurseProfile = await _firebaseServices.getNurseProfile();
      final patients = await _firebaseServices.getNursePatients();

      if (mounted && nurseProfile != null) {
        setState(() {
          _nurse = {
            'name': nurseProfile.name ?? 'ممرض/ة',
            'role': 'Nurse', // NurseModel doesn't have role field
            'userId': nurseProfile.uid,
            'phone': nurseProfile.phone ?? '',
            'image': '',
          };

          _contact = {
            'email': '', // NurseModel doesn't have email field
            'phone': nurseProfile.phone ?? '',
            'department': nurseProfile.department ?? '',
            'shift': nurseProfile.shift ?? '',
          };

          _patientsUnderCare = patients.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Nurse Profile] Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Temporary placeholder - old data structure
  final List<Map<String, dynamic>> _assignedDoctorsOld = [
    {
      'name': 'Dr. Robert Smith',
      'specialty': 'Cardiology',
      'doctorId': 'DOC-001',
      'isAlsoPatient': true, // Dr. Smith is also a patient
      'patientId': 'P-DOC-002',
    },
    {
      'name': 'Dr. Priya Patel',
      'specialty': 'Oncology',
      'doctorId': 'DOC-002',
      'isAlsoPatient': true, // Dr. Patel is also a patient
      'patientId': 'P-DOC-001',
    },
    {
      'name': 'Dr. Emily Chen',
      'specialty': 'Internal Medicine',
      'doctorId': 'DOC-003',
      'isAlsoPatient': false,
    },
  ];

  // Temporary placeholder - old data structure
  final List<Map<String, dynamic>> _patientListOld = [
    {'name': 'Jane Cooper', 'patientId': 'P-123456', 'condition': 'Diabetes'},
    {
      'name': 'Michael Brown',
      'patientId': 'P-234567',
      'condition': 'Post-Surgery',
    },
    {'name': 'Kyle Smith', 'patientId': 'P-456789', 'condition': 'Fever'},
    {
      'name': 'Sarah Ahmed',
      'patientId': 'P-345678',
      'condition': 'Breast Cancer',
    },
    {
      'name': 'Dr. Priya Patel',
      'patientId': 'P-DOC-001',
      'condition': 'Diabetes (Also Doctor)',
    },
    {
      'name': 'Olivia Thompson',
      'patientId': 'P-NURSE-001',
      'condition': 'Routine Checkup (You)',
    },
  ];

  // todo: Connect Firebase - Fetch from 'publications' collection
  final String _lastPost =
      'For cancer patients, try including more antioxidants like blueberries and green tea. Shared by Dr. Priya Patel.';

  // todo: Connect Firebase - Fetch languages
  final List<String> _languages = ['Arabic', 'English', 'French'];

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
                    icon: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'الملف الشخصي',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Backend Integration - Edit profile
                    },
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Profile card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                _nurse['image'] != null &&
                                    _nurse['image'].isNotEmpty
                                ? NetworkImage(_nurse['image'])
                                : null,
                            child:
                                _nurse['image'] == null ||
                                    _nurse['image'].isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nurse['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nurse['role'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'User ID: ${_nurse['userId']}',
                            style: TextStyle(
                              inherit: false,
                              fontSize: 12,
                              color: Colors.grey[600],
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nurse['phone'],
                            style: TextStyle(
                              inherit: false,
                              fontSize: 12,
                              color: Colors.grey[600],
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Contact Information
                    _buildSection(context, 'معلومات الاتصال', [
                      _buildInfoRow(Icons.mail, _contact['email']),
                      _buildInfoRow(Icons.phone, _contact['phone']),
                      _buildInfoRow(Icons.business, _contact['department']),
                    ]),
                    const SizedBox(height: 16),
                    // Assigned Doctors
                    _buildSection(context, 'الأطباء المعينون', [
                      Text(
                        _assignedDoctors.map((d) => d['name']).join(', '),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Patients Under Care
                    _buildSection(context, 'المرضى تحت الرعاية', [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'حالياً تراقب $_patientsUnderCare مريض',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Last Seen Post
                    _buildSection(context, 'آخر منشور', [
                      Row(
                        children: [
                          Icon(
                            Icons.article,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _lastPost,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Languages
                    _buildSection(context, 'اللغات', [
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _languages.join(', '),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        // Navigate to different pages based on index
        Widget? destination;
        switch (index) {
          case 0:
            destination = const NurseDashboard();
            break;
          case 1:
            destination = const NurseAppointmentManagement();
            break;
          case 2:
            destination = const NurseMedicationManagement();
            break;
          case 3:
            destination = const NursePublication(); // Message/Publication page
            break;
          case 4:
            destination = const NursePatientManagement();
            break;
          case 5:
            // Already on Account/Profile page
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
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        inherit: true,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(inherit: true),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'المواعيد',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'الأدوية'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'الرسائل'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المرضى'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
      ],
    );
  }
}
