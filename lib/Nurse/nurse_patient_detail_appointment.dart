import 'package:flutter/material.dart';

/// Nurse Patient Detail Appointment Page
///
/// This page displays patient appointment information organized into tabs for nurses.
/// Features include:
/// - Lab Results tab: Lab test results for the patient (placeholder)
/// - Appointment History tab: Past, upcoming, and canceled appointments with sub-tabs
/// - Clinical Notes tab: Clinical documentation and notes
/// - Upcoming appointment information
/// - Next appointment details
///
/// The page helps nurses view comprehensive appointment-related information for
/// patients and coordinate care based on appointment schedules and history.
class NursePatientDetailAppointment extends StatefulWidget {
  const NursePatientDetailAppointment({super.key});

  @override
  State<NursePatientDetailAppointment> createState() =>
      _NursePatientDetailAppointmentState();
}

/// State class for Nurse Patient Detail Appointment Page
///
/// Manages:
/// - Selected main tab index (Lab Results, Appointment History, Clinical Notes)
/// - Selected sub-tab index for appointment history (Upcoming, Past, Canceled)
/// - Upcoming appointment information
/// - Clinical notes list
/// - Next appointment information
/// - UI state and interactions
class _NursePatientDetailAppointmentState
    extends State<NursePatientDetailAppointment> {
  /// Currently selected main tab index
  /// 0 = Lab Results, 1 = Appointment History, 2 = Clinical Notes
  int _selectedTab =
      1; // 0: Lab Results, 1: Appointment History, 2: Clinical Notes
  
  /// Currently selected sub-tab index for appointment history filtering
  /// 0 = Upcoming, 1 = Past, 2 = Canceled
  int _selectedSubTab = 0; // 0: Upcoming, 1: Past, 2: Canceled

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  /// Information about the next upcoming appointment
  /// Contains: date, title, time, fullDate, status
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _upcomingAppointment = {
    'date': '15 MAR',
    'title': 'Annual Checkup',
    'time': '09:00 - 10:00',
    'fullDate': '15/03/2024',
    'status': 'Approved',
  };

  // TODO: Connect Firebase - Fetch from 'clinicalNotes' collection
  /// List of clinical notes and documentation
  /// Each note contains: date, title, files (file count)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _clinicalNotes = [
    {'date': 'January 25', 'title': 'X-Ray', 'files': '2 files'},
    {'date': 'September 15, 2024', 'title': 'Prescription', 'files': '1 file'},
    {
      'date': 'September 15, 2024',
      'title': 'Diabetes Follow-up Visit',
      'files': '3 files',
    },
  ];

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  /// Information about the next scheduled appointment
  /// Contains: date, doctor
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _nextAppointment = {
    'date': '15/03/2024',
    'doctor': 'Dr. Brian Thomas',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      'Patient Detail',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
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
                Expanded(child: _buildTab(0, 'Lab Results')),
                Expanded(child: _buildTab(1, 'Appointment History')),
                Expanded(child: _buildTab(2, 'Clinical Notes')),
              ],
            ),
            // Sub-tabs (only for Appointment History)
            if (_selectedTab == 1)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _buildSubTab(0, 'Upcoming')),
                    Expanded(child: _buildSubTab(1, 'Past Appointments')),
                    Expanded(child: _buildSubTab(2, 'Canceled')),
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
                        'Next - ${_nextAppointment['date']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _nextAppointment['doctor'],
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
                      // todo: Navigate to reschedule page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reschedule'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
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
              color: isSelected ? const Color(0xFF6B46C1) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF6B46C1) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(int index, String label) {
    final isSelected = _selectedSubTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubTab = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B46C1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            inherit: false,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[600],
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildLabResultsContent();
      case 1:
        return _buildAppointmentHistoryContent();
      case 2:
        return _buildClinicalNotesContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildLabResultsContent() {
    return const Center(
      child: Text(
        'Lab Results content will be displayed here',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildAppointmentHistoryContent() {
    if (_selectedSubTab == 0) {
      // Upcoming
      return Container(
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _upcomingAppointment['date'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B46C1),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _upcomingAppointment['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_upcomingAppointment['time']} | ${_upcomingAppointment['fullDate']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
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
                    _upcomingAppointment['status'],
                    style: const TextStyle(
                      inherit: false,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // todo: Navigate to reschedule page
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6B46C1)),
                      foregroundColor: const Color(0xFF6B46C1),
                    ),
                    child: const Text('Reschedule'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // todo: Connect Firebase - Cancel appointment
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Past or Canceled
      return Center(
        child: Text(
          _selectedSubTab == 1
              ? 'Past appointments will be displayed here'
              : 'Canceled appointments will be displayed here',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildClinicalNotesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Clinical Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                // todo: Show more notes
              },
              child: const Row(
                children: [
                  Text(
                    'See more',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B46C1)),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: Color(0xFF6B46C1)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._clinicalNotes.map(
          (note) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.grey, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          note['title'],
                          style: const TextStyle(
                            inherit: false,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note['files'],
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
                  IconButton(
                    icon: const Icon(Icons.download, color: Color(0xFF6B46C1)),
                    onPressed: () {
                      // todo: Connect Firebase - Download files
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
