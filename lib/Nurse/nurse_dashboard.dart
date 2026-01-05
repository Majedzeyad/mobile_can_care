import 'package:flutter/material.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_patient_management.dart';
import 'nurse_profile.dart';
import 'nurse_posts.dart';
import 'nurse_group_chats_list.dart';
import 'nurse_common_widgets.dart';
import '../services/firebase_services.dart';

/// Nurse Dashboard Page - لوحة تحكم الممرض/ة
///
/// تصميم منظم وسهل الاستخدام للممرضين يركز على:
/// - عرض المهام اليومية بشكل واضح ومنظم
/// - سهولة الوصول للمرضى والأدوية
/// - تنظيم الجدول الزمني بشكل بصري
/// - ألوان هادئة واحترافية
/// - إجراءات سريعة للمهام المتكررة
class NurseDashboard extends StatefulWidget {
  const NurseDashboard({super.key});

  @override
  State<NurseDashboard> createState() => _NurseDashboardState();
}

class _NurseDashboardState extends State<NurseDashboard> {
  // Firebase Integration
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  
  String _nurseName = 'ممرض/ة';
  bool _isLoading = true;
  List<Map<String, dynamic>> _todayTasks = [];
  List<Map<String, dynamic>> _quickStats = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      final currentUserId = _firebaseServices.currentUserId;
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      // Get nurse profile
      final nurseProfile = await _firebaseServices.getNurseProfile();
      if (nurseProfile != null && mounted) {
        setState(() {
          _nurseName = nurseProfile.name ?? 'ممرض/ة';
        });
      }

      // Get today's appointments (tasks)
      final appointments = await _firebaseServices.getNurseAppointments();
      final today = DateTime.now();
      final todayAppointments = appointments.where((apt) {
        final aptDate = apt['date'] as DateTime?;
        return aptDate != null &&
            aptDate.year == today.year &&
            aptDate.month == today.month &&
            aptDate.day == today.day;
      }).toList();

      // Get assigned patients count
      final patients = await _firebaseServices.getNursePatients();
      
      // Get pending medications count
      final medications = await _firebaseServices.getNurseMedications();
      final pendingMeds = medications.where((med) => 
        med['status'] == 'pending' || med['status'] == 'upcoming'
      ).length;

      if (mounted) {
        setState(() {
          _todayTasks = todayAppointments.map((apt) => {
            'patient': apt['patientName'] ?? 'مريض',
            'task': apt['reason'] ?? 'موعد',
            'time': apt['time'] ?? '',
            'room': apt['room'] ?? '',
            'priority': 'عادية',
            'completed': false,
          }).toList();

          _quickStats = [
            {'label': 'المرضى المعينين', 'value': '${patients.length}', 'icon': Icons.people},
            {'label': 'الأدوية المعلقة', 'value': '$pendingMeds', 'icon': Icons.medication},
            {'label': 'مواعيد اليوم', 'value': '${todayAppointments.length}', 'icon': Icons.calendar_today},
          ];
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Nurse Dashboard] Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildNurseDrawer(context, theme),
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // Shows drawer icon
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(theme),
                    const SizedBox(height: 24),

                    // Quick Overview Stats
                    _buildQuickOverview(theme),
                    const SizedBox(height: 24),

                    // Today's Tasks Section
                    _buildTodayTasks(theme),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(theme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: buildNurseBottomNavBar(
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
              'مرحباً بك، $_nurseName',
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
                    // TODO: Show notifications
                  },
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
                  MaterialPageRoute(builder: (context) => const NurseProfile()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickOverview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نظرة سريعة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: _quickStats.map((stat) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stat['value'] as String,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTodayTasks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'مهام اليوم',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'السبت، 15 فبراير',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._todayTasks.map((task) {
          Color priorityColor;
          switch (task['priority']) {
            case 'عاجلة':
              priorityColor = const Color(0xFFEF5350);
              break;
            case 'عالية':
              priorityColor = const Color(0xFFFFB74D);
              break;
            default:
              priorityColor = const Color(0xFF81C784);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task['completed']
                    ? theme.colorScheme.secondary.withOpacity(0.3)
                    : priorityColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: task['completed']
                      ? theme.colorScheme.secondary.withOpacity(0.2)
                      : priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  task['completed'] ? Icons.check_circle : Icons.person,
                  color: task['completed']
                      ? theme.colorScheme.secondary
                      : priorityColor,
                  size: 32,
                ),
              ),
              title: Text(
                task['patient'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration:
                      task['completed'] ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    task['task'],
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task['time'],
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.room,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task['room'],
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task['priority'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Checkbox(
                    value: task['completed'],
                    onChanged: (value) {
                      setState(() {
                        task['completed'] = value;
                      });
                      // TODO: Backend Integration - Update task status
                    },
                    activeColor: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {
        'icon': Icons.people,
        'label': 'إدارة المرضى',
        'color': const Color(0xFF9575CD),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NursePatientManagement(),
            ),
          );
        },
      },
      {
        'icon': Icons.medication,
        'label': 'الأدوية',
        'color': const Color(0xFF81C784),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NurseMedicationManagement(),
            ),
          );
        },
      },
      {
        'icon': Icons.calendar_today,
        'label': 'المواعيد',
        'color': const Color(0xFF5B9AA0),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NurseAppointmentManagement(),
            ),
          );
        },
      },
      {
        'icon': Icons.article,
        'label': 'المنشورات',
        'color': const Color(0xFFFFB74D),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NursePosts(),
            ),
          );
        },
      },
      {
        'icon': Icons.chat,
        'label': 'المحادثات',
        'color': const Color(0xFF5B9AA0),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NurseGroupChatsList(),
            ),
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

}
