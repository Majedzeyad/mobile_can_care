import 'package:flutter/material.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_publication.dart';
import 'nurse_patient_management.dart';
import 'nurse_profile.dart';

/// Nurse Dashboard Page
///
/// This is the main dashboard screen for nurses in the CancerCare application.
/// It provides a comprehensive overview of a nurse's daily activities including:
/// - Calendar view with highlighted dates for important appointments
/// - Today's schedule and events with patient and doctor information
/// - Quick overview of tasks (patient rounds, medication administration, vitals monitoring)
/// - Reminders for upcoming patient care activities
/// - Quick action buttons for common nursing tasks
/// - Bottom navigation to access other nurse-related pages
///
/// The dashboard is designed to help nurses efficiently manage their daily workload
/// and stay organized with patient care responsibilities.
class NurseDashboard extends StatefulWidget {
  const NurseDashboard({super.key});

  @override
  State<NurseDashboard> createState() => _NurseDashboardState();
}

/// State class for Nurse Dashboard Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Calendar selection state (highlighted dates, selected date)
/// - Dashboard data (nurse name, quick overview, today's events, reminders, quick actions)
/// - UI interactions and navigation
class _NurseDashboardState extends State<NurseDashboard> {
  /// Current selected tab index in bottom navigation bar
  int _currentIndex = 0;

  /// List of dates that should be highlighted in the calendar (days with appointments/events)
  final List<int> _highlightedDates = [15, 23];

  /// Currently selected date in the calendar view
  int _selectedDate = 15;

  // TODO: Connect Firebase - Fetch from 'users' collection
  // Nurse: Olivia Thompson (NC-48276) - Also registered as patient for routine checkups
  /// Display name of the currently logged-in nurse
  /// Currently using dummy data, should be fetched from Firebase in production
  final String _nurseName = 'Olivia Thompson';

  // TODO: Connect Firebase - Fetch from 'appointments' and 'tasks' collections
  /// Quick overview list showing summary of nurse's tasks and responsibilities
  /// Each item contains a 'task' field describing the task (patient rounds, medications, vitals)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _quickOverview = [
    {'task': 'Patient Rounds: 5 scheduled visits'},
    {'task': 'Medications: 3 doses to administer'},
    {'task': 'Vitals Monitoring: 6 patients due for vital checks'},
  ];

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  // Appointments showing nurse-doctor-patient relationships
  /// List of today's scheduled events/appointments for the nurse
  /// Each event contains: time, title, location, doctor name, and optional notes
  /// Demonstrates multi-role scenarios (e.g., doctor who is also a patient)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _todayEvents = [
    {
      'time': '10:00 AM',
      'title': 'General Checkup - John Doe',
      'location': 'Room 201',
      'doctor': 'Dr. Robert Smith',
    },
    {
      'time': '2:00 PM',
      'title': 'Diabetes Follow-up - Dr. Priya Patel (Patient)',
      'location': 'Conference Room',
      'doctor': 'Dr. Emily Chen',
      'note': 'Dr. Patel is also a patient',
    },
  ];

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  /// Reminder for upcoming patient care activity
  /// Contains patient name, time, assigned doctor, room number, and nurse information
  /// Currently using dummy data, should be fetched from Firebase in production
  final Map<String, dynamic> _reminder = {
    'patient': 'Jane Cooper',
    'time': '10:30 AM',
    'doctor': 'Dr. Robert Smith',
    'room': 'Room 202',
    'nurse': 'Olivia Thompson (You)',
  };

  // TODO: Connect Firebase - Fetch from various collections
  /// List of quick action items for common nursing tasks
  /// Each action contains: title, icon, and a detailed hint describing the task
  /// Includes reminders, transportation requests, lab results review, and medication dispensing
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Reminders',
      'icon': Icons.notifications,
      'hint':
          'Follow up with Jane Cooper (P-123456) for medication adherence. Assigned to Dr. Robert Smith.',
    },
    {
      'title': 'Transportation Request',
      'icon': Icons.local_taxi,
      'hint':
          'Patient transfer: Michael Brown to St. Mary\'s Hospital. Coordinated with Dr. Priya Patel.',
    },
    {
      'title': 'Lab Results',
      'icon': Icons.science,
      'hint':
          'Review new CBC results for Kyle Smith (P-123456). Ordered by Dr. Robert Smith.',
    },
    {
      'title': 'Medication',
      'icon': Icons.medication,
      'hint':
          'Dispense evening medications to Ward B. 3 patients: Jane Cooper, Michael Brown, Sarah Ahmed.',
    },
  ];

  /// Builds the nurse dashboard UI with calendar, schedule, and quick actions.
  ///
  /// Creates a comprehensive dashboard interface including:
  /// - Status bar simulation at the top
  /// - Header with nurse name and greeting
  /// - Calendar widget with date selection and highlighting
  /// - Today's events list showing appointments with patient and doctor details
  /// - Quick overview cards showing task summaries
  /// - Upcoming reminder card with patient care details
  /// - Quick action buttons for common nursing tasks
  /// - Bottom navigation bar for accessing other nurse pages
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete nurse dashboard UI
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Hi, $_nurseName!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B46C1),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.grid_view,
                          color: Color(0xFF6B46C1),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF6B46C1)),
                        onPressed: () {
                          // Navigate to Profile
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NurseProfile(),
                            ),
                          );
                        },
                      ),
                    ],
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
                    // Today's Overview
                    const Text(
                      'Today\'s Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Calendar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'February 2024',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mon Tue Wed Thu Fri Sat Sun',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(29, (index) {
                            final date = index + 1;
                            final isSelected = date == _selectedDate;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = date;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF6B46C1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    date.toString(),
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Today's Events
                    const Text(
                      'Today\'s Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._todayEvents.map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                event['time'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['title'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      event['location'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Calendar & Reminder
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mon Tue Wed Thu Fri Sat Sun',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(14, (index) {
                                  final date = 12 + index;
                                  final isHighlighted = _highlightedDates
                                      .contains(date);
                                  final isSelected = date == _selectedDate;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = date;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(0xFF6B46C1)
                                                : isHighlighted
                                                ? Colors.red
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          date.toString(),
                                          style: TextStyle(
                                            color:
                                                isSelected || isHighlighted
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight:
                                                isSelected || isHighlighted
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Remember box
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.notifications,
                                      color: Color(0xFF6B46C1),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remember',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B46C1),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_reminder['patient']} - ${_reminder['time']} (${_reminder['doctor']}) - ${_reminder['room']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to Appointment Management
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const NurseAppointmentManagement(),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Show More',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B46C1),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 16,
                                        color: Color(0xFF6B46C1),
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
                    const SizedBox(height: 24),
                    // Quick Actions
                    ..._quickActions.map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Navigate based on action type
                              final hint = action['hint'] as String;
                              if (hint.contains('Patient') ||
                                  hint.contains('patient')) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const NursePatientManagement(),
                                  ),
                                );
                              } else if (hint.contains('Medication') ||
                                  hint.contains('medication')) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const NurseMedicationManagement(),
                                  ),
                                );
                              } else if (hint.contains('Appointment') ||
                                  hint.contains('appointment')) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const NurseAppointmentManagement(),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  action['icon'],
                                  color: const Color(0xFF6B46C1),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    action['hint'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
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
            // Already on Home (NurseDashboard)
            return;
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
            destination = const NurseProfile(); // Account/Profile
            break;
        }

        if (destination != null) {
          Navigator.push(
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
          icon: Icon(Icons.calendar_today),
          label: 'Appointment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}
