import 'package:flutter/material.dart';
import 'patient_medical_record.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_publication.dart';
import '../services/firebase_services.dart';
import '../models/patient_model.dart';
import '../models/prescription_model.dart';
import 'patient_common_widgets.dart';

/// Patient Profile Page
///
/// This page displays comprehensive patient profile information for the currently
/// logged-in patient. Features include:
/// - Personal information (name, patient ID, national ID, age, gender)
/// - Assigned doctor information
/// - Current medications list with dosage and frequency
/// - Current medical condition/status
/// - Emergency contact information
/// - Medical documents (scans, reports, etc.)
/// - Profile image display
///
/// The page allows patients to view their complete medical profile and access
/// important health information in one place.
class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

/// State class for Patient Profile Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - Patient profile data
/// - Medications list
/// - Contact information
/// - Documents list
/// - UI state and interactions
class _PatientProfileState extends State<PatientProfile> {
  /// Current selected tab index in bottom navigation bar (Profile tab = 4)
  int _currentIndex = 4;

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Profile
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores patient profile, medications, and contact info from Firebase.
  // To modify the data source:
  // - Change query filters in FirebaseServices.getPatientProfile()
  // - Update medication fetching in FirebaseServices.getPatientActivePrescriptions()
  // - Adjust medical records fetching in FirebaseServices.getPatientMedicalRecords()
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Patient profile from Firebase
  PatientModel? _patientProfile;

  // Medications from Firebase
  List<PrescriptionModel> _medications = [];

  // Current condition (from latest medical record)
  String _currentCondition = 'لا توجد معلومات متاحة';

  // Emergency contact (from patient profile)
  Map<String, dynamic> _contact = {
    'name': 'غير متاح',
    'relation': '',
    'phone': 'غير متاح',
    'email': 'غير متاح',
  };

  // Documents (placeholder - can be extended with Firebase Storage)
  List<Map<String, dynamic>> _documents = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientProfile();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads patient profile data from Firebase:
  // - Patient profile (name, ID, age, gender, doctor, etc.)
  // - Active medications
  // - Current medical condition (from latest medical record)
  // - Emergency contact information
  //
  // To modify:
  // - Change the query filters in FirebaseServices methods
  // - Add new data sources by extending this method
  // - Update the data mapping if model structures change
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadPatientProfile() async {
    try {
      setState(() => _isLoading = true);

      // Load patient profile
      _patientProfile = await _firebaseServices.getPatientProfile();

      // Load active medications
      _medications = await _firebaseServices.getPatientActivePrescriptions();

      // Load latest medical record for current condition
      final medicalRecords = await _firebaseServices.getPatientMedicalRecords();
      if (medicalRecords.isNotEmpty) {
        final latestRecord = medicalRecords.first;
        _currentCondition = latestRecord.description ?? 'لا توجد معلومات متاحة';
      }

      // Extract contact info from patient profile
      if (_patientProfile != null) {
        _contact = {
          'name':
              _patientProfile!.webData?['emergencyContactName']?.toString() ??
              'غير متاح',
          'relation':
              _patientProfile!.webData?['emergencyContactRelation']
                  ?.toString() ??
              '',
          'phone':
              _patientProfile!.webData?['emergencyContactPhone']?.toString() ??
              _patientProfile!.phone ??
              'غير متاح',
          'email': _patientProfile!.email ?? 'غير متاح',
        };
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[PatientProfile] Error loading patient profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الملف الشخصي: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildPatientDrawer(context, theme),
      bottomNavigationBar: buildPatientBottomNavBar(
        context,
        theme,
        currentIndex: 3, // الملف
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header
                    _buildHeader(theme),
                    const SizedBox(height: 32),

                    // Patient photo
                    _buildProfilePhoto(theme),
                    const SizedBox(height: 24),

                    // Patient information card
                    _buildPatientInfoCard(theme),
                    const SizedBox(height: 16),

                    // Active medications card
                    _buildMedicationsCard(theme),
                    const SizedBox(height: 16),

                    // Current condition card
                    _buildConditionCard(theme),
                    const SizedBox(height: 16),

                    // Contact information card
                    _buildContactCard(theme),
                    const SizedBox(height: 16),

                    // Documents card
                    _buildDocumentsCard(theme),
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
            'ملفي الشخصي',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            size: 28,
            color: theme.colorScheme.primary,
          ),
          onPressed: () {
            // TODO: Backend Integration - Edit profile
          },
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 70,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.person, size: 70, color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildPatientInfoCard(ThemeData theme) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الشخصية',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            Icons.person,
            'الاسم',
            _patientProfile?.name ?? 'غير متاح',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.badge,
            'رقم المريض',
            '#${_patientProfile?.id ?? 'غير متاح'}',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.credit_card,
            'الرقم الوطني',
            _patientProfile?.webData?['nationalId']?.toString() ?? 'غير متاح',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.cake,
            'العمر',
            _patientProfile?.dob != null
                ? _calculateAgeFromString(_patientProfile!.dob!).toString()
                : 'غير متاح',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.wc,
            'الجنس',
            _patientProfile?.gender ?? 'غير متاح',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.medical_services,
            'الطبيب المعالج',
            _patientProfile?.assignedDoctorId ?? 'غير متاح',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'الأدوية النشطة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_medications.isEmpty)
            Text(
              'لا توجد أدوية نشطة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            )
          else
            ..._medications.map(
              (med) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${med.medicationName ?? 'دواء'} (${med.dosage ?? 'جرعة'}) - ${med.frequency ?? 'تواتر'}',
                        style: theme.textTheme.bodyMedium,
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

  Widget _buildConditionCard(ThemeData theme) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'الحالة الصحية',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_currentCondition, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Backend Integration - Navigate to medical record
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientMedicalRecord(),
                ),
              );
            },
            icon: const Icon(Icons.description, size: 20),
            label: const Text('عرض السجل الطبي'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ThemeData theme) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الاتصال الطارئة',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildContactRow(
            theme,
            Icons.person,
            'الاسم',
            '${_contact['name']} (${_contact['relation']})',
          ),
          const SizedBox(height: 16),
          _buildContactRow(theme, Icons.phone, 'الهاتف', _contact['phone']),
          const SizedBox(height: 16),
          _buildContactRow(theme, Icons.email, 'البريد', _contact['email']),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.secondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsCard(ThemeData theme) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.folder_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'المستندات والتقارير',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._documents.map(
            (doc) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(doc['name'], style: theme.textTheme.bodyMedium),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Backend Integration - Download document
                    },
                    icon: Icon(
                      Icons.download,
                      color: theme.colorScheme.primary,
                      size: 24,
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
