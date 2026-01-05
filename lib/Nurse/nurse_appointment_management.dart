import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_medication_management.dart';
import 'nurse_publication.dart';
import 'nurse_patient_management.dart';
import 'nurse_profile.dart';
import '../services/firebase_services.dart';

/// Nurse Appointment Management Page
///
/// This page provides comprehensive appointment management functionality for nurses.
/// Features include:
/// - Calendar view for browsing appointments by month and date
/// - Appointment list filtered by selected date
/// - Search functionality to find specific appointments
/// - Detailed appointment information showing patient, doctor, nurse, room, and reason
/// - Support for multi-role scenarios (doctors/nurses who are also patients)
/// - Bottom navigation to access other nurse-related pages
///
/// The page displays appointments where the current nurse is assigned, helping
/// nurses manage their daily schedule and patient care responsibilities.
class NurseAppointmentManagement extends StatefulWidget {
  const NurseAppointmentManagement({super.key});

  @override
  State<NurseAppointmentManagement> createState() =>
      _NurseAppointmentManagementState();
}

/// State class for Nurse Appointment Management Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Calendar state (current month, selected date)
/// - Search controller for filtering appointments
/// - List of appointments with multi-role support
/// - UI interactions and navigation
class _NurseAppointmentManagementState
    extends State<NurseAppointmentManagement> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  DateTime _currentMonth = DateTime(2025, 2, 1);
  int _selectedDate = 14;

  // Firebase Integration
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() => _isLoading = true);

      final appointments = await _firebaseServices.getNurseAppointments();

      if (mounted) {
        setState(() {
          _appointments = appointments.map((apt) => {
            'time': apt['time'] ?? '',
            'patient': apt['patientName'] ?? 'مريض',
            'patientId': apt['patientId'] ?? '',
            'doctor': apt['doctorName'] ?? '',
            'doctorId': apt['doctorId'] ?? '',
            'nurse': 'You',
            'nurseId': apt['nurseId'] ?? '',
            'room': apt['room'] ?? '',
            'reason': apt['reason'] ?? '',
            'date': apt['date'] as DateTime?,
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Nurse Appointment Management] Error loading appointments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    return _appointments.where((apt) {
      final date = apt['date'] as DateTime?;
      if (date == null) return false;
      return date.day == _selectedDate &&
          date.month == _currentMonth.month &&
          date.year == _currentMonth.year;
    }).toList();
  }

  Widget _buildAppointmentsList(ThemeData theme) {
    final filtered = _filteredAppointments;
    
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'لا توجد مواعيد في هذا اليوم',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((apt) => Container(
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
                Icon(Icons.access_time, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  apt['time'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('المريض: ${apt['patient']}'),
            Text('الطبيب: ${apt['doctor']}'),
            Text('الغرفة: ${apt['room']}'),
            Text('السبب: ${apt['reason']}'),
          ],
        ),
      )).toList(),
    );
  }

  // Temporary placeholder - old data structure
  final List<Map<String, dynamic>> _appointmentsOld = [
    {
      'time': '10:00 AM',
      'patient': 'Jane Cooper',
      'patientId': 'P-123456',
      'doctor': 'Dr. Robert Smith',
      'doctorId': 'DOC-001',
      'nurse': 'Olivia Thompson (You)',
      'nurseId': 'NC-48276',
      'room': 'Room 201',
      'reason': 'Diabetes follow-up',
    },
    {
      'time': '10:30 AM',
      'patient': 'John Doe',
      'patientId': 'P-111222',
      'doctor': 'Dr. Robert Smith',
      'doctorId': 'DOC-001',
      'nurse': 'Olivia Thompson (You)',
      'nurseId': 'NC-48276',
      'room': 'Room 202',
      'reason': 'General checkup',
    },
    {
      'time': '01:00 PM',
      'patient': 'Emily Carter',
      'patientId': 'P-567890',
      'doctor': 'Dr. Priya Patel',
      'doctorId': 'DOC-002',
      'nurse': 'Olivia Thompson (You)',
      'nurseId': 'NC-48276',
      'room': 'Room 105',
      'reason': 'Chronic migraine consultation',
    },
    {
      'time': '02:00 PM',
      'patient': 'Dr. Priya Patel',
      'patientId': 'P-DOC-001',
      'doctor': 'Dr. Emily Chen',
      'doctorId': 'DOC-003',
      'nurse': 'Sarah Johnson',
      'nurseId': 'NC-48277',
      'room': 'Conference Room',
      'reason': 'Diabetes follow-up (Dr. Patel is also a patient)',
      'isMultiRole': true,
    },
    {
      'time': '03:45 PM',
      'patient': 'Michael Brown',
      'patientId': 'P-234567',
      'doctor': 'Dr. Priya Patel',
      'doctorId': 'DOC-002',
      'nurse': 'Olivia Thompson (You)',
      'nurseId': 'NC-48276',
      'room': 'Room 310',
      'reason': 'Post-surgery recovery check',
    },
    {
      'time': '04:30 PM',
      'patient': 'Olivia Thompson',
      'patientId': 'P-NURSE-001',
      'doctor': 'Dr. Robert Smith',
      'doctorId': 'DOC-001',
      'nurse': 'Sarah Johnson',
      'nurseId': 'NC-48277',
      'room': 'Room 205',
      'reason': 'Routine annual checkup (You are also a patient)',
      'isMultiRole': true,
    },
  ];

  /// Builds the nurse appointment management UI with calendar and appointment list.
  ///
  /// Creates a comprehensive interface including:
  /// - Status bar simulation at the top
  /// - Header with page title and search functionality
  /// - Calendar widget for selecting dates and viewing appointment distribution
  /// - Filtered appointment list showing appointments for the selected date
  /// - Appointment cards with detailed information (patient, doctor, room, reason)
  /// - Bottom navigation bar for accessing other nurse pages
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete nurse appointment management UI
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
              child: Column(
                children: [
                  Row(
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
                          'المواعيد',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          // TODO: Backend Integration - Add appointment
                        },
                      ),
                    ],
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
                        hintText: 'ابحث عن المواعيد...',
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
                        // TODO: Backend Integration - Filter appointments by search query
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
                    // Today's Appointments
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مواعيد اليوم:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._appointments.map(
                            (appointment) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                '${appointment['time']} ${appointment['patient']}, ${appointment['doctor']}, ${appointment['room']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // todo: Navigate to add appointment page
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 22),
                                SizedBox(width: 8),
                                Text('إضافة'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // todo: Navigate to edit appointment page
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorScheme.primary),
                              foregroundColor: theme.colorScheme.primary,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // todo: Connect Firebase - Cancel appointment
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close, size: 20),
                                SizedBox(width: 8),
                                Text('Cancel'),
                              ],
                            ),
                          ),
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
                icon: const Icon(Icons.chevron_left, color: Colors.white),
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
                icon: const Icon(Icons.chevron_right, color: Colors.white),
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
              _CalendarDayHeader('SUN'),
              _CalendarDayHeader('MON'),
              _CalendarDayHeader('TUE'),
              _CalendarDayHeader('WED'),
              _CalendarDayHeader('THU'),
              _CalendarDayHeader('FRI'),
              _CalendarDayHeader('SAT'),
            ],
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(6, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dateIndex = weekIndex * 7 + dayIndex - firstWeekday + 1;
                if (dateIndex < 1 || dateIndex > daysInMonth) {
                  // Previous/next month dates
                  final prevMonthDays =
                      DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                        0,
                      ).day;
                  final date =
                      dateIndex < 1
                          ? prevMonthDays + dateIndex
                          : dateIndex - daysInMonth;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        date.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          inherit: false,
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ),
                  );
                }
                final isSelected = dateIndex == _selectedDate;
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
                        color:
                            isSelected
                                ? const Color(0xFF6B46C1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          dateIndex.toString(),
                          style: TextStyle(
                            inherit: false,
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.white,
                            textBaseline: TextBaseline.alphabetic,
                            fontWeight:
                                isSelected
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
            // Already on Appointment page
            return;
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

class _CalendarDayHeader extends StatelessWidget {
  final String day;
  const _CalendarDayHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          inherit: false,
          fontSize: 12,
          color: Colors.white,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }
}
