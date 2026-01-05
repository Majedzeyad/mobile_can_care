import 'package:flutter/material.dart';

/// Nurse Medication Detail Page
///
/// This page provides detailed medication management for a specific patient, organized
/// into tabs. Features include:
/// - Patient profile information
/// - Medications tab: Active medications with administration tracking
/// - Lab Tests tab: Lab results related to medication monitoring (placeholder)
/// - Imaging tab: Imaging studies related to treatment (placeholder)
/// - Override requests from doctors
/// - Search functionality
///
/// The page helps nurses track medication administration, monitor patient response,
/// and coordinate with doctors on medication-related decisions.
class NurseMedicationDetail extends StatefulWidget {
  const NurseMedicationDetail({super.key});

  @override
  State<NurseMedicationDetail> createState() => _NurseMedicationDetailState();
}

/// State class for Nurse Medication Detail Page
///
/// Manages:
/// - Current navigation index
/// - Selected tab index (Medications, Lab Tests, Imaging)
/// - Search controller
/// - Patient information
/// - Override requests list
/// - Active medications list with administration status
/// - UI state and interactions
class _NurseMedicationDetailState extends State<NurseMedicationDetail> {
  /// Current navigation index (2 for medications)
  int _currentIndex = 2;
  
  /// Currently selected tab index
  /// 0 = Medications, 1 = Lab Tests, 2 = Imaging
  int _selectedTab = 0; // 0: Medications, 1: Lab Tests, 2: Imaging
  
  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'patients' collection
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

  // TODO: Connect Firebase - Fetch from 'overrideRequests' collection
  // Override requests from doctors, reviewed by nurses
  /// List of medication override requests requiring nurse review
  /// Each request contains: message, requestedBy (doctor), reviewedBy (nurse),
  /// timestamp, patientId
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _overrideRequests = [
    {
      'message':
          'Pain medication override requested for Michael Brown (P-234567)',
      'requestedBy': 'Dr. Priya Patel',
      'reviewedBy': 'Olivia Thompson (You)',
      'timestamp': '2 hours ago',
      'patientId': 'P-234567',
    },
  ];

  // TODO: Connect Firebase - Fetch from 'prescriptions' collection
  // Medications prescribed by doctors, administered by nurses
  /// List of active medications for the patient
  /// Each medication contains: name, dosage, schedule, status (Administered/Next Dose/Available),
  /// statusColor, icon, prescribedBy (doctor), administeredBy (nurse), lastAdministered
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _activeMedications = [
    {
      'name': 'Metformin',
      'dosage': '850mg',
      'schedule': 'Twice daily (8:00 AM, 8:00 PM)',
      'status': 'Administered',
      'statusColor': Colors.green,
      'icon': Icons.medication,
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
      'lastAdministered': 'Today, 8:00 AM',
    },
    {
      'name': 'Insulin Glargine',
      'dosage': '20 units',
      'schedule': 'Once daily (9:00 PM)',
      'status': 'Next Dose in 2h',
      'statusColor': Colors.blue,
      'icon': Icons.medication,
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
    },
    {
      'name': 'Lisinopril',
      'dosage': '20mg',
      'schedule': 'Once daily (9:00 AM)',
      'status': 'Administered',
      'statusColor': Colors.green,
      'icon': Icons.medication,
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
      'lastAdministered': 'Today, 9:00 AM',
    },
    {
      'name': 'Atorvastatin',
      'dosage': '40mg',
      'schedule': 'Before bedtime (9:30 PM)',
      'status': 'Next Dose in 8h',
      'statusColor': Colors.blue,
      'icon': Icons.medication,
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
    },
    {
      'name': 'Ibuprofen',
      'dosage': '200mg',
      'schedule': 'As needed for pain',
      'status': 'Available',
      'statusColor': Colors.grey,
      'icon': Icons.medication,
      'prescribedBy': 'Dr. Robert Smith',
      'administeredBy': 'Olivia Thompson (You)',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                    '9:53',
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
                      'تفاصيل الدواء',
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
                      // TODO: Backend Integration - Search medications
                    },
                  ),
                ],
              ),
            ),
            // Patient summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        _patient['image'] != null &&
                                _patient['image'].isNotEmpty
                            ? NetworkImage(_patient['image'])
                            : null,
                    child:
                        _patient['image'] == null || _patient['image'].isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _patient['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                Expanded(child: _buildTab(context, 0, 'الأدوية')),
                Expanded(child: _buildTab(context, 1, 'التحاليل')),
                Expanded(child: _buildTab(context, 2, 'التصوير')),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildMedicationsContent();
      case 1:
        return _buildLabTestsContent();
      case 2:
        return _buildImagingContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMedicationsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              hintText: 'Search Medications',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              // todo: Filter medications by search query
            },
          ),
        ),
        const SizedBox(height: 16),
        // Add New Prescription button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // todo: Navigate to add prescription page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Add New Prescription'),
          ),
        ),
        const SizedBox(height: 24),
        // Pending Override Requests
        if (_overrideRequests.isNotEmpty) ...[
          Text(
            'Pending Override Requests (${_overrideRequests.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._overrideRequests.map(
            (request) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request['message'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // todo: Connect Firebase - Approve override request
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // todo: Connect Firebase - Reject override request
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        // Active Medications
        Text(
          'Active Medications (${_activeMedications.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._activeMedications.map((med) => _buildMedicationCard(med)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(medication['icon'], color: const Color(0xFF6B46C1), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${medication['name']} - ${medication['dosage']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medication['schedule'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (medication['statusColor'] as Color).withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: medication['statusColor'] as Color,
                    ),
                  ),
                  child: Text(
                    medication['status'],
                    style: TextStyle(
                      inherit: false,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: medication['statusColor'] as Color,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // todo: Show medication details
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabTestsContent() {
    return const Center(
      child: Text(
        'Lab Tests content will be displayed here',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildImagingContent() {
    return const Center(
      child: Text(
        'Imaging content will be displayed here',
        style: TextStyle(fontSize: 14, color: Colors.grey),
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
