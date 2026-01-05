import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';
import '../services/firebase_services.dart';
import '../models/patient_model.dart';
import '../models/lab_result_model.dart';
import 'patient_common_widgets.dart';

/// Patient Lab Results Review Page
///
/// This page displays all lab test results for the currently logged-in patient.
/// Features include:
/// - Patient profile information (name, age, patient ID)
/// - List of lab test results with status indicators (Normal, Abnormal, Positive, Pending)
/// - Test details showing specific findings
/// - Download functionality for lab result documents (when available)
/// - Visual indicators for different test types (blood tests, urinalysis, EKG, etc.)
///
/// The page allows patients to review their lab results, understand their health
/// status, and access downloadable copies of test reports.
class PatientLabResultsReview extends StatefulWidget {
  const PatientLabResultsReview({super.key});

  @override
  State<PatientLabResultsReview> createState() =>
      _PatientLabResultsReviewState();
}

/// State class for Patient Lab Results Review Page
///
/// Manages:
/// - Current navigation index
/// - Patient information
/// - List of lab test results with status and details
/// - UI state and interactions
class _PatientLabResultsReviewState extends State<PatientLabResultsReview> {
  /// Current navigation index (0 for this page)
  int _currentIndex = 0;

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Lab Results Review
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores patient profile and lab results from Firebase.
  // To modify the data source:
  // - Change query filters in FirebaseServices.getPatientProfile()
  // - Update lab results fetching in FirebaseServices.getPatientLabResults()
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Patient profile from Firebase
  PatientModel? _patientProfile;

  // Lab results from Firebase
  List<LabResultModel> _labResults = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLabResults();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads lab results from Firebase:
  // - Patient profile (name, age, ID)
  // - Lab test results
  //
  // To modify:
  // - Change the query filters in FirebaseServices.getPatientLabResults()
  // - Update the data mapping if lab result structure changes
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadLabResults() async {
    try {
      setState(() => _isLoading = true);

      // Load patient profile
      _patientProfile = await _firebaseServices.getPatientProfile();

      // Load lab results
      _labResults = await _firebaseServices.getPatientLabResults();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[PatientLabResultsReview] Error loading lab results: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل نتائج التحاليل: $e')),
        );
      }
    }
  }

  /// Builds the patient lab results review UI with results list and download options.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title and back button
  /// - Patient profile card with name, age, and ID
  /// - Lab results list with status indicators and color coding
  /// - Test details and findings for each result
  /// - Download buttons for available result documents
  /// - Visual icons representing different test types
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient lab results review UI
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
                    icon: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'نتائج التحاليل',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Backend Integration - Filter lab results
                    },
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
                          // Patient profile card
                          _buildPatientProfileCard(context),
                          const SizedBox(height: 24),
                          // Lab results list
                          if (_labResults.isEmpty)
                            Center(
                              child: Text(
                                'لا توجد نتائج تحاليل',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            )
                          else
                            ..._labResults.map(
                              (result) => _buildLabResultCard(context, result),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientProfileCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                Text(
                  _patientProfile?.name ?? 'المريض',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_patientProfile?.dob != null ? _calculateAgeFromString(_patientProfile!.dob!).toString() : 'غير متاح'} سنة | ${_patientProfile?.id ?? 'غير متاح'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
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

  Widget _buildLabResultCard(BuildContext context, LabResultModel result) {
    final theme = Theme.of(context);
    IconData iconData;
    Color statusColor;

    // Determine icon and color based on result status
    final status = result.status?.toLowerCase() ?? 'normal';
    switch (status) {
      case 'abnormal':
        iconData = Icons.science;
        statusColor = Colors.orange;
        break;
      case 'positive':
        iconData = Icons.medication;
        statusColor = Colors.red;
        break;
      case 'pending':
        iconData = Icons.pending;
        statusColor = Colors.blue;
        break;
      default:
        iconData = Icons.check_circle;
        statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Icon(iconData, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.testName ?? 'تحليل',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الحالة: ${result.status ?? 'غير متاح'}',
                      style: TextStyle(fontSize: 14, color: statusColor),
                    ),
                  ],
                ),
              ),
              // Image placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.results?.toString() ?? 'لا توجد تفاصيل',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          if (result.doctorNotes != null && result.doctorNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ملاحظات الطبيب: ${result.doctorNotes}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // todo: Connect Firebase Storage - Download lab result
                  // LabResultModel doesn't have documentUrl, would need to be added or fetched separately
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لا يوجد ملف متاح حالياً')),
                  );
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // todo: Show more details or navigate to detail page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'عرض تفاصيل ${result.testName ?? 'التحليل'}',
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'عرض المزيد',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getImageIcon(String imageType) {
    switch (imageType) {
      case 'test_tube':
        return Icons.science;
      case 'medicine_bottle':
        return Icons.medication;
      case 'ekg_graph':
        return Icons.favorite;
      case 'test_swab':
        return Icons.medical_services;
      default:
        return Icons.image;
    }
  }
}
