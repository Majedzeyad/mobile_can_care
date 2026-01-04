import 'package:flutter/material.dart';
import 'nurse_appointment_listing.dart';

/// Nurse Appointment List Page
///
/// This page displays a filtered list of appointments for nurses with filter options.
/// Features include:
/// - Filter buttons to view appointments by category (Upcoming, Past, Today)
/// - Appointment cards showing patient, doctor, specialty, date, time, and status
/// - Status indicators with color coding (Confirmed, Pending, Completed)
/// - Support for multi-role scenarios (doctors/nurses who are also patients)
/// - Visual color bars for quick appointment type identification
///
/// The page helps nurses quickly view and manage appointments based on time periods,
/// making it easier to organize their schedule and prioritize patient care.
class NurseAppointmentList extends StatefulWidget {
  const NurseAppointmentList({super.key});

  @override
  State<NurseAppointmentList> createState() => _NurseAppointmentListState();
}

/// State class for Nurse Appointment List Page
///
/// Manages:
/// - Current navigation index
/// - Selected filter index (Upcoming/Past/Today)
/// - Lists of appointments organized by time period
/// - UI state and interactions
class _NurseAppointmentListState extends State<NurseAppointmentList> {
  /// Current navigation index (1 for appointments)
  int _currentIndex = 1;
  
  /// Currently selected filter index
  /// 0 = Upcoming, 1 = Past, 2 = Today
  int _selectedFilter = 0; // 0: Upcoming, 1: Past, 2: Today

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  // Appointments showing nurse-doctor-patient relationships
  /// List of upcoming appointments
  /// Each appointment contains: date, patient, patientId, doctor, specialty,
  /// nurse, status, statusColor, barColor, optional note
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'date': 'Feb 20, 2024, 10:00 AM',
      'patient': 'Jane Cooper',
      'patientId': 'P-123456',
      'doctor': 'Dr. Robert Smith',
      'specialty': 'Cardiology',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Confirmed',
      'statusColor': Colors.green,
      'barColor': const Color(0xFF6B46C1),
    },
    {
      'date': 'Feb 22, 2024, 2:30 PM',
      'patient': 'Michael Brown',
      'patientId': 'P-234567',
      'doctor': 'Dr. Priya Patel',
      'specialty': 'Oncology',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Pending',
      'statusColor': Colors.blue,
      'barColor': Colors.blue,
    },
    {
      'date': 'Feb 25, 2024, 11:00 AM',
      'patient': 'Dr. Priya Patel',
      'patientId': 'P-DOC-001',
      'doctor': 'Dr. Emily Chen',
      'specialty': 'Internal Medicine',
      'nurse': 'Sarah Johnson',
      'status': 'Confirmed',
      'statusColor': Colors.green,
      'barColor': Colors.green,
      'note': 'Dr. Patel is also a patient',
    },
  ];

  /// List of past/completed appointments
  /// Each appointment contains: date, patient, patientId, doctor, specialty,
  /// nurse, status, statusColor, barColor
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _pastAppointments = [
    {
      'date': 'Feb 10, 2024, 9:00 AM',
      'patient': 'Kyle Smith',
      'patientId': 'P-456789',
      'doctor': 'Dr. Robert Smith',
      'specialty': 'General Medicine',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Completed',
      'statusColor': Colors.green,
      'barColor': Colors.green,
    },
    {
      'date': 'Feb 8, 2024, 3:00 PM',
      'patient': 'Sarah Ahmed',
      'patientId': 'P-345678',
      'doctor': 'Dr. Priya Patel',
      'specialty': 'Oncology',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Completed',
      'statusColor': Colors.green,
      'barColor': Colors.green,
    },
  ];

  /// List of appointments scheduled for today
  /// Each appointment contains: date, patient, patientId, doctor, specialty,
  /// nurse, status, statusColor, barColor, optional note
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _todayAppointments = [
    {
      'date': 'Today, 10:00 AM',
      'patient': 'Jane Cooper',
      'patientId': 'P-123456',
      'doctor': 'Dr. Robert Smith',
      'specialty': 'Cardiology',
      'nurse': 'Olivia Thompson (You)',
      'status': 'Confirmed',
      'statusColor': Colors.green,
      'barColor': const Color(0xFF6B46C1),
    },
    {
      'date': 'Today, 2:00 PM',
      'patient': 'Dr. Priya Patel',
      'patientId': 'P-DOC-001',
      'doctor': 'Dr. Emily Chen',
      'specialty': 'Internal Medicine',
      'nurse': 'Sarah Johnson',
      'status': 'Confirmed',
      'statusColor': Colors.green,
      'barColor': Colors.blue,
      'note': 'Dr. Patel is also a patient',
    },
  ];

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
                    '9:42',
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
            ),
            // Filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildFilterButton(0, 'Upcoming')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFilterButton(1, 'Past')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFilterButton(2, 'Today')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Main content
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _getAppointmentsList().length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(_getAppointmentsList()[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterButton(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF6B46C1).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF6B46C1) : Colors.grey[300]!,
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

  List<Map<String, dynamic>> _getAppointmentsList() {
    switch (_selectedFilter) {
      case 0:
        return _upcomingAppointments;
      case 1:
        return _pastAppointments;
      case 2:
        return _todayAppointments;
      default:
        return _upcomingAppointments;
    }
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
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
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: appointment['barColor'] as Color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['date'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment['doctor'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment['specialty'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (appointment['statusColor'] as Color).withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: appointment['statusColor'] as Color,
                    ),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: appointment['statusColor'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // todo: Navigate to appointment detail
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NurseAppointmentListing(),
                ),
              );
            },
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
        // todo: Navigate to different pages
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
