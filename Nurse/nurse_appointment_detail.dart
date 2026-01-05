import 'package:flutter/material.dart';

/// Nurse Appointment Detail/Edit Page
///
/// This page allows nurses to view and edit detailed information about a specific appointment.
/// Features include:
/// - Patient name field
/// - Doctor name field
/// - Date and time fields
/// - Reason/appointment purpose field
/// - Form editing capabilities
/// - Save functionality for appointment updates
///
/// The page helps nurses manage appointment details, update information when needed,
/// and ensure accurate scheduling and coordination between patients, doctors, and nurses.
class NurseAppointmentDetail extends StatefulWidget {
  const NurseAppointmentDetail({super.key});

  @override
  State<NurseAppointmentDetail> createState() => _NurseAppointmentDetailState();
}

/// State class for Nurse Appointment Detail Page
///
/// Manages:
/// - Current navigation index
/// - Text controllers for all appointment fields (patient, doctor, date, time, reason)
/// - Appointment data and form state
/// - UI interactions and form submission
class _NurseAppointmentDetailState extends State<NurseAppointmentDetail> {
  /// Current navigation index (1 for appointments)
  int _currentIndex = 1;
  
  /// Controller for patient name text field
  final TextEditingController _patientController = TextEditingController();
  
  /// Controller for doctor name text field
  final TextEditingController _doctorController = TextEditingController();
  
  /// Controller for appointment date text field
  final TextEditingController _dateController = TextEditingController();
  
  /// Controller for appointment time text field
  final TextEditingController _timeController = TextEditingController();
  
  /// Controller for appointment reason/purpose text field
  final TextEditingController _reasonController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'appointments' collection
  /// Initialize widget state and populate form fields with appointment data.
  ///
  /// Called when the widget is first created. Initializes all text controllers
  /// with dummy data. In production, would load appointment data from Firebase
  /// and populate the form fields accordingly.
  @override
  void initState() {
    super.initState();
    _patientController.text = 'John Doe';
    _doctorController.text = 'Dr. Emily Smith';
    _dateController.text = 'September 24, 2024';
    _timeController.text = '10:00 AM';
    _reasonController.text = 'Routine check-up';
  }

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes all text controllers to prevent memory leaks.
  @override
  void dispose() {
    _patientController.dispose();
    _doctorController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  /// Builds the nurse appointment detail/edit UI with form fields.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title, back button, and save button
  /// - Form fields for patient, doctor, date, time, and reason
  /// - Editable text fields allowing nurses to update appointment information
  /// - Save functionality to persist changes
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete nurse appointment detail/edit UI
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
                      'Appointment Detail',
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
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient field
                    _buildInputField(
                      'Patient',
                      _patientController,
                      Icons.person,
                    ),
                    const SizedBox(height: 16),
                    // Doctor field
                    _buildInputField(
                      'Doctor',
                      _doctorController,
                      Icons.medical_services,
                    ),
                    const SizedBox(height: 16),
                    // Date field
                    _buildInputField(
                      'Date',
                      _dateController,
                      Icons.calendar_today,
                      onTap: () {
                        // todo: Show date picker
                      },
                    ),
                    const SizedBox(height: 16),
                    // Time field
                    _buildInputField(
                      'Time',
                      _timeController,
                      Icons.access_time,
                      onTap: () {
                        // todo: Show time picker
                      },
                    ),
                    const SizedBox(height: 16),
                    // Reason field
                    _buildTextAreaField('Reason', _reasonController),
                    const SizedBox(height: 32),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // todo: Connect Firebase - Save appointment changes
                              // await FirebaseFirestore.instance
                              //     .collection('appointments')
                              //     .doc(appointmentId)
                              //     .update({
                              //   'patient': _patientController.text,
                              //   'doctor': _doctorController.text,
                              //   'date': _dateController.text,
                              //   'time': _timeController.text,
                              //   'reason': _reasonController.text,
                              // });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Changes saved successfully'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // todo: Connect Firebase - Cancel appointment
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Cancel Appointment'),
                                      content: const Text(
                                        'Are you sure you want to cancel this appointment?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // todo: Connect Firebase - Cancel appointment
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Appointment cancelled',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Yes',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel Appointment'),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: onTap == null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
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
