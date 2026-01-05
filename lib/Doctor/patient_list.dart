import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import 'doctor_common_widgets.dart';

/// Patient List Page (UI Layer)
///
/// This page displays a list of all patients assigned to the current doctor.
/// Features:
/// - List of patients with name and diagnosis
/// - Search functionality to filter patients
/// - View patient details button
/// - Bottom navigation bar
class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

/// State class for Patient List Page
class _PatientListState extends State<PatientList> {
  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // Current page index for bottom navigation (1 = Patients)
  static const int pageIndex = 1;

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient List
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores the list of patients assigned to the current doctor.
  // To modify the data source:
  // 1. Change the query in FirebaseServices.getDoctorPatients()
  // 2. Update field mappings in _loadPatients()
  // 3. Modify PatientModel if new fields are needed
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Complete list of all patients (unfiltered)
  List<Map<String, dynamic>> _patients = [];

  /// Filtered list of patients based on search query
  List<Map<String, dynamic>> _filteredPatients = [];

  // Loading state
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load patients from Firebase
    _loadPatients();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads patients assigned to the current doctor from Firebase.
  //
  // To modify:
  // - Change query filters: modify FirebaseServices.getDoctorPatients()
  // - Add sorting: add orderBy in the query
  // - Add pagination: use startAfterDocument() for infinite scroll
  // - Change collection: modify collection name in FirebaseServices
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadPatients() async {
    try {
      setState(() => _isLoading = true);

      // Load patients from Firebase
      // This queries the 'patients' collection filtered by assignedDoctorId
      // Matches web app structure: queries 'patients' collection where assignedDoctorId == doctorUid
      // See src/services/firestoreService.js for web app implementation
      // Note: assignedDoctorId should match doctors.uid (not document ID)
      // Patient structure matches web app:
      // - assignedDoctorId: Doctor's UID (links to doctors.uid)
      // - assignedNurseId: Nurse's UID
      // - name, dob, status: Basic patient info
      // - webData.diagnosis: Diagnosis information
      final patients = await _firebaseServices.getDoctorPatients();

      if (mounted) {
        setState(() {
          _patients = patients.map((patient) {
            // Format last visit date if available
            String lastVisit = 'غير متوفر';
            // You can add lastVisit field to PatientModel if needed
            // if (patient['lastVisit'] != null) {
            //   lastVisit = _formatDate(patient['lastVisit']);
            // }

            return {
              'id': patient['id'] ?? '',
              'name': patient['name'] ?? 'غير معروف',
              'diagnosis': patient['diagnosis'] ?? 'لا يوجد تشخيص',
              'status': patient['status'] ?? 'غير محدد',
              'lastVisit': lastVisit,
              'age': patient['age'],
            };
          }).toList();
    _filteredPatients = _patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Patient List] Error loading patients: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل قائمة المرضى: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handle search input and filter patient list.
  void _searchPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          final name = (patient['name'] ?? '').toString().toLowerCase();
          final diagnosis = (patient['diagnosis'] ?? '')
              .toString()
              .toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || diagnosis.contains(searchLower);
        }).toList();
      }
    });
  }

  /// Navigate to patient details page
  void _viewPatientDetails(Map<String, dynamic> patient) {
    // TODO: Navigate to patient details page when implemented
    // For now, show a snackbar to indicate the action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('عرض تفاصيل ${patient['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildDoctorDrawer(context, theme),
      appBar: AppBar(
        title: const Text('قائمة المرضى'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                      'قائمة المرضى',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // Refresh patient list from Firebase
                      _loadPatients();
                    },
                    tooltip: 'تحديث',
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
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
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchPatients,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مريض...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Patient count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'إجمالي المرضى: ${_filteredPatients.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Patient list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPatients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'لا يوجد مرضى'
                                : 'لا توجد نتائج',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPatients,
                      child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = _filteredPatients[index];
                        final isActive = patient['status'] == 'نشط';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? theme.colorScheme.primary.withOpacity(0.2)
                                  : Colors.grey[300]!,
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _viewPatientDetails(patient),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                                    // Patient avatar
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 28,
                                        color: theme.colorScheme.primary,
                                      ),
                        ),
                        const SizedBox(width: 16),
                                    
                                    // Patient info
                        Expanded(
                          child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                            children: [
                              Text(
                                            patient['name'] ?? 'غير معروف',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                              patient['diagnosis'] ??
                                                  'لا يوجد تشخيص',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                              .withOpacity(0.1)
                                                      : Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                ),
                                                child: Text(
                                                  patient['status'] ?? '',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                    color: isActive
                                                              ? theme
                                                                    .colorScheme
                                                                    .primary
                                                              : Colors
                                                                    .grey[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'آخر زيارة: ${patient['lastVisit']}',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // View button
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        ),
                    ),
                  );
                },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildDoctorBottomNavBar(context, theme, currentIndex: pageIndex),
    );
  }
}
