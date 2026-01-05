import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_publication.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';
import '../services/firebase_services.dart';
import '../models/prescription_model.dart';
import 'patient_common_widgets.dart';

/// Patient Medication Management Page
///
/// This page provides medication management functionality for patients.
/// Features include:
/// - Next dosage reminder showing the upcoming medication, dosage, and time
/// - Complete medication list with expandable details
/// - Search functionality to find specific medications
/// - Medication cards showing name, dosage, and instructions
/// - Expandable medication cards for detailed information
///
/// The page helps patients track their medications, remember dosage schedules,
/// and access medication information when needed.
class PatientMedicationManagement extends StatefulWidget {
  const PatientMedicationManagement({super.key});

  @override
  State<PatientMedicationManagement> createState() =>
      _PatientMedicationManagementState();
}

/// State class for Patient Medication Management Page
///
/// Manages:
/// - Current navigation index
/// - Search controller for filtering medications
/// - Next dosage reminder information
/// - List of current medications with expandable state
/// - UI state and interactions
class _PatientMedicationManagementState
    extends State<PatientMedicationManagement> {
  /// Current navigation index (1 for medications page)
  int _currentIndex = 1;

  /// Controller for the search text field to filter medications
  final TextEditingController _searchController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Medication Management
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores patient prescriptions from Firebase.
  // To modify the data source:
  // - Change query filters in FirebaseServices.getPatientActivePrescriptions()
  // - Update medication tracking logic if needed
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Medications from Firebase
  List<PrescriptionModel> _allMedications = [];
  List<PrescriptionModel> _filteredMedications = [];

  // Next dosage (from first active prescription)
  Map<String, dynamic> _nextDosage = {
    'medication': 'لا توجد أدوية',
    'dosage': '',
    'time': '',
  };

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads active prescriptions from Firebase.
  //
  // To modify:
  // - Change the query filters in FirebaseServices.getPatientActivePrescriptions()
  // - Update the data mapping if prescription structure changes
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadMedications() async {
    try {
      setState(() => _isLoading = true);

      // Load active prescriptions
      _allMedications = await _firebaseServices.getPatientActivePrescriptions();
      _filteredMedications = _allMedications;

      // Set next dosage from first prescription
      if (_allMedications.isNotEmpty) {
        final firstMed = _allMedications.first;
        _nextDosage = {
          'medication': firstMed.medicationName ?? 'دواء',
          'dosage': firstMed.dosage ?? 'جرعة',
          'time': firstMed.frequency ?? '10:00 ص',
        };
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[PatientMedicationManagement] Error loading medications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الأدوية: $e')));
      }
    }
  }

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the patient medication management UI with reminders and medication list.
  ///
  /// Creates an interface including:
  /// - Status bar simulation at the top
  /// - Header with page title, back button, and search functionality
  /// - Next dosage reminder card highlighting the upcoming medication
  /// - Medication list with expandable cards for detailed information
  /// - Search functionality to filter medications
  /// - Medication cards showing name, dosage, and expandable details
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient medication management UI
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

              // Next dosage banner
              _buildNextDosageBanner(theme),
              const SizedBox(height: 24),

              // Search bar
              _buildSearchBar(theme),
              const SizedBox(height: 24),

              // My Medications heading
              Text(
                'أدويتي',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Medication list
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_filteredMedications.isEmpty)
                Center(
                  child: Text(
                    'لا توجد أدوية',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                ..._filteredMedications.map(
                  (med) => _buildMedicationItem(med, theme),
                ),
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
            'الأدوية',
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
            // TODO: Backend Integration - Add medication reminder
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
          hintText: 'ابحث عن دواء...',
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
          _searchMedications(value);
        },
      ),
    );
  }

  Widget _buildNextDosageBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withOpacity(0.15),
            theme.colorScheme.primary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الجرعة القادمة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_nextDosage['medication']} - ${_nextDosage['dosage']}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الموعد: ${_nextDosage['time']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _searchMedications(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMedications = _allMedications;
      });
      return;
    }

    setState(() {
      _filteredMedications = _allMedications.where((med) {
        final name = (med.medicationName ?? '').toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _buildMedicationItem(PrescriptionModel medication, ThemeData theme) {
    final isTaken = false; // This should be tracked separately in Firebase

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isTaken
            ? theme.colorScheme.secondary.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isTaken
              ? theme.colorScheme.secondary.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Medication icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isTaken
                  ? theme.colorScheme.secondary.withOpacity(0.15)
                  : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isTaken ? Icons.check_circle : Icons.medication,
              color: isTaken
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Medication info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.medicationName ?? 'دواء',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.dosage ?? 'جرعة'} - ${medication.frequency ?? 'تواتر'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Checkbox
          Transform.scale(
            scale: 1.3,
            child: Checkbox(
              value: isTaken,
              onChanged: (value) {
                // TODO: Backend Integration - Mark medication as taken in Firebase
                // This would require a new method in FirebaseServices to update medication status
                setState(() {
                  // For now, just update local state
                  // In production, call FirebaseServices to update the prescription
                });
              },
              activeColor: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
