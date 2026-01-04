import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';

/// Patient Appointment Management Page
///
/// This page provides appointment management functionality for patients.
/// Features include:
/// - Calendar view for browsing appointments by month and date
/// - Today indicator to highlight the current date
/// - Appointment list filtered by selected date
/// - Appointment details showing doctor, time, and room
/// - Search functionality to find specific appointments
/// - Easy navigation between different months
///
/// The page helps patients manage their appointment schedule, view upcoming
/// appointments, and track their medical visit history.
class PatientAppointmentManagement extends StatefulWidget {
  const PatientAppointmentManagement({super.key});

  @override
  State<PatientAppointmentManagement> createState() =>
      _PatientAppointmentManagementState();
}

/// State class for Patient Appointment Management Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Calendar state (current month, selected date, today's date)
/// - Search controller for filtering appointments
/// - List of appointments
/// - UI interactions and navigation
class _PatientAppointmentManagementState
    extends State<PatientAppointmentManagement> {
  /// Current selected tab index in bottom navigation bar (Appointments tab = 0)
  int _currentIndex = 0;

  /// Controller for the search text field to filter appointments
  final TextEditingController _searchController = TextEditingController();

  /// Currently displayed month in the calendar view
  DateTime _currentMonth = DateTime(2025, 3, 1);

  /// Currently selected date in the calendar (day of month)
  int _selectedDate = 20;

  /// Today's date (day of month) for highlighting in the calendar
  int _todayDate = 7;

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  /// List of patient appointments
  /// Each appointment contains: date, time, doctor, room
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _appointments = [
    {
      'date': 'Today',
      'time': '10:30 AM',
      'doctor': 'Dr. Smith',
      'room': 'Room 202',
    },
    {
      'date': '20 Mar',
      'time': '1:00 PM',
      'doctor': 'Dr. Patel',
      'room': 'Room 105',
    },
  ];

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the patient appointment management UI with calendar and appointment list.
  ///
  /// Creates a comprehensive interface including:
  /// - Status bar simulation at the top
  /// - Header with page title, back button, and search functionality
  /// - Calendar widget for selecting dates and viewing appointment distribution
  /// - Today indicator highlighting the current date
  /// - Filtered appointment list showing appointments for the selected date
  /// - Appointment cards with doctor, time, and room information
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient appointment management UI
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
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Appointments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B46C1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF6B46C1)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        // todo: Filter appointments by search query
                      },
                    ),
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
                    // Calendar card
                    _buildCalendarCard(),
                    const SizedBox(height: 24),
                    // Appointments card
                    _buildAppointmentsCard(),
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

  Widget _buildCalendarCard() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthName = monthNames[_currentMonth.month - 1];
    final year = _currentMonth.year;

    // Get first day of month and number of days
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B46C1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                      1,
                    );
                  });
                },
              ),
              Text(
                '$monthName $year',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                      1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day headers
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CalendarDayHeader('Mon'),
              _CalendarDayHeader('Tue'),
              _CalendarDayHeader('Wed'),
              _CalendarDayHeader('Thu'),
              _CalendarDayHeader('Fri'),
              _CalendarDayHeader('Sat'),
              _CalendarDayHeader('Sun'),
            ],
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(6, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dateIndex = weekIndex * 7 + dayIndex - firstWeekday + 2;
                if (dateIndex < 1 || dateIndex > daysInMonth) {
                  // Previous/next month dates
                  final prevMonthDays = DateTime(
                    _currentMonth.year,
                    _currentMonth.month - 1,
                    0,
                  ).day;
                  final date = dateIndex < 1
                      ? prevMonthDays + dateIndex
                      : dateIndex - daysInMonth;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        date.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                }
                final isSelected = dateIndex == _selectedDate;
                final isToday =
                    dateIndex == _todayDate &&
                    _currentMonth.month == DateTime.now().month &&
                    _currentMonth.year == DateTime.now().year;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = dateIndex;
                      });
                      // todo: Fetch appointments for selected date
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6B46C1)
                            : isToday
                            ? Colors.red
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          dateIndex.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? Colors.white
                                : Colors.white,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppointmentsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B46C1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Appointments:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._appointments.map(
            (appointment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${appointment['date']} ${appointment['time']} (${appointment['doctor']}) - ${appointment['room']}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            destination = const PatientDashboard();
            break;
          case 1:
            destination = const PatientMedicationManagement();
            break;
          case 2:
            destination =
                const PatientPublication(); // Message/Publication page
            break;
          case 3:
            destination = const PatientMedicalRecord(); // Record page
            break;
          case 4:
            destination = const PatientProfile();
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
      selectedItemColor: const Color(0xFF6B46C1),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Record'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class _CalendarDayHeader extends StatelessWidget {
  final String day;
  const _CalendarDayHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}
