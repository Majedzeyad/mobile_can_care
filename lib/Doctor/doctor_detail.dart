import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import 'doctor_common_widgets.dart';

/// Doctor Detail Page (UI Layer)
///
/// This page displays the current doctor's profile information.
/// Features:
/// - Personal information (name, age, gender, blood type, etc.)
/// - Professional information (specialization, experience)
/// - Contact information
/// - Documents download (placeholder)
///
/// **Architecture**: Uses DoctorService to handle
/// all Firebase operations, keeping UI separate from data logic.
class DoctorDetail extends StatefulWidget {
  const DoctorDetail({super.key});

  @override
  State<DoctorDetail> createState() => _DoctorDetailState();
}

/// State class for Doctor Detail Page
///
/// Manages:
/// - Doctor profile data
/// - Navigation state
class _DoctorDetailState extends State<DoctorDetail> {
  // ==================== State Variables ====================

  // This page doesn't have a specific index in bottom nav (not in main 4 tabs)
  // It's accessible from drawer only

  // ==================== Doctor Profile Data ====================

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Doctor Profile
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores the doctor's profile data loaded from Firebase.
  // To modify the data source:
  // 1. Change the collection name in FirebaseServices.getDoctorProfile()
  // 2. Update field mappings in _loadDoctorDetails()
  // 3. Modify DoctorModel if new fields are needed
  //
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> _doctor = {
    'name': 'د. غير معروف',
    'doctorId': '',
    'nationalId': '',
    'age': '',
    'gender': '',
    'bloodType': '',
    'nationality': '',
    'specialization': '',
    'experience': '',
    'contactName': '',
    'phone': '',
    'email': '',
  };

