import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_publication.dart';
import 'nurse_profile.dart';
import 'nurse_patient_detail.dart';
import '../services/firebase_services.dart';

/// Nurse Patient Management Page
///
/// This page provides comprehensive patient management functionality for nurses.
/// Features include:
/// - Emergency patient alerts with immediate action requirements
/// - New patient notifications
/// - Patient list organized by priority (High, Medium, Routine)
/// - Search functionality to quickly find specific patients
/// - Patient cards showing condition, status, assigned doctor, and nurse
/// - Support for multi-role scenarios (doctors/nurses who are also patients)
/// - Bottom navigation to access other nurse-related pages
///
/// The page helps nurses prioritize patient care and manage their assigned
/// patients efficiently, with special emphasis on emergency situations.
class NursePatientManagement extends StatefulWidget {
  const NursePatientManagement({super.key});

  @override
  State<NursePatientManagement> createState() => _NursePatientManagementState();
}

/// State class for Nurse Patient Management Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Search controller for filtering patients
/// - Emergency patient information
/// - New patient information
/// - Patients organized by priority level
/// - UI interactions and navigation
class _NursePatientManagementState extends State<NursePatientManagement> {
  int _currentIndex = 4;
  final TextEditingController _searchController = TextEditingController();

  // Firebase Integration
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  
  bool _isLoading = true;
  Map<String, dynamic>? _emergencyPatient;
  Map<String, dynamic>? _newPatient;
  
  final Map<String, String> _prioritySections = {
    'High Priority': 'high',
    'Medium Priority': 'medium',
    'Routine Priority': 'routine',
  };

  Map<String, List<Map<String, dynamic>>> _patientsByPriority = {
    'high': [],
    'medium': [],
    'routine': [],
  };

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() => _isLoading = true);

      final patients = await _firebaseServices.getNursePatients();
      
      if (mounted) {
        final highPriority = <Map<String, dynamic>>[];
        final mediumPriority = <Map<String, dynamic>>[];
        final routinePriority = <Map<String, dynamic>>[];

        for (var patient in patients) {
          final priority = patient['priority'] as String? ?? 'routine';
          final patientData = {
            'name': patient['name'] ?? 'مريض',
            'age': patient['age']?.toString() ?? '',
            'patientId': patient['id'] ?? '',
            'condition': patient['condition'] ?? '',
            'status': patient['status'] ?? 'Stable',
            'assignedDoctor': patient['assignedDoctorName'] ?? '',
            'assignedNurse': 'You',
            'image': '',
          };

          if (priority == 'high' || priority == 'emergency') {
            highPriority.add(patientData);
            if (priority == 'emergency' && _emergencyPatient == null) {
              _emergencyPatient = {
                ...patientData,
                'message': patient['emergencyNote'] ?? 'Immediate attention required',
                'room': patient['room'] ?? '',
              };
            }
          } else if (priority == 'medium') {
            mediumPriority.add(patientData);
          } else {
            routinePriority.add(patientData);
          }

          // Check for new patients (added in last 24 hours)
          if (patient['createdAt'] != null) {
            final createdAt = (patient['createdAt'] as Timestamp).toDate();
            final hoursDiff = DateTime.now().difference(createdAt).inHours;
            if (hoursDiff < 24 && _newPatient == null) {
              _newPatient = {
                ...patientData,
                'type': 'Newly assigned patient',
              };
            }
          }
        }

        setState(() {
          _patientsByPriority = {
            'high': highPriority,
            'medium': mediumPriority,
            'routine': routinePriority,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Nurse Patient Management] Error loading patients: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  final Map<String, bool> _expandedSections = {
    'high': true,
    'medium': true,
    'routine': true,
  };

  int _currentPage = 1;
  final int _totalPages = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                      'مرضاي',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Backend Integration - Advanced search
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن المريض...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          // TODO: Backend Integration - Filter patients by search query
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Emergency banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'حالة طارئة',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Backend Integration - Call emergency contact
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red,
                                  minimumSize: const Size(100, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.phone, size: 18),
                                    SizedBox(width: 6),
                                    Text('اتصل الآن'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_emergencyPatient!['name']}, ${_emergencyPatient!['age']} - ${_emergencyPatient!['condition']}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _emergencyPatient!['message'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                            ),
                            const SizedBox(height: 16),
                        // New patient banner
                        if (_newPatient != null)
                          Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مريض جديد',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_newPatient!['name']} - ${_newPatient!['age']} سنة، ${_newPatient!['condition']}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                              ),
                            ),
                        const SizedBox(height: 24),
                        // Priority sections
                        ..._prioritySections.entries.map((entry) {
                      final priority = entry.value;
                      final patients = _patientsByPriority[priority] ?? [];
                      final count = patients.length;
                      final isExpanded = _expandedSections[priority] ?? false;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedSections[priority] = !isExpanded;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key == 'High Priority'
                                        ? 'أولوية عالية ($count)'
                                        : entry.key == 'Medium Priority'
                                            ? 'أولوية متوسطة ($count)'
                                            : 'أولوية عادية ($count)',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            ...patients.map(
                              (patient) => _buildPatientCard(
                                patient,
                                priority == 'high' || priority == 'medium'
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                              ],
                            ],
                          );
                        }),
                        // Pagination
                        Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed:
                              _currentPage > 1
                                  ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                  : null,
                          child: const Text('Previous'),
                        ),
                        Text(
                          'Page $_currentPage of $_totalPages',
                          style: const TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed:
                              _currentPage < _totalPages
                                  ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                  : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
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

  Widget _buildPatientCard(Map<String, dynamic> patient, Color statusColor) {
    return InkWell(
      onTap: () {
        // Navigate to patient detail page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NursePatientDetail()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  patient['image'] != null && patient['image'].isNotEmpty
                      ? NetworkImage(patient['image'])
                      : null,
              child:
                  patient['image'] == null || patient['image'].isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${patient['age']} years old, ${patient['condition']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                patient['status'],
                style: TextStyle(
                  inherit: false,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ),
          ],
        ),
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
            // Already on Patients page
            return;
          case 5:
            destination = const NurseProfile(); // Account/Profile
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
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        inherit: true,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        inherit: true,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'المواعيد',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'الأدوية',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'الرسائل'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المرضى'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
      ],
    );
  }
}
