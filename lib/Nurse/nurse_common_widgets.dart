import 'package:flutter/material.dart';
import 'nurse_dashboard.dart';
import 'nurse_patient_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_appointment_management.dart';
import 'nurse_profile.dart';
import 'nurse_posts.dart';
import 'nurse_group_chats_list.dart';
import '../services/firebase_services.dart';
import '../pages/login_page.dart';

/// Common widgets for Nurse pages
/// Contains Drawer and BottomNavigationBar that can be reused across all Nurse pages

/// Build bottom navigation bar for Nurse pages
Widget buildNurseBottomNavBar(
  BuildContext context,
  ThemeData theme, {
  required int currentIndex,
}) {
  final pages = [
    {'route': const NurseDashboard(), 'icon': Icons.home, 'label': 'الرئيسية'},
    {'route': const NursePatientManagement(), 'icon': Icons.people, 'label': 'المرضى'},
    {
      'route': const NurseMedicationManagement(),
      'icon': Icons.medication,
      'label': 'الأدوية',
    },
    {'route': const NurseAppointmentManagement(), 'icon': Icons.calendar_today, 'label': 'المواعيد'},
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

/// Build drawer for Nurse pages
Widget buildNurseDrawer(BuildContext context, ThemeData theme) {
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
                    print('[NurseDrawer] Error loading image: $error');
                    print('[NurseDrawer] StackTrace: $stackTrace');
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
                        'لوحة تحكم الممرض/ة',
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
                      MaterialPageRoute(builder: (_) => const NurseDashboard()),
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
                      MaterialPageRoute(builder: (_) => const NursePatientManagement()),
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
                      MaterialPageRoute(builder: (_) => const NurseMedicationManagement()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.calendar_today,
                  title: 'المواعيد',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NurseAppointmentManagement()),
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
                      MaterialPageRoute(builder: (_) => const NursePosts()),
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
                      MaterialPageRoute(builder: (_) => const NurseGroupChatsList()),
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
                      MaterialPageRoute(builder: (_) => const NurseProfile()),
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

