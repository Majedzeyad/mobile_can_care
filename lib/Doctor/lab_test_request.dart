import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import 'doctor_common_widgets.dart';

/// Lab Test Request Page (UI Layer)
///
/// This page allows doctors to:
/// - Request new lab tests for patients
/// - View pending lab test requests
/// - Select patient, test type, and urgency
///
/// **Architecture**: Uses PatientService and LabService to handle
/// all Firebase operations, keeping UI separate from data logic.
class LabTestRequest extends StatefulWidget {
  const LabTestRequest({super.key});

  @override
  State<LabTestRequest> createState() => _LabTestRequestState();
}

/// State class for Lab Test Request Page
///
/// Manages:
/// - Form state (patient selection, test type, urgency)
/// - List of available patients
/// - List of pending test requests
/// - Form submission
class _LabTestRequestState extends State<LabTestRequest> {
  // ==================== State Variables ====================

  // This page doesn't have a specific index in bottom nav (not in main 4 tabs)
  // It's accessible from drawer only

  /// Selected tab: 0 = Pending Results, 1 = Completed Tests
  int _selectedTab = 0;

  /// Selected patient name from dropdown
  String? _selectedPatient;

  /// Selected test type (e.g., "Blood Test", "COVID-19", "Urinalysis")
  String? _selectedTestType;

  /// Selected specific test (e.g., "rapid", "serology" for COVID-19)
  String? _selectedTest;

  /// Selected urgency level ("low", "normal", "high", "urgent")
  String? _selectedUrgency;

  /// Controller for additional notes text field
  final TextEditingController _notesController = TextEditingController();

  // ==================== Data Lists ====================

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Lab Test Request Data
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // These lists store data for lab test requests.
  // To modify the data source:
  // 1. Change patient list: modify FirebaseServices.getDoctorPatients()
  // 2. Change test types: update _testTypes list or load from Firestore
  // 3. Change pending requests: modify FirebaseServices.getDoctorPendingLabRequests()
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// List of patients for dropdown selection (loaded from Firebase)
  List<Map<String, dynamic>> _patients = [];
  List<String> _patientNames = [];

  /// Available test types (can be loaded from Firestore if needed)
  List<String> _testTypes = ['تحليل الدم', 'تحليل البول', 'كوفيد-19'];

  /// List of pending lab test requests (loaded from Firebase)
  List<Map<String, dynamic>> _pendingResults = [];

  // Loading state
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load data from Firebase
    _loadData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads patients and pending lab requests from Firebase.
  //
  // To modify:
  // - Change patient query: modify FirebaseServices.getDoctorPatients()
  // - Add test types from Firestore: query 'test_types' collection
  // - Change pending requests query: modify FirebaseServices.getDoctorPendingLabRequests()
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      print('[Lab Test Request] Loading data...');
      final doctorId = _firebaseServices.currentUserId;
      print('[Lab Test Request] Doctor ID: $doctorId');

      // Load patients assigned to doctor
      // Queries 'patients' collection where assignedDoctorId == doctorUid
      // Matches web app structure in src/services/firestoreService.js
      final patients = await _firebaseServices.getDoctorPatients();
      print('[Lab Test Request] Loaded ${patients.length} patients');

      // Load pending lab test requests
      // Queries 'mobile_lab_test_requests' collection where doctorId == doctorUid and status == 'pending'
      // Note: doctorId should match doctors.uid (not document ID)
      // This is a mobile-specific collection (not in web app)
      final pendingRequests = await _firebaseServices
          .getDoctorPendingLabRequests();
      print(
        '[Lab Test Request] Loaded ${pendingRequests.length} pending requests',
      );

