import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medical_record.dart';
import 'patient_appointment_management.dart';
import 'patient_medication_management.dart';
import 'patient_lab_results_review.dart';
import 'patient_transportation.dart';
import 'patient_profile.dart';
import 'patient_posts.dart';
import 'patient_group_chats_list.dart';
import '../services/firebase_services.dart';
import '../pages/login_page.dart';

/// Common widgets for Patient pages
/// Contains Drawer and BottomNavigationBar that can be reused across all Patient pages

/// Build drawer for Patient pages
Widget buildPatientDrawer(BuildContext context, ThemeData theme) {
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
                  errorBuilder: (context, error, stackTrace) {
                    print('[PatientDrawer] Error loading image: $error');
                    print('[PatientDrawer] StackTrace: $stackTrace');
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
                        'لوحة تحكم المريض',
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
                      MaterialPageRoute(
                        builder: (_) => const PatientDashboard(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.medical_information,
                  title: 'السجل الطبي',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientMedicalRecord(),
                      ),
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
                      MaterialPageRoute(
                        builder: (_) => const PatientAppointmentManagement(),
                      ),
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
                      MaterialPageRoute(
                        builder: (_) => const PatientMedicationManagement(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.science,
                  title: 'نتائج المختبر',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientLabResultsReview(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  icon: Icons.local_taxi,
                  title: 'طلب نقل',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientTransportation(),
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
                      MaterialPageRoute(builder: (_) => const PatientPosts()),
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
                      MaterialPageRoute(
                        builder: (_) => const PatientGroupChatsList(),
                      ),
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
                      MaterialPageRoute(builder: (_) => const PatientProfile()),
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

/// Build bottom navigation bar for Patient pages
Widget buildPatientBottomNavBar(
  BuildContext context,
  ThemeData theme, {
  required int currentIndex,
}) {
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
          children: [
            _buildNavItem(
              theme,
              icon: Icons.home,
              label: 'الرئيسية',
              isSelected: currentIndex == 0,
              onTap: () {
                if (currentIndex != 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientDashboard()),
                  );
                }
              },
            ),
            _buildNavItem(
              theme,
              icon: Icons.article,
              label: 'المنشورات',
              isSelected: currentIndex == 1,
              onTap: () {
                if (currentIndex != 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientPosts()),
                  );
                }
              },
            ),
            _buildNavItem(
              theme,
              icon: Icons.chat,
              label: 'المحادثات',
              isSelected: currentIndex == 2,
              onTap: () {
                if (currentIndex != 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientGroupChatsList(),
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              theme,
              icon: Icons.person,
              label: 'الملف',
              isSelected: currentIndex == 3,
              onTap: () {
                if (currentIndex != 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientProfile()),
                  );
                }
              },
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            size: 28,
            color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
