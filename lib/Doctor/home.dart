import 'package:flutter/material.dart';
import 'doctor_detail.dart';
import 'lab_results_review.dart';
import 'override_requests.dart';
import 'patient_list.dart';
import 'medications.dart';
import 'lab_test_request.dart';
import 'incoming_requests.dart';
import '../services/firebase_services.dart';
import '../pages/login_page.dart';
import '../models/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_common_widgets.dart';

/// Doctor Dashboard Page - لوحة تحكم الطبيب
///
/// تصميم احترافي وفعال للأطباء يركز على:
/// - عرض المعلومات بكثافة معتدلة وواضحة
/// - سهولة الوصول للوظائف الأكثر استخداماً
/// - إحصائيات واضحة ومباشرة
/// - تنظيم بصري احترافي بألوان هادئة
/// - إجراءات سريعة واضحة وسهلة الوصول
class Dashdoctor extends StatefulWidget {
  const Dashdoctor({super.key});

  @override
  State<Dashdoctor> createState() => DdashdoctorState();
}

class DdashdoctorState extends State<Dashdoctor> {
  final TextEditingController _searchController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Dashboard Statistics
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // هذه المتغيرات تخزن إحصائيات لوحة التحكم المحملة من Firebase.
  //
  // **المجموعات (Collections) المستخدمة:**
  // 1. 'patients' - للمرضى النشطين
  //    - الحقل: assignedDoctorId (يجب أن يطابق doctors.uid)
  //    - الاستعلام: where('assignedDoctorId', isEqualTo: doctorId)
  //
  // 2. 'mobile_lab_test_requests' - لنتائج التحاليل المعلقة
  //    - الحقول: doctorId, status
  //    - الاستعلام: where('doctorId', isEqualTo: doctorId).where('status', isEqualTo: 'pending')
  //
  // 3. 'mobile_prescriptions' - للوصفات الطبية الحديثة (آخر 7 أيام)
  //    - الحقول: doctorId, createdAt
  //    - الاستعلام: where('doctorId', isEqualTo: doctorId)
  //                  .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
  //
  // 4. 'mobile_override_requests' - لطلبات الموافقة المعلقة
  //    - الحقل: doctorId
  //    - الاستعلام: where('doctorId', isEqualTo: doctorId).where('status', isEqualTo: 'pending')
  //
  // 5. 'web_appointments' - لمواعيد اليوم
  //    - الحقول: doctorId, appointmentDate
  //    - الاستعلام: where('doctorId', isEqualTo: doctorId)
  //                  .where('appointmentDate', isGreaterThanOrEqualTo: startOfToday)
  //                  .where('appointmentDate', isLessThan: endOfToday)
  //    - ملاحظة: يستخدم 'web_appointments' بدلاً من 'appointments' لمطابقة بنية التطبيق الويب
  //
  // **ملاحظات مهمة:**
  // - doctorId يجب أن يكون uid من Firebase Auth (ليس document ID)
  // - جميع الاستعلامات تتم عبر FirebaseServices.getDoctorDashboardStats()
  // - البيانات تُحدّث تلقائياً عند استدعاء _loadDashboardData()
  //
  // **لتعديل مصدر البيانات:**
  // 1. عدّل الاستعلامات في FirebaseServices.getDoctorDashboardStats()
  // 2. عدّل التعيين في _loadDashboardData()
  // 3. أضف إحصائيات جديدة بتمديد الـ return map
  //
  // ═══════════════════════════════════════════════════════════════════════════

  int activePatients = 0; // للمرضى النشطين
  int pendingLabResults = 0; // لنتائج التحاليل المعلقة
  int recentPrescriptions = 0; // للوصفات الطبية الحديثة (آخر 7 أيام)
  int pendingRequests = 0; // لطلبات الموافقة المعلقة

  // Loading state for dashboard data
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Doctor profile for displaying name
  DoctorModel? _doctorProfile;

  // Today's appointments
  List<Map<String, dynamic>> _todayAppointments = [];
  bool _isLoadingAppointments = false;

