import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';
import '../services/firebase_services.dart';
import 'patient_common_widgets.dart';

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

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Appointment Management
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores patient appointments from Firebase.
  // To modify the data source:
  // - Change query filters in FirebaseServices.getPatientAppointments()
  // - Update appointment filtering logic if needed
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Currently displayed month in the calendar view
  DateTime _currentMonth = DateTime.now();

  // Currently selected date in the calendar (day of month)
  int _selectedDate = DateTime.now().day;

  // Today's date (day of month) for highlighting in the calendar
  int _todayDate = DateTime.now().day;

  // All appointments from Firebase
  List<Map<String, dynamic>> _allAppointments = [];

  // Filtered appointments for selected date
  List<Map<String, dynamic>> _appointments = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads appointments from Firebase.
  //
  // To modify:
  // - Change the query filters in FirebaseServices.getPatientAppointments()
  // - Update the data mapping if appointment structure changes
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadAppointments() async {
    try {
      setState(() => _isLoading = true);

      // Load appointments
      _allAppointments = await _firebaseServices.getPatientAppointments();

      // Filter appointments for selected date
      _filterAppointmentsForDate(_selectedDate);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[PatientAppointmentManagement] Error loading appointments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المواعيد: $e')));
      }
    }
  }

  void _filterAppointmentsForDate(int day) {
    setState(() {
      _appointments = _allAppointments.where((apt) {
        final aptDate = (apt['appointmentDate'] as dynamic)?.toDate();
        if (aptDate == null) return false;
        return aptDate.year == _currentMonth.year &&
            aptDate.month == _currentMonth.month &&
            aptDate.day == day;
      }).toList();
    });
  }

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
      drawer: buildPatientDrawer(context, theme),
      bottomNavigationBar: buildPatientBottomNavBar(
        context,
        theme,
        currentIndex: 0, // الرئيسية
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(theme),
              const SizedBox(height: 32),

              // Search bar
              _buildSearchBar(theme),
              const SizedBox(height: 24),

              // Calendar card
              _buildCalendarCard(theme),
              const SizedBox(height: 24),

              // Appointments list
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildAppointmentsList(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 28,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            'مواعيدي',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          onPressed: () {
            // TODO: Backend Integration - Add new appointment
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'ابحث عن موعد...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 28,
            color: theme.colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        onChanged: (value) {
          // TODO: Backend Integration - Filter appointments by search query
        },
      ),
    );
  }

  Widget _buildCalendarCard(ThemeData theme) {
    final monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final monthName = monthNames[_currentMonth.month - 1];
    final year = _currentMonth.year;

    // Get first day of month and number of days
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.secondary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
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
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
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
          const SizedBox(height: 20),
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CalendarDayHeader('الإثنين', theme),
              _CalendarDayHeader('الثلاثاء', theme),
              _CalendarDayHeader('الأربعاء', theme),
              _CalendarDayHeader('الخميس', theme),
              _CalendarDayHeader('الجمعة', theme),
              _CalendarDayHeader('السبت', theme),
              _CalendarDayHeader('الأحد', theme),
            ],
          ),
          const SizedBox(height: 12),
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
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        date.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
                      _filterAppointmentsForDate(dateIndex);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : isToday
                            ? theme.colorScheme.secondary
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected || isToday
                              ? Colors.transparent
                              : theme.colorScheme.primary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dateIndex.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected || isToday
                                ? Colors.white
                                : Colors.black87,
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

  Widget _buildAppointmentsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المواعيد القادمة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_appointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مواعيد في هذا التاريخ',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._appointments.map(
            (appointment) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['doctorName'] ??
                              appointment['doctor'] ??
                              'طبيب',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatAppointmentDateTime(appointment),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        if (appointment['room'] != null ||
                            appointment['location'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.room,
                                  size: 20,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  appointment['room'] ??
                                      appointment['location'] ??
                                      'غير متاح',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
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
    );
  }

  String _formatAppointmentDateTime(Map<String, dynamic> appointment) {
    final aptDate = (appointment['appointmentDate'] as dynamic)?.toDate();
    final now = DateTime.now();

    if (aptDate == null) {
      return appointment['appointmentTime'] ?? 'غير متاح';
    }

    final isToday =
        aptDate.year == now.year &&
        aptDate.month == now.month &&
        aptDate.day == now.day;
    final isTomorrow =
        aptDate.year == now.year &&
        aptDate.month == now.month &&
        aptDate.day == now.day + 1;

    String dateText = '${aptDate.day}/${aptDate.month}/${aptDate.year}';
    if (isToday) dateText = 'اليوم';
    if (isTomorrow) dateText = 'غداً';

    final time =
        appointment['appointmentTime'] ??
        '${aptDate.hour.toString().padLeft(2, '0')}:${aptDate.minute.toString().padLeft(2, '0')}';

    return '$dateText - $time';
  }
}

class _CalendarDayHeader extends StatelessWidget {
  final String day;
  final ThemeData theme;
  const _CalendarDayHeader(this.day, this.theme);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
