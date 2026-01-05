import 'package:flutter/material.dart';
import 'home.dart';
import 'patient_list.dart';
import 'lab_results_review.dart';
import 'medical_records.dart';
import 'medications.dart';
import 'lab_test_request.dart';
import 'override_requests.dart';
import 'incoming_requests.dart';
import 'doctor_detail.dart';
import 'posts.dart';
import 'group_chats_list.dart';
import '../services/firebase_services.dart';
import '../pages/login_page.dart';

/// Common widgets for Doctor pages
/// Contains Drawer and BottomNavigationBar that can be reused across all Doctor pages

/// Build bottom navigation bar for Doctor pages
Widget buildDoctorBottomNavBar(
  BuildContext context,
  ThemeData theme, {
  required int currentIndex,
}) {
  final pages = [
    {'route': const Dashdoctor(), 'icon': Icons.home, 'label': 'الرئيسية'},
    {'route': const PatientList(), 'icon': Icons.people, 'label': 'المرضى'},
    {
      'route': const LabResultsReview(),
      'icon': Icons.science,
      'label': 'التحاليل',
    },
    {'route': const MedicalRecords(), 'icon': Icons.folder, 'label': 'السجلات'},
  ];

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(pages.length, (index) {
            final page = pages[index];
            final isSelected = index == currentIndex;
            return _buildNavItem(
              theme,
              icon: page['icon'] as IconData,
              label: page['label'] as String,
              isSelected: isSelected,
              onTap: () {
                if (!isSelected) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => page['route'] as Widget),
                  );
                }
              },
            );
          }),
        ),
      ),
    ),
  );
}

Widget _buildNavItem(
  ThemeData theme, {
  required IconData icon,
  required String label,
  bool isSelected = false,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Build drawer for Doctor pages
Widget buildDoctorDrawer(BuildContext context, ThemeData theme) {
  final firebaseServices = FirebaseServices.instance;

  return Drawer(
    child: SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/cancare_logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  cacheWidth: 80,
                  cacheHeight: 80,
                  errorBuilder: (context, error, stackTrace) {
                    print('[DoctorDrawer] Error loading image: $error');
                    print('[DoctorDrawer] StackTrace: $stackTrace');
                    // Fallback to icon if image not found
                    return Icon(
                      Icons.health_and_safety_rounded,
                      size: 40,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CanCare',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'لوحة تحكم الطبيب',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.home,
                  title: 'الرئيسية',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Dashdoctor()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.people,
                  title: 'المرضى',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientList()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.science,
                  title: 'التحاليل',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LabResultsReview(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.folder,
                  title: 'السجلات الطبية',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MedicalRecords()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.medication,
                  title: 'الأدوية',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Medications()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.add_task,
                  title: 'طلب تحليل جديد',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LabTestRequest()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.approval,
                  title: 'طلبات الموافقة',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OverrideRequests(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.swap_horiz,
                  title: 'طلبات النقل',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncomingRequests(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.article,
                  title: 'المنشورات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Posts()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.chat,
                  title: 'المحادثات الجماعية',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GroupChatsList()),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.person,
                  title: 'الملف الشخصي',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorDetail()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  onTap: () async {
                    Navigator.pop(context);
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
                    if (confirm == true && context.mounted) {
                      await firebaseServices.signOut();
                      if (context.mounted) {
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
          ),
        ],
      ),
    ),
  );
}

Widget _buildDrawerItem(
  BuildContext context,
  ThemeData theme, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: theme.colorScheme.primary),
    title: Text(title, style: theme.textTheme.bodyLarge),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
  );
}
