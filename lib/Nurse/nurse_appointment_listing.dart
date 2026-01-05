import 'package:flutter/material.dart';

/// Nurse Appointment Listing Page
///
/// This page displays a detailed timeline view of appointments for selected days.
/// Features include:
/// - Day selector for viewing appointments across multiple days
/// - Timeline view with time markers for easy scheduling reference
/// - Appointment cards showing patient, doctor, nurse, time, and status
/// - Status indicators (Completed, Cancelled, Examining, Upcoming) with color coding
/// - Support for multi-role scenarios (e.g., doctors who are also patients)
/// - Click-to-expand appointment details
///
/// This view helps nurses see their daily schedule at a glance and manage
/// appointment flow throughout the day.
class NurseAppointmentListing extends StatefulWidget {
  const NurseAppointmentListing({super.key});

  @override
  State<NurseAppointmentListing> createState() =>
      _NurseAppointmentListingState();
}

/// State class for Nurse Appointment Listing Page
///
/// Manages:
/// - Selected day index for filtering appointments
/// - List of days available for viewing
/// - List of appointments with status information
/// - Time markers for timeline display
/// - UI interactions and navigation
class _NurseAppointmentListingState extends State<NurseAppointmentListing> {
  /// Index of the currently selected day (2 = Wednesday in the example)
  int _selectedDayIndex = 2; // Wednesday selected

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  /// List of day labels for the day selector (format: "DD Day")
  /// Currently using dummy data, should be dynamically generated in production
  final List<String> _days = ['17 Mon', '18 Tue', '19 Wed', '20 Thu'];

  // Appointments showing nurse-doctor-patient relationships
  /// List of appointments for the selected day(s)
  /// Each appointment contains: time, patient, patientId, doctor, nurse,
  /// status, statusColor, and optional note field
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _appointments = [
    {
      'time': '10:00',
      'patient': 'Jane Cooper',
      'patientId': 'P-123456',
      'doctor': 'Dr. Robert Smith',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Completed',
      'statusColor': Colors.green,
    },
    {
      'time': '10:30',
      'patient': 'John Doe',
      'patientId': 'P-111222',
      'doctor': 'Dr. Robert Smith',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Cancelled',
      'statusColor': Colors.red,
    },
    {
      'time': '13:30',
      'patient': 'Emily Carter',
      'patientId': 'P-567890',
      'doctor': 'Dr. Priya Patel',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Completed',
      'statusColor': Colors.green,
    },
    {
      'time': '14:30',
      'patient': 'Kyle Smith',
      'patientId': 'P-456789',
      'doctor': 'Dr. Robert Smith',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Examining',
      'statusColor': Color(0xFF6B46C1),
    },
    {
      'time': '15:00',
      'patient': 'Sarah Ahmed',
      'patientId': 'P-345678',
      'doctor': 'Dr. Priya Patel',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Upcoming',
      'statusColor': Colors.grey,
    },
    {
      'time': '16:00',
      'patient': 'Michael Brown',
      'patientId': 'P-234567',
      'doctor': 'Dr. Priya Patel',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Upcoming',
      'statusColor': Colors.grey,
    },
    {
      'time': '17:00',
      'patient': 'Dr. Priya Patel',
      'patientId': 'P-DOC-001',
      'doctor': 'Dr. Emily Chen',
      'nurse': 'Sarah Johnson',
      'status': 'Upcoming',
      'statusColor': Colors.grey,
      'note': 'Dr. Patel is also a patient',
    },
  ];

  /// List of time markers for the timeline display
  /// These times are displayed along the timeline to help nurses visualize
  /// the schedule and see when appointments occur throughout the day
  final List<String> _timeMarkers = [
    '12:30',
    '13:30',
    '14:30',
    '15:00',
    '16:00',
    '17:00',
    '18:30',
  ];

  /// Builds the nurse appointment listing UI with timeline view.
  ///
  /// Creates a timeline-based interface including:
  /// - Day selector for switching between different days
  /// - Timeline view with time markers on the left side
  /// - Appointment cards positioned according to their scheduled times
  /// - Status indicators with color coding for quick visual reference
  /// - Detailed appointment information (patient, doctor, nurse, status)
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete nurse appointment listing UI
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
                      'September, 2024',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF6B46C1)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Date selector
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                      // todo: Fetch appointments for selected day
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF6B46C1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF6B46C1)
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _days[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Timeline
            Expanded(
              child: Stack(
                children: [
                  // Vertical line
                  Positioned(
                    left: 40,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.grey[300]),
                  ),
                  // Appointments
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      final isCurrent = appointment['status'] == 'Examining';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time marker
                            SizedBox(
                              width: 60,
                              child: Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          isCurrent
                                              ? const Color(0xFF6B46C1)
                                              : Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (isCurrent)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 2,
                                      height: 20,
                                      color: const Color(0xFF6B46C1),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Time text
                            SizedBox(
                              width: 60,
                              child: Text(
                                appointment['time'],
                                style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Appointment card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
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
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            appointment['patient'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: (appointment['statusColor']
                                                      as Color)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    appointment['statusColor']
                                                        as Color,
                                              ),
                                            ),
                                            child: Text(
                                              appointment['status'],
                                              style: TextStyle(
                                                inherit: false,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    appointment['statusColor']
                                                        as Color,
                                                textBaseline: TextBaseline.alphabetic,
                                              ),
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
