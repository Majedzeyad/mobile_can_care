import 'package:flutter/material.dart';
import 'patient_transportation.dart';
import 'patient_appointment_management.dart';
import 'patient_profile.dart';
import 'patient_publication.dart';

/// Patient Dashboard Page
///
/// This is the main dashboard screen for patients in the CancerCare application.
/// It provides a comprehensive overview of the patient's health information and activities:
/// - Calendar view with highlighted dates for appointments
/// - Reminders for upcoming appointments and tasks
/// - Medication tracking (current medications and dosage schedules)
/// - Transportation request status
/// - Lab results notifications
/// - Emergency SOS button for urgent situations
/// - Quick access to various patient features via navigation cards
///
/// The dashboard is designed to help patients stay organized with their health
/// management and easily access important medical information.
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

/// State class for Patient Dashboard Page
///
/// Manages:
/// - Calendar selection state (highlighted dates, selected date)
/// - Dashboard data (user name, reminders, transportation requests, lab results, medications)
/// - Bottom navigation tab index
/// - UI interactions and navigation
class _PatientDashboardState extends State<PatientDashboard> {
  /// Current selected tab index in bottom navigation bar
  int _currentIndex = 0;

  /// List of dates that should be highlighted in the calendar (days with appointments)
  final List<int> _highlightedDates = [15, 23];

  /// Currently selected date in the calendar view
  int _selectedDate = 15;

  // TODO: Connect Firebase - Fetch user name, appointments, transportation requests, lab results
  /// Display name of the currently logged-in patient
  /// Currently using dummy data, should be fetched from Firebase in production
  final String _userName = 'Emily Johnson'; // Dummy data

  /// List of reminders for appointments and tasks
  /// Each reminder contains: title, time
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _reminders = [
    {'title': 'Don\'t Forget Appointment at 10:00 am', 'time': '10:00 am'},
  ];

  /// List of transportation requests and their status
  /// Each request contains: message, time
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _transportationRequests = [
    {'message': 'Your Request Has Been Sent', 'time': '2 hours ago'},
  ];

  /// List of lab results notifications
  /// Each result contains: message, time
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _labResults = [
    {'message': 'Your results is out', 'time': '2 hours ago'},
  ];

  /// List of current medications with dosage schedules and tracking
  /// Each medication contains: name, dosage (time/instructions), taken (boolean tracking)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _medications = [
    {'name': 'taken medication', 'dosage': '10 am dosage', 'taken': true},
    {'name': 'taken medication', 'dosage': '4 pm dosage', 'taken': false},
  ];

  /// Builds the patient dashboard UI with calendar, reminders, medications, and quick actions.
  ///
  /// Creates a comprehensive dashboard interface including:
  /// - Status bar simulation at the top
  /// - Header with patient name and greeting
  /// - Calendar widget with date selection and highlighting
  /// - Reminders section showing upcoming appointments
  /// - Medication tracking cards with dosage schedules
  /// - Transportation request status
  /// - Lab results notifications
  /// - Emergency SOS button for urgent situations
  /// - Navigation cards for accessing different patient features
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient dashboard UI
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
                      const Text(
                        'Home',
                        style: TextStyle(
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
                        onPressed: () {
                          // Navigate to Publication/Message page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PatientPublication(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF6B46C1)),
                        onPressed: () {
                          // Navigate to Profile page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PatientProfile(),
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
                    // Date
                    const Text(
                      'Saturday, August 14',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // Welcome message
                    Text(
                      'Welcome Back, $_userName!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Calendar
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    // Remember section
                    _buildRememberSection(),
                    const SizedBox(height: 16),
                    // Transportation request card
                    _buildTransportationCard(),
                    const SizedBox(height: 16),
                    // Lab results card
                    _buildLabResultsCard(),
                    const SizedBox(height: 24),
                    // Taken medication section
                    _buildMedicationSection(),
                    const SizedBox(height: 24),
                    // SOS button
                    _buildSOSButton(),
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

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mon Tue Wed Thu Fri Sat Sun',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(14, (index) {
            final date = 12 + index;
            final isHighlighted = _highlightedDates.contains(date);
            final isSelected = date == _selectedDate;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                // Navigate to appointments when a date with appointment is tapped
                if (isHighlighted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const PatientAppointmentManagement(),
                    ),
                  );
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF6B46C1)
                          : isHighlighted
                          ? const Color(0xFF6B46C1).withOpacity(0.2)
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
                              : isHighlighted
                              ? const Color(0xFF6B46C1)
                              : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRememberSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: Color(0xFF6B46C1)),
              const SizedBox(width: 8),
              const Text(
                'Remember',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B46C1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_reminders[0]['title'], style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // Navigate to Appointment Management page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientAppointmentManagement(),
                ),
              );
            },
            child: const Row(
              children: [
                Text(
                  'Show More',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B46C1)),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFF6B46C1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportationCard() {
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
          const Text(
            'Pending Transportation Request',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _transportationRequests[0]['message'],
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            _transportationRequests[0]['time'],
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // Navigate to Transportation page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientTransportation(),
                ),
              );
            },
            child: const Row(
              children: [
                Text(
                  'Show More',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B46C1)),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFF6B46C1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultsCard() {
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
          const Text(
            'Lab results',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _labResults[0]['message'],
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            _labResults[0]['time'],
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // todo: Show lab results details
            },
            child: const Row(
              children: [
                Text(
                  'Show More',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B46C1)),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF6B46C1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Taken medication',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._medications.map(
          (med) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Checkbox(
                  value: med['taken'],
                  onChanged: (value) {
                    setState(() {
                      med['taken'] = value;
                    });
                    // todo: Connect Firebase - Update medication taken status
                  },
                  activeColor: const Color(0xFF6B46C1),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med['name'], style: const TextStyle(fontSize: 14)),
                      Text(
                        med['dosage'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildSOSButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'SOS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Emergency only',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
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
        // todo: Navigate to different pages
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
