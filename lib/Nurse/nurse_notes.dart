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
                      'ملاحظات الممرض',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.save,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Backend Integration - Save notes
                    },
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
                          hintText: 'ابحث عن المريض',
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
                          // TODO: Backend Integration - Filter patients by search query
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Symptoms section
                    _buildInputSection(
                      context,
                      'الأعراض',
                      Icons.medical_services,
                      'مثال: حمى، سعال',
                      'أدخل الأعراض...',
                      _symptomsController,
                    ),
                    const SizedBox(height: 16),
                    // Medications section
                    _buildInputSection(
                      context,
                      'الأدوية',
                      Icons.medication,
                      'مثال: باراسيتامول 500 مجم',
                      'أدخل الأدوية...',
                      _medicationsController,
                    ),
                    const SizedBox(height: 16),
                    // Treatments section
                    _buildInputSection(
                      context,
                      'العلاجات',
                      Icons.healing,
                      'مثال: تغيير الضمادة',
                      'أدخل العلاجات...',
                      _treatmentsController,
                    ),
                    const SizedBox(height: 16),
                    // Observations section
                    _buildInputSection(
                      context,
                      'الملاحظات',
                      Icons.remove_red_eye,
                      'مثال: المريض مستقر بعد العلاج',
                      'أدخل الملاحظات...',
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
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('حفظ الملاحظات'),
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
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildInputSection(
    BuildContext context,
    String title,
    IconData icon,
    String hint,
    String placeholder,
    TextEditingController controller,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          style: TextStyle(
            inherit: false,
            fontSize: 12,
            color: Colors.grey[600],
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
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
            style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        // todo: Navigate to different pages
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
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'السجلات'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
      ],
    );
  }
}