      if (mounted) {
        setState(() {
          _patients = patients;
          // Filter out null names and ensure type safety
          _patientNames = patients
              .map((p) => p['name'] as String? ?? 'غير معروف')
              .where((name) => name.isNotEmpty)
              .toList();
          _pendingResults = pendingRequests.map((req) {
            return {
              'id': req['id'] ?? '',
              'patient': req['patientName'] ?? 'غير معروف',
              'timestamp': req['formattedDate'] ?? 'غير متوفر',
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('[Lab Test Request] ERROR loading data: $e');
      print('[Lab Test Request] Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Clean up resources when widget is disposed
  ///
  /// Disposes the notes controller to prevent memory leaks.
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ==================== Data Loading Methods ====================

  // Removed: _loadData() - TODO: Backend Integration

  // ==================== Form Submission Methods ====================

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Create Lab Test Request
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method creates a lab test request in Firebase.
  //
  // To modify:
  // - Change collection name: modify FirebaseServices.createLabTestRequest()
  // - Add validation: check patient exists, test type is valid
  // - Add notifications: send push notification to lab staff
  // - Add error handling: handle specific Firebase errors
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _requestTest() async {
    // Validate form inputs
    if (_selectedPatient == null || _selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المريض ونوع التحليل')),
      );
      return;
    }

    try {
      print('[Lab Test Request] Creating lab test request...');

      // Find patient ID from selected patient name
      final selectedPatientData = _patients.firstWhere(
        (p) => (p['name'] as String? ?? '') == _selectedPatient,
        orElse: () => {'id': '', 'name': _selectedPatient},
      );
      final patientId = selectedPatientData['id'] as String? ?? '';

      if (patientId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ: لم يتم العثور على المريض')),
          );
        }
        return;
      }

      // Create lab test request in Firebase
      // This adds a document to 'mobile_lab_test_requests' collection
      // Structure matches mobile app requirements:
      // - doctorId: Doctor's UID (should match doctors.uid)
      // - patientId: Patient document ID
      // - patientName: Patient name
      // - testType, test: Test information
      // - urgency: Urgency level
      // - status: 'pending' (default)
      // - createdAt: Server timestamp
      await _firebaseServices.createLabTestRequest(
        patientId: patientId,
        patientName: _selectedPatient!,
        testType: _selectedTestType ?? 'غير محدد',
        test: _selectedTest!,
        urgency: _selectedUrgency ?? 'normal',
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      print('[Lab Test Request] Lab test request created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم طلب التحليل بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );

        // Clear form
        setState(() {
          _selectedPatient = null;
          _selectedTestType = null;
          _selectedTest = null;
          _selectedUrgency = null;
          _notesController.clear();
        });

        // Reload pending requests to show the new one
        await _loadData();
      }
    } catch (e, stackTrace) {
      print('[Lab Test Request] ERROR creating request: $e');
      print('[Lab Test Request] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء الطلب: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildDoctorDrawer(context, theme),
      appBar: AppBar(
        title: const Text('طلب تحليل جديد'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? const Color(0xFF6B46C1)
                              : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'النتائج المعلقة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? const Color(0xFF6B46C1)
                              : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'التحاليل المكتملة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: _selectedTab == 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Select Patient
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedPatient,
                                      decoration: const InputDecoration(
                                        labelText: 'اختر المريض',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: _patientNames.map((patient) {
                                        return DropdownMenuItem(
                                          value: patient,
                                          child: Text(patient),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(
                                          () => _selectedPatient = value,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Select Test Type
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedTestType,
                                      decoration: const InputDecoration(
                                        labelText: 'اختر نوع التحليل',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: _testTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTestType = value;
                                          _selectedTest = null;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Radio buttons for COVID-19 tests
                                  // Note: Check for Arabic text 'كوفيد-19' to match _testTypes
                                  if (_selectedTestType == 'كوفيد-19')
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          RadioListTile<String>(
                                            title: const Text(
                                              'فحص سريع - كوفيد-19',
                                            ),
                                            value: 'rapid',
                                            groupValue: _selectedTest,
                                            onChanged: (value) {
                                              setState(
                                                () => _selectedTest = value,
                                              );
                                            },
                                          ),
                                          RadioListTile<String>(
                                            title: const Text(
                                              'فحص مصلي - كوفيد-19',
                                            ),
                                            value: 'serology',
                                            groupValue: _selectedTest,
                                            onChanged: (value) {
                                              setState(
                                                () => _selectedTest = value,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Show test selection for other test types
                                  if (_selectedTestType != null &&
                                      _selectedTestType != 'كوفيد-19')
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedTest,
                                        decoration: const InputDecoration(
                                          labelText: 'اختر التحليل',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: _selectedTestType == 'تحليل الدم'
                                            ? [
                                                'CBC',
                                                'Hemoglobin',
                                                'Glucose',
                                              ].map((test) {
                                                return DropdownMenuItem(
                                                  value: test,
                                                  child: Text(test),
                                                );
                                              }).toList()
                                            : _selectedTestType == 'تحليل البول'
                                            ? ['Urinalysis', 'Culture'].map((
                                                test,
                                              ) {
                                                return DropdownMenuItem(
                                                  value: test,
                                                  child: Text(test),
                                                );
                                              }).toList()
                                            : [],
                                        onChanged: (value) {
                                          setState(() => _selectedTest = value);
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  // Additional Notes
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      controller: _notesController,
                                      maxLines: 3,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      decoration: const InputDecoration(
                                        labelText: 'ملاحظات إضافية',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Urgency
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedUrgency,
                                      decoration: const InputDecoration(
                                        labelText: 'مستوى الأولوية',
                                        border: OutlineInputBorder(),
                                      ),
                                      items:
                                          [
                                            'منخفضة',
                                            'عادية',
                                            'عالية',
                                            'عاجلة',
                                          ].map((urgency) {
                                            return DropdownMenuItem(
                                              value: urgency == 'منخفضة'
                                                  ? 'low'
                                                  : urgency == 'عادية'
                                                  ? 'normal'
                                                  : urgency == 'عالية'
                                                  ? 'high'
                                                  : 'urgent',
                                              child: Text(urgency),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(
                                          () => _selectedUrgency = value,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Request Tests button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _requestTest,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6B46C1,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'طلب التحليل',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Pending Results list
                                  const Text(
                                    'النتائج المعلقة',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _pendingResults.isEmpty
                                      ? Container(
                                          padding: const EdgeInsets.all(32),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.inbox_outlined,
                                                  size: 64,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'لا توجد طلبات معلقة',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: _pendingResults.map((
                                            result,
                                          ) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${result['patient'] ?? 'غير معروف'}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium,
                                                    ),
                                                  ),
                                                  Text(
                                                    result['timestamp'] ??
                                                        'غير متوفر',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                ],
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.construction_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'قريباً: التحاليل المكتملة',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
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
}
