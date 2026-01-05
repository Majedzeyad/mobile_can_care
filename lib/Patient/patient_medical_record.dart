import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import 'patient_profile.dart';
import '../services/firebase_services.dart';
import '../models/patient_model.dart';
import '../models/medical_record_model.dart';
import '../models/lab_result_model.dart';
import 'patient_common_widgets.dart';

/// Patient Medical Record Page
///
/// This page displays comprehensive medical record information for the currently
/// logged-in patient. Features include:
/// - Patient personal information (name, national ID, age, gender, allergies)
/// - Current diagnosis and treatment plan
/// - Medical history (chronic conditions, previous surgeries, family history)
/// - Lifestyle information
/// - Lab results with values and status indicators
/// - Search functionality to find specific records
///
/// The page provides patients with complete access to their medical history,
/// allowing them to review diagnoses, treatments, and test results in one place.
class PatientMedicalRecord extends StatefulWidget {
  const PatientMedicalRecord({super.key});

  @override
  State<PatientMedicalRecord> createState() => _PatientMedicalRecordState();
}

/// State class for Patient Medical Record Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Search controller for filtering records
/// - Patient information
/// - Diagnosis and treatment plan data
/// - Medical history information
/// - Lab results list
/// - UI state and interactions
class _PatientMedicalRecordState extends State<PatientMedicalRecord> {
  /// Current selected tab index in bottom navigation bar (Records tab = 3)
  int _currentIndex = 3;

  /// Controller for the search text field to filter medical records
  final TextEditingController _searchController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Medical Record
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores patient profile, medical records, and lab results from Firebase.
  // To modify the data source:
  // - Change query filters in FirebaseServices.getPatientProfile()
  // - Update medical records fetching in FirebaseServices.getPatientMedicalRecords()
  // - Adjust lab results fetching in FirebaseServices.getPatientLabResults()
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Patient profile from Firebase
  PatientModel? _patientProfile;

  // Medical records from Firebase
  List<MedicalRecordModel> _medicalRecords = [];

  // Lab results from Firebase
  List<LabResultModel> _labResults = [];

  // Current diagnosis (from latest medical record)
  Map<String, dynamic> _diagnosis = {
    'condition': 'لا توجد معلومات متاحة',
    'dateDiagnosed': 'غير متاح',
    'treatmentPlan': 'غير متاح',
  };

  // Medical history (from patient profile and records)
  Map<String, dynamic> _medicalHistory = {
    'chronicConditions': 'غير متاح',
    'previousSurgeries': 'غير متاح',
    'familyHistory': 'غير متاح',
  };

