import 'package:flutter/material.dart';

/// Nurse Patient Detail Page
///
/// This page provides comprehensive patient information for nurses, organized into
/// tabs for easy navigation. Features include:
/// - Patient profile information (name, ID, age, assigned doctor and nurse)
/// - Allergies tab: List of patient allergies and sensitivities
/// - Treatment Plans tab: Active treatment plans with progress tracking and adherence
/// - Notes tab: Clinical notes and observations (placeholder)
/// - Billing tab: Billing history and invoice information
/// - Upcoming appointment information
///
/// The page helps nurses access detailed patient information needed for care
/// coordination, medication administration, and treatment monitoring.
class NursePatientDetail extends StatefulWidget {
  const NursePatientDetail({super.key});

  @override
  State<NursePatientDetail> createState() => _NursePatientDetailState();
}

/// State class for Nurse Patient Detail Page
///
/// Manages:
/// - Selected tab index (Allergies, Treatment Plans, Notes, Billing)
/// - Patient information
/// - Allergies list
/// - Treatment plan details with progress tracking
/// - Billing items list
/// - Upcoming appointment information
/// - UI state and interactions
class _NursePatientDetailState extends State<NursePatientDetail> {
  /// Currently selected tab index
  /// 0 = Allergies, 1 = Treatment Plans, 2 = Notes, 3 = Billing
  int _selectedTab =
      1; // 0: Allergies, 1: Treatment Plans, 2: Notes, 3: Billing

  // TODO: Connect Firebase - Fetch from 'patients' collection
  // Patient: Jane Cooper (P-123456) - Assigned to Dr. Robert Smith and Nurse Olivia Thompson
  /// Patient profile information
  /// Contains: name, patientId, age, assignedDoctor, assignedNurse
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _patient = {
    'name': 'Jane Cooper',
    'patientId': 'P-123456',
    'age': '45',
    'assignedDoctor': 'Dr. Robert Smith',
    'assignedNurse': 'Olivia Thompson (You)',
  };

  /// List of patient allergies and sensitivities
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<String> _allergies = ['Penicillin', 'Latex', 'Shellfish'];

  // TODO: Connect Firebase - Fetch from 'treatmentPlans' collection
  // Treatment plan created by doctor, monitored by nurse
  /// Active treatment plan information with progress tracking
  /// Contains: title, status, startDate, endDate, adherence percentage, type,
  /// provider (doctor), monitoredBy (nurse), lastUpdated, progress goals, note
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _treatmentPlan = {
    'title': 'Diabetes Management Plan',
    'status': 'Active',
    'startDate': '1/15/2024',
    'endDate': '7/15/2024',
    'adherence': 85,
    'type': 'Chronic Care - Diabetes Type 2',
    'provider': 'Dr. Robert Smith',
    'monitoredBy': 'Olivia Thompson (You)',
    'lastUpdated': '02/14/2024',
    'progress': [
      {'goal': 'Reduce HbA1c to below 7%', 'progress': 70},
      {'goal': 'Maintain daily medication adherence', 'progress': 90},
      {'goal': 'Lose 10 lbs through diet and exercise', 'progress': 60},
    ],
    'note':
        'Patient showing good progress with medication adherence (90%) but needs additional support with diet. Consider referral to nutritionist. Regular monitoring by Nurse Olivia Thompson.',
  };

