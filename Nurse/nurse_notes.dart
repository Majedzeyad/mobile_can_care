import 'package:flutter/material.dart';

/// Nurse Notes Page
///
/// This page allows nurses to document clinical observations and notes for patients.
/// Features include:
/// - Symptoms documentation field
/// - Medications notes field
/// - Treatments notes field
/// - Observations field for general clinical notes
/// - Save functionality to persist notes
/// - Search functionality (placeholder)
///
/// The page helps nurses maintain detailed clinical documentation, record patient
/// observations, and communicate important information to the healthcare team.
class NurseNotes extends StatefulWidget {
  const NurseNotes({super.key});

  @override
  State<NurseNotes> createState() => _NurseNotesState();
}

/// State class for Nurse Notes Page
///
/// Manages:
/// - Current navigation index
/// - Text controllers for all note fields (symptoms, medications, treatments, observations)
/// - Search controller
/// - Form state and submission
/// - UI state and interactions
class _NurseNotesState extends State<NurseNotes> {
  /// Current navigation index (3 for notes)
  int _currentIndex = 3;
  
  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  
  /// Controller for symptoms documentation field
  final TextEditingController _symptomsController = TextEditingController();
  
  /// Controller for medications notes field
  final TextEditingController _medicationsController = TextEditingController();
  
  /// Controller for treatments notes field
  final TextEditingController _treatmentsController = TextEditingController();
  
  /// Controller for observations/clinical notes field
  final TextEditingController _observationsController = TextEditingController();

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes all text controllers to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    _symptomsController.dispose();
    _medicationsController.dispose();
    _treatmentsController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

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
                      'Nurse\'s Notes',
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
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search Patient',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          // todo: Filter patients by search query
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Symptoms section
                    _buildInputSection(
                      'Symptoms',
                      Icons.medical_services,
                      'E.g. Fever, Cough',
                      'Enter symptoms...',
                      _symptomsController,
                    ),
                    const SizedBox(height: 16),
                    // Medications section
                    _buildInputSection(
                      'Medications',
                      Icons.medication,
                      'E.g. Paracetamol 500mg',
                      'Enter medications...',
                      _medicationsController,
                    ),
                    const SizedBox(height: 16),
                    // Treatments section
                    _buildInputSection(
                      'Treatments',
                      Icons.healing,
                      'E.g. Dressing Change',
                      'Enter treatments...',
                      _treatmentsController,
                    ),
                    const SizedBox(height: 16),
                    // Observations section
                    _buildInputSection(
                      'Observations',
                      Icons.remove_red_eye,
                      'E.g. Patient stable after treatment',
                      'Enter observations...',
                      _observationsController,
                    ),
                    const SizedBox(height: 24),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // todo: Connect Firebase - Save notes to 'nurseNotes' collection
                          // await FirebaseFirestore.instance.collection('nurseNotes').add({
                          //   'patientId': _selectedPatientId,
                          //   'symptoms': _symptomsController.text,
                          //   'medications': _medicationsController.text,
                          //   'treatments': _treatmentsController.text,
                          //   'observations': _observationsController.text,
                          //   'timestamp': FieldValue.serverTimestamp(),
                          //   'nurseId': FirebaseAuth.instance.currentUser?.uid,
                          // });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notes saved successfully'),
                            ),
                          );

                          // Clear fields
                          _symptomsController.clear();
                          _medicationsController.clear();
                          _treatmentsController.clear();
                          _observationsController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B46C1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Notes'),
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

  Widget _buildInputSection(
    String title,
    IconData icon,
    String hint,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6B46C1), size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
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
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Record'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