  // Lifestyle information
  String _lifestyle = 'غير متاح';

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalRecordData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads medical record data from Firebase:
  // - Patient profile (name, ID, age, gender, etc.)
  // - Medical records (diagnosis, treatment plan, etc.)
  // - Lab results
  //
  // To modify:
  // - Change the query filters in FirebaseServices methods
  // - Add new data sources by extending this method
  // - Update the data mapping if model structures change
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadMedicalRecordData() async {
    try {
      setState(() => _isLoading = true);

      // Load patient profile
      _patientProfile = await _firebaseServices.getPatientProfile();

      // Load medical records
      _medicalRecords = await _firebaseServices.getPatientMedicalRecords();

      // Load lab results
      _labResults = await _firebaseServices.getPatientLabResults();

      // Extract diagnosis from latest medical record
      if (_medicalRecords.isNotEmpty) {
        final latestRecord = _medicalRecords.first;
        _diagnosis = {
          'condition': latestRecord.category ?? 'لا توجد معلومات متاحة',
          'dateDiagnosed': latestRecord.createdAt != null
              ? _formatDate(latestRecord.createdAt!)
              : 'غير متاح',
          'treatmentPlan': latestRecord.description ?? 'غير متاح',
        };
      }

      // Extract medical history from patient profile webData
      if (_patientProfile != null) {
        _medicalHistory = {
          'chronicConditions':
              _patientProfile!.webData?['chronicConditions']?.toString() ??
              'غير متاح',
          'previousSurgeries':
              _patientProfile!.webData?['previousSurgeries']?.toString() ??
              'غير متاح',
          'familyHistory':
              _patientProfile!.webData?['familyHistory']?.toString() ??
              'غير متاح',
        };
        _lifestyle =
            _patientProfile!.webData?['lifestyle']?.toString() ?? 'غير متاح';
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[PatientMedicalRecord] Error loading medical record data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل السجل الطبي: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the patient medical record UI with comprehensive health information.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title and search functionality
  /// - Patient information card with personal details
  /// - Diagnosis section with condition and treatment plan
  /// - Medical history section (chronic conditions, surgeries, family history)
  /// - Lifestyle information
  /// - Lab results section with test values and status indicators
  /// - Organized sections for easy navigation
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient medical record UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildPatientDrawer(context, theme),
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
                          'السجل الطبي',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          size: 24,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          // TODO: Backend Integration - Search medical records
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
                        hintText: 'ابحث في السجلات...',
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
                        // TODO: Backend Integration - Filter records by search query
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Patient summary card
                          _buildPatientSummaryCard(),
                          const SizedBox(height: 16),
                          // Diagnosis card
                          _buildDiagnosisCard(),
                          const SizedBox(height: 16),
                          // Medical history card
                          _buildMedicalHistoryCard(),
                          const SizedBox(height: 16),
                          // Lifestyle card
                          _buildLifestyleCard(),
                          const SizedBox(height: 16),
                          // Lab results card
                          _buildLabResultsCard(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildPatientBottomNavBar(
        context,
        theme,
        currentIndex: 0, // الرئيسية
      ),
    );
  }

  Widget _buildPatientSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoText('Name', _patientProfile?.name ?? 'غير متاح'),
                const SizedBox(height: 4),
                _buildInfoText(
                  'National Id',
                  _patientProfile?.webData?['nationalId']?.toString() ??
                      'غير متاح',
                ),
                const SizedBox(height: 4),
                _buildInfoText(
                  'Age',
                  _patientProfile?.dob != null
                      ? _calculateAgeFromString(
                          _patientProfile!.dob!,
                        ).toString()
                      : 'غير متاح',
                ),
                const SizedBox(height: 4),
                _buildInfoText('Gender', _patientProfile?.gender ?? 'غير متاح'),
                const SizedBox(height: 4),
                _buildInfoText(
                  'Allergies',
                  _patientProfile?.webData?['allergies']?.toString() ??
                      'لا توجد',
                ),
                const SizedBox(height: 4),
                _buildInfoText(
                  'Dr.',
                  _patientProfile?.assignedDoctorId ?? 'غير متاح',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Text('$label: $value', style: Theme.of(context).textTheme.bodySmall);
  }

  Widget _buildDiagnosisCard() {
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
            'Diagnosis:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Condition: ${_diagnosis['condition']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Date Diagnosed: ${_diagnosis['dateDiagnosed']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Current Treatment Plan: ${_diagnosis['treatmentPlan']}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard() {
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
            'Medical History:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Chronic Conditions: ${_medicalHistory['chronicConditions']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Previous Surgeries: ${_medicalHistory['previousSurgeries']}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Family History: ${_medicalHistory['familyHistory']}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(_lifestyle, style: const TextStyle(fontSize: 14))],
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
            'Recent Lab Test Results:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (_labResults.isEmpty)
            Text(
              'لا توجد نتائج تحاليل',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          else
            ..._labResults
                .take(5)
                .map(
                  (result) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.testName ?? 'تحليل'}: ${result.results?.toString() ?? 'غير متاح'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (result.doctorNotes != null &&
                            result.doctorNotes!.isNotEmpty)
                          Text(
                            '(${result.doctorNotes})',
                            style: TextStyle(
                              inherit: false,
                              fontSize: 12,
                              color: Colors.grey[600],
                              textBaseline: TextBaseline.alphabetic,
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

  int _calculateAgeFromString(String dobString) {
    final dob = DateTime.tryParse(dobString);
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
