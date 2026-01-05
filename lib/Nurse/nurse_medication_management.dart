import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_publication.dart';
import 'nurse_profile.dart';
import '../services/firebase_services.dart';

/// Nurse Medication Management Page
///
/// This page provides comprehensive medication management functionality for nurses.
/// Features include:
/// - Patient selector dropdown to filter medications by patient
/// - Search functionality to find specific medications
/// - Medication list showing dosage, timing, and status (Taken/Upcoming)
/// - Medication administration tracking
/// - Patient-medication relationships with assigned doctor and nurse
/// - Support for multi-role scenarios (nurses/doctors who are also patients)
/// - Medication request submission capability
/// - Bottom navigation to access other nurse-related pages
///
/// The page helps nurses track and administer medications for their assigned
/// patients, ensuring proper medication management and adherence.
class NurseMedicationManagement extends StatefulWidget {
  const NurseMedicationManagement({super.key});

  @override
  State<NurseMedicationManagement> createState() =>
      _NurseMedicationManagementState();
}

class _NurseMedicationManagementState extends State<NurseMedicationManagement> {
  int _currentIndex = 2;
  String? _selectedPatient;
  final TextEditingController _searchController = TextEditingController();

  // Firebase Integration
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final patients = await _firebaseServices.getNursePatients();
      final medications = await _firebaseServices.getNurseMedications();

      if (mounted) {
        setState(() {
          _patients = patients.map((p) => {
            'name': p['name'] ?? 'مريض',
            'patientId': p['id'] ?? '',
            'assignedDoctor': p['assignedDoctorName'] ?? '',
            'assignedNurse': 'You',
          }).toList();

          _medications = medications.map((med) => {
            'name': med['medicationName'] ?? med['name'] ?? 'دواء',
            'dosage': med['dosage'] ?? '',
            'time': med['time'] ?? '',
            'status': med['status'] ?? 'Upcoming',
            'patient': med['patientName'] ?? 'مريض',
            'patientId': med['patientId'] ?? '',
            'prescribedBy': med['doctorName'] ?? '',
            'administeredBy': 'You',
            'image': '',
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Nurse Medication Management] Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredMedications {
    if (_selectedPatient == null || _selectedPatient == 'all') {
      return _medications;
    }
    return _medications
        .where((med) => med['patientId'] == _selectedPatient)
        .toList();
  }

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medication,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'إدارة الأدوية',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            // TODO: Backend Integration - Show menu
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
                          // Patient selector
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedPatient,
                                hint: const Text('اختر المريض'),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'all',
                                    child: Text('جميع المرضى'),
                                  ),
                                  ..._patients.map((patient) {
                                    return DropdownMenuItem(
                                      value: patient['patientId'],
                                      child: Text(
                                        '${patient['name']} (${patient['patientId']})',
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPatient = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Search bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'ابحث عن الدواء...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.colorScheme.primary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Medications list
                          Text(
                            'الأدوية (${_filteredMedications.length})',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_filteredMedications.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'لا توجد أدوية',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._filteredMedications.map(
                              (medication) => _buildMedicationCard(medication, theme),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildMedicationCard(
    Map<String, dynamic> medication,
    ThemeData theme,
  ) {
    final statusColor = medication['status'] == 'Taken'
        ? Colors.green
        : medication['status'] == 'Missed'
            ? Colors.red
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication['dosage'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  medication['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                medication['time'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${medication['patient']} (${medication['patientId']})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.medical_services, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'وصفه: ${medication['prescribedBy']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        Widget? destination;
        switch (index) {
          case 0:
            destination = const NurseDashboard();
            break;
          case 1:
            destination = const NurseAppointmentManagement();
            break;
          case 2:
            // Already on Medications page
            return;
          case 3:
            destination = const NursePublication();
            break;
          case 4:
            destination = const NurseProfile();
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
      unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(inherit: true),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Publications'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
