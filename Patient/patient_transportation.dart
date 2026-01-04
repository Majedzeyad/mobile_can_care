import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';

/// Patient Transportation Request Page
///
/// This page allows patients to request transportation services to hospitals.
/// Features include:
/// - Hospital selector dropdown with available hospital options
/// - Reason field for transportation request details
/// - Submit transportation request functionality
/// - View request history with status (approved, rejected, pending)
/// - Request status tracking and timestamps
///
/// The page helps patients coordinate medical transportation needs, ensuring
/// they can get to appointments and medical facilities when needed.
class PatientTransportation extends StatefulWidget {
  const PatientTransportation({super.key});

  @override
  State<PatientTransportation> createState() => _PatientTransportationState();
}

/// State class for Patient Transportation Request Page
///
/// Manages:
/// - Current navigation index
/// - Selected hospital for transportation request
/// - Reason text controller for request details
/// - List of available hospitals
/// - Transportation request history
/// - UI state and form submission
class _PatientTransportationState extends State<PatientTransportation> {
  /// Current navigation index (0 for this page)
  int _currentIndex = 0;
  
  /// Currently selected hospital from the dropdown
  String? _selectedHospital;
  
  /// Controller for the reason text field explaining transportation need
  final TextEditingController _reasonController = TextEditingController();

  // TODO: Connect Firebase - Fetch from 'hospitals' collection
  /// List of available hospitals for transportation requests
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<String> _hospitals = [
    'Abdali Hospital',
    'Jordan University',
    'Jordan Hospital',
  ];

  // TODO: Connect Firebase - Fetch from 'transportationRequests' collection
  /// List of previous transportation requests with their status
  /// Each request contains: sendTime, state (display text), status (internal value)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _lastRequests = [
    {
      'sendTime': 'October 06, 2024 at 10:47 AM',
      'state': 'Rejected',
      'status': 'rejected',
    },
  ];

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the reason text controller to prevent memory leaks.
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Builds the patient transportation request UI with form and history.
  ///
  /// Creates an interface including:
  /// - Status bar simulation at the top
  /// - Header with page title and back button
  /// - Transportation request form (hospital selector, reason field, submit button)
  /// - Request history section showing previous requests and their status
  /// - Status indicators with appropriate colors (approved/rejected/pending)
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient transportation request UI
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
                    '9:53',
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
                      'Transportaion',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    const Text(
                      'Transportaion Requset',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Hospital selection buttons
                    _buildHospitalSelection(),
                    const SizedBox(height: 16),
                    // Reason text area
                    _buildReasonTextArea(),
                    const SizedBox(height: 16),
                    // Send button
                    _buildSendButton(),
                    const SizedBox(height: 32),
                    // Last requests heading
                    const Text(
                      'Last Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Last requests list
                    ..._lastRequests.map(
                      (request) => _buildRequestHistoryItem(request),
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

  Widget _buildHospitalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedHospital ?? 'Choose New Hospital',
                style: TextStyle(
                  color:
                      _selectedHospital != null
                          ? Colors.black
                          : Colors.grey[600],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Hospital buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _hospitals.map((hospital) {
                final isSelected = _selectedHospital == hospital;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedHospital = hospital;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF6B46C1).withOpacity(0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF6B46C1)
                                : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      hospital,
                      style: TextStyle(
                        color:
                            isSelected ? const Color(0xFF6B46C1) : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonTextArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why you Want to Change',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _reasonController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'enter reasons',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedHospital == null || _reasonController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select hospital and enter reason'),
              ),
            );
            return;
          }

          // todo: Connect Firebase - Create transportation request in 'transportationRequests' collection
          // await FirebaseFirestore.instance.collection('transportationRequests').add({
          //   'hospital': _selectedHospital,
          //   'reason': _reasonController.text,
          //   'status': 'pending',
          //   'timestamp': FieldValue.serverTimestamp(),
          //   'userId': FirebaseAuth.instance.currentUser?.uid,
          // });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request sent successfully')),
          );

          setState(() {
            _selectedHospital = null;
            _reasonController.clear();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6B46C1),
          side: const BorderSide(color: Color(0xFF6B46C1)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('send'),
      ),
    );
  }

  Widget _buildRequestHistoryItem(Map<String, dynamic> request) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Send Time:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                request['sendTime'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'State:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                request['state'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      request['status'] == 'rejected'
                          ? Colors.red
                          : request['status'] == 'accepted'
                          ? Colors.green
                          : Colors.orange,
                ),
              ),
            ],
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