  @override
  void initState() {
    super.initState();
    // Load dashboard data from Firebase
    _loadDashboardData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads dashboard statistics directly from Firebase collections.
  // All queries are executed here in the page for transparency and easy modification.
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // Get doctor ID (uid from Firebase Auth)
      final doctorId = _firebaseServices.currentUserId;
      print('[Doctor Home] Loading dashboard for doctorId: $doctorId');

      if (doctorId == null) {
        print('[Doctor Home] ERROR: No doctor ID found!');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ: لم يتم العثور على معرف الطبيب')),
          );
        }
        return;
      }

      // Load doctor profile for name display
      _doctorProfile = await _firebaseServices.getDoctorProfile();
      print(
        '[Doctor Home] Doctor profile loaded: ${_doctorProfile?.name ?? 'null'}',
      );

      // ═══════════════════════════════════════════════════════════════════════
      // 1. COUNT ACTIVE PATIENTS from 'patients' collection
      // ═══════════════════════════════════════════════════════════════════════
      // Query: where('assignedDoctorId', isEqualTo: doctorId)
      // Note: assignedDoctorId must match doctors.uid (not document ID)
      // Also try 'doctorId' field as fallback
      try {
        var patientsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .where('assignedDoctorId', isEqualTo: doctorId)
            .get();

        // If no results, try with 'doctorId' field
        if (patientsSnapshot.docs.isEmpty) {
          print(
            '[Doctor Home] No patients found with assignedDoctorId, trying doctorId...',
          );
          patientsSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .where('doctorId', isEqualTo: doctorId)
              .get();
        }

        activePatients = patientsSnapshot.docs.length;
        print('[Doctor Home] Active patients count: $activePatients');

        // Debug: Print first patient if exists
        if (patientsSnapshot.docs.isNotEmpty) {
          final firstPatient = patientsSnapshot.docs.first.data();
          print(
            '[Doctor Home] Sample patient data: ${firstPatient.keys.toList()}',
          );
        }
      } catch (e) {
        print('[Doctor Home] Error loading patients: $e');
        activePatients = 0;
      }

      // ═══════════════════════════════════════════════════════════════════════
      // 2. COUNT PENDING LAB TESTS from 'mobile_lab_test_requests' collection
      // ═══════════════════════════════════════════════════════════════════════
      // Query: where('doctorId', isEqualTo: doctorId).where('status', isEqualTo: 'pending')
      // Note: doctorId must match doctors.uid (not document ID)
      try {
        final pendingLabTestsSnapshot = await FirebaseFirestore.instance
            .collection('mobile_lab_test_requests')
            .where('doctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'pending')
            .get();
        pendingLabResults = pendingLabTestsSnapshot.docs.length;
        print('[Doctor Home] Pending lab tests count: $pendingLabResults');
      } catch (e) {
        print('[Doctor Home] Error loading lab tests: $e');
        pendingLabResults = 0;
      }

      // ═══════════════════════════════════════════════════════════════════════
      // 3. COUNT RECENT PRESCRIPTIONS from 'mobile_prescriptions' collection
      // ═══════════════════════════════════════════════════════════════════════
      // Query: where('doctorId', isEqualTo: doctorId)
      //        .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
      // Note: Counts prescriptions from last 7 days
      //
      // IMPORTANT: This query requires a composite index in Firebase Console.
      // If you get an error, click the link in the error message to create it automatically,
      // OR create it manually:
      // Collection: mobile_prescriptions
      // Fields: doctorId (Ascending), createdAt (Ascending)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      try {
        final prescriptionsSnapshot = await FirebaseFirestore.instance
            .collection('mobile_prescriptions')
            .where('doctorId', isEqualTo: doctorId)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
            )
            .get();
        recentPrescriptions = prescriptionsSnapshot.docs.length;
        print('[Doctor Home] Recent prescriptions count: $recentPrescriptions');
      } catch (e) {
        // If index error, try alternative: get all and filter in code
        if (e.toString().contains('index') ||
            e.toString().contains('FAILED_PRECONDITION')) {
          print(
            '[Doctor Home] Index required for prescriptions query, using alternative method...',
          );
          try {
            final allPrescriptionsSnapshot = await FirebaseFirestore.instance
                .collection('mobile_prescriptions')
                .where('doctorId', isEqualTo: doctorId)
                .get();

            recentPrescriptions = allPrescriptionsSnapshot.docs.where((doc) {
              final createdAt = doc.data()['createdAt'];
              if (createdAt == null) return false;
              final date = createdAt is Timestamp
                  ? createdAt.toDate()
                  : (createdAt is DateTime ? createdAt : null);
              if (date == null) return false;
              return date.isAfter(sevenDaysAgo) ||
                  date.isAtSameMomentAs(sevenDaysAgo);
            }).length;
            print(
              '[Doctor Home] Recent prescriptions (alternative method): $recentPrescriptions',
            );
          } catch (e2) {
            print(
              '[Doctor Home] Error in alternative prescriptions method: $e2',
            );
            recentPrescriptions = 0;
          }
        } else {
          print('[Doctor Home] Error loading prescriptions: $e');
          recentPrescriptions = 0;
        }
      }

      // ═══════════════════════════════════════════════════════════════════════
      // 4. COUNT PENDING OVERRIDE REQUESTS from 'mobile_override_requests' collection
      // ═══════════════════════════════════════════════════════════════════════
      // Query: where('doctorId', isEqualTo: doctorId).where('status', isEqualTo: 'pending')
      // Note: doctorId must match doctors.uid (not document ID)
      try {
        final overrideRequestsSnapshot = await FirebaseFirestore.instance
            .collection('mobile_override_requests')
            .where('doctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'pending')
            .get();
        pendingRequests = overrideRequestsSnapshot.docs.length;
        print(
          '[Doctor Home] Pending override requests count: $pendingRequests',
        );
      } catch (e) {
        print('[Doctor Home] Error loading override requests: $e');
        pendingRequests = 0;
      }

      // Load today's appointments
      await _loadTodayAppointments();

      // Print summary
      print('[Doctor Home] Dashboard data loaded:');
      print('  - Active patients: $activePatients');
      print('  - Pending lab results: $pendingLabResults');
      print('  - Recent prescriptions: $recentPrescriptions');
      print('  - Pending requests: $pendingRequests');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Doctor Home] ERROR loading dashboard data: $e');
      print('[Doctor Home] Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Reset to 0 on error
          activePatients = 0;
          pendingLabResults = 0;
          recentPrescriptions = 0;
          pendingRequests = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD - Today's Appointments
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads today's appointments from Firebase 'web_appointments' collection.
  // Filters by doctorId (using uid) and today's date.
  // Note: Uses 'web_appointments' collection to match web app structure.
  //
  // To modify:
  // - Change the collection name if different
  // - Adjust date filtering logic
  // - Update field mappings if appointment structure changes
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadTodayAppointments() async {
    try {
      setState(() => _isLoadingAppointments = true);

      final doctorId = _firebaseServices.currentUserId;
      if (doctorId == null) {
        print('[Doctor Home] No doctor ID for appointments');
        setState(() => _todayAppointments = []);
        return;
      }

      // Get start and end of today
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = startOfToday.add(const Duration(days: 1));

      print(
        '[Doctor Home] Loading appointments for today: $startOfToday to $endOfToday',
      );

      // Query appointments for today
      // Note: Using 'web_appointments' collection (matches web app structure)
      // Using simpler query without orderBy to avoid index requirement
      // We'll sort in code if needed
      QuerySnapshot appointmentsSnapshot;
      try {
        // Try with doctorId first - using 'web_appointments' collection
        appointmentsSnapshot = await FirebaseFirestore.instance
            .collection('web_appointments')
            .where('doctorId', isEqualTo: doctorId)
            .get();

        print(
          '[Doctor Home] Total appointments found in web_appointments: ${appointmentsSnapshot.docs.length}',
        );

        // Filter by date in code to avoid index requirement
        // Note: web_appointments uses 'date' (String: "YYYY-MM-DD") and 'time' (String: "HH:mm") separately
        // Not 'appointmentDate' as Timestamp
        _todayAppointments = appointmentsSnapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};

              // Try to get date from different possible fields
              String? dateStr = data['date'] as String?;
              if (dateStr == null || dateStr.isEmpty) {
                // Fallback: try appointmentDate as Timestamp
                final aptDate = (data['appointmentDate'] as Timestamp?)
                    ?.toDate();
                if (aptDate != null) {
                  dateStr =
                      '${aptDate.year}-${aptDate.month.toString().padLeft(2, '0')}-${aptDate.day.toString().padLeft(2, '0')}';
                }
              }

              if (dateStr == null || dateStr.isEmpty) return false;

              // Compare date string directly (format: "YYYY-MM-DD")
              try {
                final todayStr =
                    '${startOfToday.year}-${startOfToday.month.toString().padLeft(2, '0')}-${startOfToday.day.toString().padLeft(2, '0')}';
                return dateStr == todayStr;
              } catch (e) {
                print(
                  '[Doctor Home] Error comparing date: $dateStr, error: $e',
                );
                return false;
              }
            })
            .take(5)
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};

              // Get date and time
              String? dateStr = data['date'] as String?;
              String? timeStr = data['time'] as String?;
              DateTime? aptDate;

              // Try to parse date and time
              if (dateStr != null && dateStr.isNotEmpty) {
                try {
                  if (timeStr != null && timeStr.isNotEmpty) {
                    // Parse time (format: "HH:mm")
                    final timeParts = timeStr.split(':');
                    if (timeParts.length == 2) {
                      final hour = int.tryParse(timeParts[0]) ?? 0;
                      final minute = int.tryParse(timeParts[1]) ?? 0;
                      final dateParts = dateStr.split('-');
                      if (dateParts.length == 3) {
                        final year =
                            int.tryParse(dateParts[0]) ?? DateTime.now().year;
                        final month =
                            int.tryParse(dateParts[1]) ?? DateTime.now().month;
                        final day =
                            int.tryParse(dateParts[2]) ?? DateTime.now().day;
                        aptDate = DateTime(year, month, day, hour, minute);
                      }
                    }
                  } else {
                    // Only date, no time
                    aptDate = DateTime.parse(dateStr);
                  }
                } catch (e) {
                  print(
                    '[Doctor Home] Error parsing date/time: date=$dateStr, time=$timeStr, error: $e',
                  );
                }
              }

              // Fallback: try appointmentDate as Timestamp
              if (aptDate == null) {
                aptDate = (data['appointmentDate'] as Timestamp?)?.toDate();
              }

              // Get patient name - check all possible fields
              final patientName =
                  data['patientName'] as String? ??
                  data['patient'] as String? ??
                  data['patientName'] as String? ??
                  'مريض';

              // Debug: Print patient name for each appointment
              print(
                '[Doctor Home] Appointment ${doc.id}: patientName="$patientName", date=$dateStr, time=$timeStr',
              );
              print('[Doctor Home] Full data keys: ${data.keys.toList()}');
              print('[Doctor Home] patientName value: ${data['patientName']}');
              print('[Doctor Home] patient value: ${data['patient']}');

              return {
                'id': doc.id,
                'patient': patientName,
                'time':
                    timeStr ??
                    (aptDate != null ? _formatTime(aptDate) : 'غير متاح'),
                'type':
                    data['type'] ??
                    data['appointmentType'] ??
                    data['status'] ??
                    'موعد',
                'appointmentDate': aptDate,
              };
            })
            .toList();

        // Sort by time
        _todayAppointments.sort((a, b) {
          final dateA = a['appointmentDate'] as DateTime?;
          final dateB = b['appointmentDate'] as DateTime?;
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });

        print(
          '[Doctor Home] Today appointments after filtering: ${_todayAppointments.length}',
        );
      } catch (e) {
        print(
          '[Doctor Home] Error with doctorId, trying alternative fields: $e',
        );
        // Try alternative: get all appointments from web_appointments and filter in code
        try {
          final allAppointments = await FirebaseFirestore.instance
              .collection('web_appointments')
              .get();

          print(
            '[Doctor Home] Total appointments in web_appointments collection: ${allAppointments.docs.length}',
          );

          // Filter by doctorId and date in code
          // Note: web_appointments uses 'date' (String) and 'time' (String) separately
          _todayAppointments = allAppointments.docs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                final docDoctorId =
                    data['doctorId'] ?? data['assignedDoctorId'];
                if (docDoctorId != doctorId) return false;

                // Try to get date from 'date' field (String format: "YYYY-MM-DD")
                String? dateStr = data['date'] as String?;
                if (dateStr == null || dateStr.isEmpty) {
                  // Fallback: try appointmentDate as Timestamp
                  final aptDate = (data['appointmentDate'] as Timestamp?)
                      ?.toDate();
                  if (aptDate != null) {
                    dateStr =
                        '${aptDate.year}-${aptDate.month.toString().padLeft(2, '0')}-${aptDate.day.toString().padLeft(2, '0')}';
                  }
                }

                if (dateStr == null || dateStr.isEmpty) return false;

                // Compare date string with today
                try {
                  final todayStr =
                      '${startOfToday.year}-${startOfToday.month.toString().padLeft(2, '0')}-${startOfToday.day.toString().padLeft(2, '0')}';
                  return dateStr == todayStr;
                } catch (e) {
                  return false;
                }
              })
              .take(5)
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};

                // Get date and time
                String? dateStr = data['date'] as String?;
                String? timeStr = data['time'] as String?;
                DateTime? aptDate;

                // Try to parse date and time
                if (dateStr != null && dateStr.isNotEmpty) {
                  try {
                    if (timeStr != null && timeStr.isNotEmpty) {
                      // Parse time (format: "HH:mm")
                      final timeParts = timeStr.split(':');
                      if (timeParts.length == 2) {
                        final hour = int.tryParse(timeParts[0]) ?? 0;
                        final minute = int.tryParse(timeParts[1]) ?? 0;
                        final dateParts = dateStr.split('-');
                        if (dateParts.length == 3) {
                          final year =
                              int.tryParse(dateParts[0]) ?? DateTime.now().year;
                          final month =
                              int.tryParse(dateParts[1]) ??
                              DateTime.now().month;
                          final day =
                              int.tryParse(dateParts[2]) ?? DateTime.now().day;
                          aptDate = DateTime(year, month, day, hour, minute);
                        }
                      }
                    } else {
                      // Only date, no time
                      aptDate = DateTime.parse(dateStr);
                    }
                  } catch (e) {
                    print(
                      '[Doctor Home] Error parsing date/time in fallback: $e',
                    );
                  }
                }

                // Fallback: try appointmentDate as Timestamp
                if (aptDate == null) {
                  aptDate = (data['appointmentDate'] as Timestamp?)?.toDate();
                }

                // Get patient name - check all possible fields
                final patientName =
                    data['patientName'] as String? ??
                    data['patient'] as String? ??
                    data['patientName'] as String? ??
                    'مريض';

                // Debug: Print patient name for each appointment (fallback method)
                print(
                  '[Doctor Home] Appointment (fallback) ${doc.id}: patientName="$patientName", date=$dateStr, time=$timeStr',
                );
                print('[Doctor Home] Full data keys: ${data.keys.toList()}');
                print(
                  '[Doctor Home] patientName value: ${data['patientName']}',
                );
                print('[Doctor Home] patient value: ${data['patient']}');

                return {
                  'id': doc.id,
                  'patient': patientName,
                  'time':
                      timeStr ??
                      (aptDate != null ? _formatTime(aptDate) : 'غير متاح'),
                  'type':
                      data['type'] ??
                      data['appointmentType'] ??
                      data['status'] ??
                      'موعد',
                  'appointmentDate': aptDate,
                };
              })
              .toList();

          // Sort by time
          _todayAppointments.sort((a, b) {
            final dateA = a['appointmentDate'] as DateTime?;
            final dateB = b['appointmentDate'] as DateTime?;
            if (dateA == null || dateB == null) return 0;
            return dateA.compareTo(dateB);
          });

          print(
            '[Doctor Home] Today appointments (alternative method): ${_todayAppointments.length}',
          );
        } catch (e2) {
          print('[Doctor Home] ERROR loading appointments: $e2');
          _todayAppointments = [];
        }
      }

      if (mounted) {
        setState(() => _isLoadingAppointments = false);
      }
    } catch (e) {
      print('[Doctor Home] ERROR loading today appointments: $e');
      if (mounted) {
        setState(() {
          _todayAppointments = [];
          _isLoadingAppointments = false;
        });
      }
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'ص' : 'م';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPatients(String query) {
    // Search functionality can be implemented here
    // For now, it's a placeholder as the search bar is on the dashboard
    // Actual search should navigate to PatientList with search query
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PatientList()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildDoctorDrawer(context, theme),
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // Shows drawer icon
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(theme),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchBar(theme),
              const SizedBox(height: 24),

              // Statistics Cards
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildStatisticsSection(theme),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(theme),
              const SizedBox(height: 24),

              // Today's Schedule Preview
              _buildTodaySchedule(theme),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildDoctorBottomNavBar(
        context,
        theme,
        currentIndex: 0,
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لوحة التحكم',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _doctorProfile?.name != null
                  ? 'مرحباً بك، ${_doctorProfile!.name}'
                  : 'مرحباً بك',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Refresh button
            IconButton(
              icon: Icon(
                Icons.refresh,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                _loadDashboardData();
              },
              tooltip: 'تحديث البيانات',
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IncomingRequests(),
                      ),
                    );
                  },
                ),
                if (pendingRequests > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        pendingRequests.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.person_outline,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DoctorDetail()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content: const Text(
                      'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('تسجيل الخروج'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await FirebaseServices.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'بحث عن مريض أو نتيجة...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[400],
          ),
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
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات اليوم',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.people,
                title: 'المرضى النشطون',
                value: activePatients.toString(),
                color: const Color(0xFF5B9AA0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.pending_actions,
                title: 'نتائج معلقة',
                value: pendingLabResults.toString(),
                color: const Color(0xFFFFB74D),
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Medications()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF81C784).withOpacity(0.2),
                  const Color(0xFF81C784).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF81C784).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوصفات الطبية الحديثة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF81C784),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'خلال آخر 7 أيام',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  recentPrescriptions.toString(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF81C784),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    final actions = [
      {
        'icon': Icons.edit_note,
        'label': 'وصفة طبية جديدة',
        'color': const Color(0xFF5B9AA0),
        'onTap': () {
          // TODO: Navigate to prescription form
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('قريباً: نموذج الوصفة الطبية')),
          );
        },
      },
      {
        'icon': Icons.science,
        'label': 'مراجعة النتائج',
        'color': const Color(0xFF81C784),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LabResultsReview()),
          );
        },
      },
      {
        'icon': Icons.approval,
        'label': 'طلبات الموافقة',
        'color': const Color(0xFF9575CD),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OverrideRequests()),
          );
        },
      },
      {
        'icon': Icons.add_task,
        'label': 'طلب تحليل جديد',
        'color': const Color(0xFFFFB74D),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LabTestRequest()),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: action['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (action['color'] as Color).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: action['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action['label'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: action['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodaySchedule(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'جدول اليوم',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_todayAppointments.isNotEmpty)
            TextButton(
              onPressed: () {
                  // TODO: Navigate to full schedule page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('صفحة الجدول الكامل قريباً')),
                  );
              },
              child: Text(
                'عرض الكل',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingAppointments)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_todayAppointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد مواعيد لليوم',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._todayAppointments.map(
          (appointment) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          appointment['patient'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                          appointment['type'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      appointment['time'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