  // TODO: Connect Firebase - Fetch from 'billing' collection
  /// List of billing items and invoices for the patient
  /// Each item contains: service, amount, status (Paid/Overdue), invoice number/date, orderedBy (doctor)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _billingItems = [
    {
      'service': 'Lab Tests - HbA1c, CBC, Lipid Panel',
      'amount': '\$150.00',
      'status': 'Paid',
      'invoice': 'Invoice #AP002 - 02/14/2024',
      'orderedBy': 'Dr. Robert Smith',
    },
    {
      'service': 'General Check-up',
      'amount': '\$120.00',
      'status': 'Paid',
      'invoice': 'Invoice #AP001 - 01/15/2024',
      'orderedBy': 'Dr. Robert Smith',
    },
    {
      'service': 'X-Ray - Chest',
      'amount': '\$80.00',
      'status': 'Overdue',
      'invoice': 'Invoice #AP003 - 02/10/2024',
      'orderedBy': 'Dr. Robert Smith',
    },
  ];

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  /// Information about the patient's next scheduled appointment
  /// Contains: date, time, doctor, nurse, room, reason
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _upcomingAppointment = {
    'date': '02/20/2024',
    'time': '10:00 AM',
    'doctor': 'Dr. Robert Smith',
    'nurse': 'Olivia Thompson (You)',
    'room': 'Room 201',
    'reason': 'Diabetes follow-up and medication review',
  };

  /// Builds the nurse patient detail UI with tabbed information sections.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title and back button
  /// - Patient profile card with basic information
  /// - Tab bar for switching between information sections (Allergies, Treatment Plans, Notes, Billing)
  /// - Tab content displaying relevant information based on selected tab
  /// - Upcoming appointment card
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete nurse patient detail UI
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
                      'تفاصيل المريض',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            // Tabs
            Row(
              children: [
                Expanded(child: _buildTab(context, 0, 'الحساسية')),
                Expanded(child: _buildTab(context, 1, 'خطط العلاج')),
                Expanded(child: _buildTab(context, 2, 'الملاحظات')),
                Expanded(child: _buildTab(context, 3, 'الفواتير')),
              ],
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildTabContent(),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next - ${_upcomingAppointment['date']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _upcomingAppointment['doctor'],
                        style: TextStyle(
                          inherit: false,
                          fontSize: 12,
                          color: Colors.grey[600],
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Backend Integration - Navigate to reschedule page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('إعادة الجدولة'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        return _buildAllergiesContent();
      case 1:
        return _buildTreatmentPlansContent();
      case 2:
        return _buildNotesContent();
      case 3:
        return _buildBillingContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAllergiesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Known Allergies:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._allergies.map(
          (allergy) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    allergy,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentPlansContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _treatmentPlan['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      _treatmentPlan['status'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${_treatmentPlan['startDate']} - ${_treatmentPlan['endDate']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Adherence: ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _treatmentPlan['adherence'] / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6B46C1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_treatmentPlan['adherence']}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // todo: Show overview
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Overview'),
              ),
              const SizedBox(height: 16),
              // Plan Detail
              Row(
                children: [
                  const Icon(Icons.description, color: Color(0xFF6B46C1)),
                  const SizedBox(width: 8),
                  const Text(
                    'Plan Detail',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Type', _treatmentPlan['type']),
              _buildDetailRow('Start Date', _treatmentPlan['startDate']),
              _buildDetailRow('End Date', _treatmentPlan['endDate']),
              _buildDetailRow('Provider', _treatmentPlan['provider']),
              _buildDetailRow('Last Updated', _treatmentPlan['lastUpdated']),
              const SizedBox(height: 16),
              // Progress Summary
              Row(
                children: [
                  const Icon(Icons.bar_chart, color: Color(0xFF6B46C1)),
                  const SizedBox(width: 8),
                  const Text(
                    'Progress Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...(_treatmentPlan['progress'] as List).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['goal'], style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: item['progress'] / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6B46C1),
                        ),
                      ),
                      Text(
                        '${item['progress']}%',
                        style: TextStyle(
                          inherit: false,
                          fontSize: 12,
                          color: Colors.grey[600],
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _treatmentPlan['note'],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildBillingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._billingItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['service'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        item['amount'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (item['status'] == 'Paid'
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            item['status'] == 'Paid'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            item['status'] == 'Paid'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['invoice'],
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
          ),
        ),
        // Upcoming
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next - ${_upcomingAppointment['date']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _upcomingAppointment['doctor'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // todo: Navigate to reschedule page
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6B46C1)),
                  foregroundColor: const Color(0xFF6B46C1),
                ),
                child: const Text('Reschedule'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesContent() {
    final TextEditingController _searchController = TextEditingController();

    // todo: Connect Firebase - Fetch from 'notes' collection
    final List<Map<String, dynamic>> _pendingNotes = [
      {
        'author': 'Dr. Emily Smith',
        'authorImage': '',
        'date': '24/09/2024',
        'content': 'Patient expressed concern about...',
      },
      {
        'author': 'Dr. John Doe',
        'authorImage': '',
        'date': '23/09/2024',
        'content': 'Follow-up required for medication...',
      },
    ];

    final List<Map<String, dynamic>> _previousNotes = [
      {
        'author': 'Dr. Sarah Johnson',
        'authorImage': '',
        'date': '20/09/2024',
        'content': 'Patient showing improvement...',
      },
      {
        'author': 'Nurse Olivia',
        'authorImage': '',
        'date': '18/09/2024',
        'content': 'Vitals checked, all normal...',
      },
    ];

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
              hintText: 'Search Notes',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              // todo: Filter notes by search query
            },
          ),
        ),
        const SizedBox(height: 16),
        // Add New Note button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // todo: Navigate to add note page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Add New Note'),
          ),
        ),
        const SizedBox(height: 24),
        // Pending Notes
        Text(
          'Pending Notes (${_pendingNotes.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._pendingNotes.map((note) => _buildNoteCard(note)),
        const SizedBox(height: 24),
        // Previous Notes
        Text(
          'Previous Notes (${_previousNotes.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._previousNotes.map((note) => _buildNoteCard(note, isPrevious: true)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, {bool isPrevious = false}) {
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
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                note['authorImage'] != null && note['authorImage'].isNotEmpty
                    ? NetworkImage(note['authorImage'])
                    : null,
            child:
                note['authorImage'] == null || note['authorImage'].isEmpty
                    ? const Icon(Icons.person, size: 20, color: Colors.grey)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['author'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPrevious ? Colors.grey[600] : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note['date'],
                  style: TextStyle(
                    inherit: false,
                    fontSize: 12,
                    color: Colors.grey[600],
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note['content'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isPrevious ? Colors.grey[500] : Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