  // Loading state
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load doctor profile from Firebase
    _loadDoctorDetails();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads doctor profile from Firebase.
  //
  // To modify:
  // - Change collection name: modify FirebaseServices.getDoctorProfile()
  // - Add new fields: extend DoctorModel and update mapping here
  // - Change data source: query different collection or add joins
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadDoctorDetails() async {
    try {
      setState(() => _isLoading = true);

      print('[Doctor Detail] Loading doctor profile...');
      final doctorId = _firebaseServices.currentUserId;
      print('[Doctor Detail] Current doctor ID: $doctorId');

      // Load doctor profile from Firebase
      // This queries the 'doctors' collection using current user's UID
      // Matches web app structure: queries 'doctors' collection where uid == currentUserId
      // See src/services/firestoreService.js for web app implementation
      // The doctor document structure matches:
      // - uid: Firebase Auth UID (links to authentication)
      // - name, specialization, department, phone, email: Basic info
      // - stats: Statistics object (activePatients, appointmentsToday, pendingLabTests)
      // - workSchedule: Work schedule object
      final doctor = await _firebaseServices.getDoctorProfile();

      if (doctor != null && mounted) {
        print('[Doctor Detail] Doctor profile loaded: ${doctor.name}');
        setState(() {
          _doctor = {
            'name': doctor.name ?? 'د. غير معروف',
            'doctorId': doctor.uid.isNotEmpty ? doctor.uid : (doctorId ?? ''),
            'nationalId': '', // Add to DoctorModel if needed
            'age': '', // Calculate from DOB if available
            'gender': '', // Add to DoctorModel if needed
            'bloodType': '', // Add to DoctorModel if needed
            'nationality': '', // Add to DoctorModel if needed
            'specialization': doctor.specialization ?? 'غير محدد',
            'experience': doctor.stats?['experience']?.toString() ?? 'غير محدد',
            'contactName': '', // Add to DoctorModel if needed
            'phone': doctor.phone ?? '',
            'email': doctor.email ?? '',
          };
          _isLoading = false;
        });
      } else {
        print(
          '[Doctor Detail] Doctor profile not found, trying user profile fallback...',
        );
        // Load from user profile as fallback
        if (doctorId != null) {
          final userProfile = await _firebaseServices.getUserProfile(doctorId);
          if (userProfile != null && mounted) {
            print('[Doctor Detail] User profile loaded as fallback');
            setState(() {
              _doctor['name'] = userProfile.profile?['name'] ?? 'د. غير معروف';
              _doctor['email'] = userProfile.email ?? '';
              _doctor['doctorId'] = doctorId;
              _isLoading = false;
            });
          } else {
            print('[Doctor Detail] User profile also not found');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        } else {
          print('[Doctor Detail] No doctor ID available');
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e, stackTrace) {
      print('[Doctor Detail] ERROR loading doctor profile: $e');
      print('[Doctor Detail] Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الملف الشخصي: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // ==================== UI Action Handlers ====================

  /// Handle document download action
  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Document Download
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // To implement document download from Firebase Storage:
  // 1. Add firebase_storage import
  // 2. Get document URLs from Firestore (stored in doctor document)
  // 3. Use FirebaseStorage.instance.ref().getDownloadURL() to get download links
  // 4. Use url_launcher or download files directly
  //
  // Example:
  // final storageRef = FirebaseStorage.instance.ref('doctors/${doctorId}/documents');
  // final url = await storageRef.getDownloadURL();
  //
  // ═══════════════════════════════════════════════════════════════════════════
  void _downloadDocuments() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري تحميل المستندات...')));
  }

  /// Builds the doctor detail/profile UI.
  ///
  /// Creates a scrollable interface displaying the doctor's complete profile
  /// information including:
  /// - Personal information section (name, age, gender, blood type, nationality)
  /// - Professional information section (specialization, experience)
  /// - Contact information section (phone, email, emergency contact)
  /// - Documents section (placeholder for document downloads)
  /// - Bottom navigation bar for accessing other doctor pages
  ///
  /// The UI uses cards and organized sections for clear presentation of information.
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete doctor detail page UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildDoctorDrawer(context, theme),
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadDoctorDetails,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Doctor Info Card
                            Container(
                              padding: const EdgeInsets.all(20),
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
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoRow(
                                    theme,
                                    'الاسم',
                                    _doctor['name'],
                                  ),
                                  _buildInfoRow(
                                    theme,
                                    'رقم الطبيب',
                                    _doctor['doctorId'],
                                  ),
                                  _buildInfoRow(
                                    theme,
                                    'الرقم الوطني',
                                    _doctor['nationalId'],
                                  ),
                                  _buildInfoRow(theme, 'العمر', _doctor['age']),
                                  _buildInfoRow(
                                    theme,
                                    'الجنس',
                                    _doctor['gender'],
                                  ),
                                  _buildInfoRow(
                                    theme,
                                    'فصيلة الدم',
                                    _doctor['bloodType'],
                                  ),
                                  _buildInfoRow(
                                    theme,
                                    'الجنسية',
                                    _doctor['nationality'],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Specialization Card
                            _buildSectionCard(
                              theme,
                              'التخصص',
                              _doctor['specialization'],
                            ),
                            const SizedBox(height: 16),
                            // Experience Card
                            _buildSectionCard(
                              theme,
                              'الخبرة',
                              _doctor['experience'],
                            ),
                            const SizedBox(height: 16),
                            // Contact Information Card
                            Container(
                              padding: const EdgeInsets.all(20),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'معلومات الاتصال',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Only show contact name if available
                                  if (_doctor['contactName']
                                      .toString()
                                      .isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _doctor['contactName'],
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  if (_doctor['contactName']
                                      .toString()
                                      .isNotEmpty)
                                    const SizedBox(height: 12),
                                  // Only show phone if available
                                  if (_doctor['phone'].toString().isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _doctor['phone'],
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (_doctor['phone'].toString().isNotEmpty)
                                    const SizedBox(height: 12),
                                  // Only show email if available
                                  if (_doctor['email'].toString().isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _doctor['email'],
                                            style: theme.textTheme.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Documents & Reports Card
                            Container(
                              padding: const EdgeInsets.all(20),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المستندات والتقارير',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _downloadDocuments,
                                      icon: const Icon(Icons.download),
                                      label: const Text('تحميل المستندات'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          48,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildDoctorBottomNavBar(
        context,
        theme,
        currentIndex: 0,
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    // Hide empty fields or show "غير متاح" for better UX
    if (value.isEmpty) {
      return const SizedBox.shrink(); // Hide empty fields
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(ThemeData theme, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
