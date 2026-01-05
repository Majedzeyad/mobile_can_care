import 'package:flutter/material.dart';
import 'patient_transportation.dart';
import 'patient_appointment_management.dart';
import 'patient_profile.dart';
import 'patient_publication.dart';
import 'patient_medication_management.dart';
import 'patient_lab_results_review.dart';
import '../services/firebase_services.dart';
import '../models/patient_model.dart';
import 'patient_common_widgets.dart';

/// Patient Dashboard Page - واجهة المريض الرئيسية
///
/// تم تصميم هذه الواجهة خصيصاً لتكون مريحة نفسياً وبصرياً لمرضى السرطان:
/// - ألوان هادئة ومطمئنة (أخضر ناعم، أزرق فيروزي)
/// - خطوط كبيرة وواضحة لسهولة القراءة
/// - أزرار كبيرة سهلة الضغط
/// - مساحات بيضاء واسعة لتقليل الإرهاق البصري
/// - ترتيب أولوي: الأهم في الأعلى (المواعيد، الأدوية، التذكيرات)
/// - أيقونات بديهية وواضحة
/// - زر SOS واضح للحالات الطارئة
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Dashboard
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores patient profile, appointments, and medications from Firebase.
  // To modify the data source:
  // - Change query filters in FirebaseServices.getPatientProfile()
  // - Update appointment fetching in FirebaseServices.getPatientAppointments()
  // - Adjust medication fetching in FirebaseServices.getPatientActivePrescriptions()
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Patient profile
  PatientModel? _patientProfile;

  // Loading state
  bool _isLoading = true;

  // Calendar state (not used in current implementation but kept for future use)
  // final List<int> _highlightedDates = [];
  // int _selectedDate = DateTime.now().day;

  // Upcoming appointments from Firebase
  List<Map<String, dynamic>> _upcomingAppointments = [];

  // Medications from Firebase
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads dashboard data from Firebase:
  // - Patient profile (name, etc.)
  // - Upcoming appointments
  // - Active medications
  //
  // To modify:
  // - Change the query filters in FirebaseServices methods
  // - Add new data sources by extending this method
  // - Update the data mapping if model structures change
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // Load patient profile
      _patientProfile = await _firebaseServices.getPatientProfile();

      // Load upcoming appointments
      final appointments = await _firebaseServices.getPatientAppointments();
      final now = DateTime.now();
      _upcomingAppointments = appointments
          .where((apt) {
            final aptDate = (apt['appointmentDate'] as dynamic)?.toDate();
            if (aptDate == null) return false;
            return aptDate.isAfter(now) || aptDate.isAtSameMomentAs(now);
          })
          .take(2)
          .map((apt) {
            final aptDate = (apt['appointmentDate'] as dynamic)?.toDate();
            final isToday =
                aptDate != null &&
                aptDate.year == now.year &&
                aptDate.month == now.month &&
                aptDate.day == now.day;
            final isTomorrow =
                aptDate != null &&
                aptDate.year == now.year &&
                aptDate.month == now.month &&
                aptDate.day == now.day + 1;

            String dateText =
                '${aptDate?.day}/${aptDate?.month}/${aptDate?.year}';
            if (isToday) dateText = 'اليوم';
            if (isTomorrow) dateText = 'غداً';

            return {
              'title': apt['type'] ?? 'موعد',
              'time': apt['appointmentTime'] ?? '10:00 صباحاً',
              'date': dateText,
              'type': apt['type'] ?? 'فحص',
            };
          })
          .toList();

      // Load active medications
      final prescriptions = await _firebaseServices
          .getPatientActivePrescriptions();
      _medications = prescriptions.take(2).map((prescription) {
        return {
          'name': prescription.medicationName ?? 'دواء',
          'dosage': prescription.dosage ?? 'جرعة',
          'taken': false, // This should be tracked separately
          'time': prescription.frequency ?? '10:00 ص',
        };
      }).toList();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[PatientDashboard] Error loading dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildPatientDrawer(context, theme),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section - Simple and Welcoming
              _buildHeader(theme),
              const SizedBox(height: 32),

              // Welcome Message - Large and Comforting
              _buildWelcomeSection(theme),
              const SizedBox(height: 32),

              // Today's Date - Clear and Prominent
              _buildDateSection(theme),
              const SizedBox(height: 24),

              // Loading indicator
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // Priority Section 1: Upcoming Appointments
                _buildUpcomingAppointments(theme),
                const SizedBox(height: 24),

                // Priority Section 2: Medication Reminders
                _buildMedicationReminders(theme),
                const SizedBox(height: 24),
              ],

              // Quick Actions Grid - Large, Easy to Tap
              _buildQuickActionsGrid(theme),
              const SizedBox(height: 32),

              // Emergency SOS Button - Always Visible
              _buildSOSButton(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildPatientBottomNavBar(
        context,
        theme,
        currentIndex: 0, // الرئيسية
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'الرئيسية',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                _loadDashboardData();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بعودتك 👋',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _patientProfile?.name ?? 'المريض',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'نتمنى لك يوماً مليئاً بالصحة والعافية',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(DateTime.now()),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'اليوم لديك ${_upcomingAppointments.length} موعد',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_note, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'المواعيد القادمة',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._upcomingAppointments.map(
          (appointment) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medical_services,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['title'],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${appointment['time']} - ${appointment['date']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientAppointmentManagement(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'عرض جميع المواعيد',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationReminders(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medication, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'تذكير الأدوية',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._medications.map(
          (med) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: med['taken']
                  ? theme.colorScheme.secondary.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: med['taken']
                    ? theme.colorScheme.secondary.withOpacity(0.3)
                    : theme.colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: med['taken']
                        ? theme.colorScheme.secondary.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    med['taken'] ? Icons.check_circle : Icons.medication_liquid,
                    color: med['taken']
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med['name'],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: med['taken']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        med['dosage'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: med['taken'],
                  onChanged: (value) {
                    setState(() {
                      med['taken'] = value;
                    });
                    // TODO: Backend Integration - Update medication status
                  },
                  activeColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(ThemeData theme) {
    final actions = [
      {
        'icon': Icons.medical_information,
        'label': 'السجل الطبي',
        'color': const Color(0xFF5B9AA0),
        'route': null, // TODO: Add route
      },
      {
        'icon': Icons.science,
        'label': 'نتائج المختبر',
        'color': const Color(0xFF81C784),
        'route': PatientLabResultsReview(),
      },
      {
        'icon': Icons.local_taxi,
        'label': 'طلب نقل',
        'color': const Color(0xFF9575CD),
        'route': PatientTransportation(),
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'الرسائل',
        'color': const Color(0xFFFFB74D),
        'route': PatientPublication(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات السريعة',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () {
                if (action['route'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => action['route'] as Widget,
                    ),
                  );
                } else {
                  // TODO: Show coming soon message
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (action['color'] as Color).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: action['color'] as Color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action['label'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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

  Widget _buildSOSButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFE57373)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF5350).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Backend Integration - Trigger emergency alert
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تنبيه طوارئ'),
                content: const Text('هل تريد حقاً إرسال نداء طوارئ؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Send SOS
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF5350),
                    ),
                    child: const Text('نعم، أرسل'),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Icon(Icons.emergency, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  'SOS - طوارئ',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'للحالات الطارئة فقط',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${weekdays[date.weekday % 7]}، ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
