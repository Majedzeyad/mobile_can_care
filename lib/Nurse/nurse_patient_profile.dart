import 'package:flutter/material.dart';
import 'nurse_medical_record.dart';

/// Nurse Patient Profile Page
///
/// This page displays comprehensive patient profile information for nurses.
/// Features include:
/// - Patient profile information (name, ID, age, assigned doctor and nurse)
/// - Active medications list with prescription and monitoring details
/// - Current condition/status description
/// - Contact information (phone, email, address, emergency contact)
///
/// The page provides nurses with complete patient information needed for care
/// coordination, medication monitoring, and patient communication.
class NursePatientProfile extends StatefulWidget {
  const NursePatientProfile({super.key});

  @override
  State<NursePatientProfile> createState() => _NursePatientProfileState();
}

/// State class for Nurse Patient Profile Page
///
/// Manages:
/// - Current navigation index
/// - Patient information
/// - Active medications list
/// - Current condition description
/// - Contact information
/// - UI state and interactions
class _NursePatientProfileState extends State<NursePatientProfile> {
  /// Current navigation index (3 for patient profile)
  int _currentIndex = 3;

  // TODO: Connect Firebase - Fetch patient data from 'patients' collection
  // Patient: Jane Cooper (P-123456) - Assigned to Dr. Robert Smith and Nurse Olivia Thompson
  /// Patient profile information
  /// Contains: name, patientId, age, assignedDoctor, assignedNurse, image
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Jane Cooper',
    'patientId': 'P-123456',
    'age': '45 years',
    'assignedDoctor': 'Dr. Robert Smith',
    'assignedNurse': 'Olivia Thompson (You)',
    'image': '', // todo: Load from Firebase Storage
  };

  // TODO: Connect Firebase - Fetch from 'prescriptions' collection
  // Medications prescribed by doctor, monitored by nurse
  /// List of active medications for the patient
  /// Each medication contains: name, dosage, prescribedBy (doctor), monitoredBy (nurse)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _activeMedications = [
    {
      'name': 'Metformin',
      'dosage': '850mg',
      'prescribedBy': 'Dr. Robert Smith',
      'monitoredBy': 'Olivia Thompson (You)',
    },
    {
      'name': 'Insulin Glargine',
      'dosage': '20 units',
      'prescribedBy': 'Dr. Robert Smith',
      'monitoredBy': 'Olivia Thompson (You)',
    },
    {
      'name': 'Lisinopril',
      'dosage': '20mg',
      'prescribedBy': 'Dr. Robert Smith',
      'monitoredBy': 'Olivia Thompson (You)',
    },
  ];

  // TODO: Connect Firebase - Fetch from 'medicalRecords' collection
  /// Current medical condition/status description for the patient
  /// Currently using dummy data, should be fetched from Firebase in production
  final String _currentCondition =
      'Patient is stable and responding well to diabetes treatment. HbA1c improving (8.5% to 8.0%). Regular monitoring by Nurse Olivia Thompson required. Next appointment with Dr. Robert Smith on 02/20/2024.';

  // TODO: Connect Firebase - Fetch from patient contact info
  /// Patient contact information
  /// Contains: phone, email, address, emergencyContact
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _contact = {
    'phone': '+1 (555) 123-4567',
    'email': 'jane.cooper@example.com',
    'address': '123 Main Street, City, State 12345',
    'emergencyContact': 'John Cooper (Husband) - +1 (555) 123-4568',
  };

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
                    '9:50',
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
                      'الملف الشخصي للمريض',
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
                      // TODO: Backend Integration - Edit patient profile
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
                    // Patient summary card
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
                                _patient['image'] != null &&
                                    _patient['image'].isNotEmpty
                                ? NetworkImage(_patient['image'])
                                : null,
                            child:
                                _patient['image'] == null ||
                                    _patient['image'].isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _patient['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_patient['patientId']} | ${_patient['age']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Active Medications
                    _buildSection(context, 'الأدوية النشطة', [
                      ..._activeMedications.map(
                        (med) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.medication,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${med['name']} - ${med['dosage']}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Current Condition
                    _buildSection(context, 'الحالة الحالية', [
                      Text(
                        _currentCondition,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Contact Info
                    _buildSection(context, 'معلومات الاتصال', [
                      _buildContactRow(Icons.phone, _contact['phone']),
                      const SizedBox(height: 12),
                      _buildContactRow(Icons.email, _contact['email']),
                      const SizedBox(height: 12),
                      _buildContactRow(Icons.location_on, _contact['address']),
                    ]),
                    const SizedBox(height: 16),
                    // Documents
                    _buildSection(context, 'الوثائق', [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NurseMedicalRecord(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('عرض السجل الطبي'),
                        ),
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

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
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

  Widget _buildContactRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
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
        // todo: Navigate to different pages
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
          icon: Icon(Icons.medication),
          label: 'الأدوية',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'الرسائل'),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'السجلات'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
      ],
    );
  }
}
