import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nurse_dashboard.dart';
import 'nurse_appointment_management.dart';
import 'nurse_medication_management.dart';
import 'nurse_patient_management.dart';
import 'nurse_profile.dart';

/// Nurse Publication Page
///
/// This page displays a feed of healthcare publications, news articles, and
/// professional content for nurses. Features include:
/// - Publication feed with articles and posts from healthcare professionals
/// - Author information with profile images
/// - Publication content with text and images
/// - "Read more" functionality for longer articles
/// - Bottom navigation to access other nurse-related pages
///
/// The page provides nurses with access to professional development materials,
/// healthcare news, and community publications relevant to nursing practice.
class NursePublication extends StatefulWidget {
  const NursePublication({super.key});

  @override
  State<NursePublication> createState() => _NursePublicationState();
}

/// State class for Nurse Publication Page
///
/// Manages:
/// - Current bottom navigation tab index
/// - List of publications with author and content information
/// - UI state and interactions
class _NursePublicationState extends State<NursePublication> {
  int _currentIndex = 0;

  // Firebase Integration
  bool _isLoading = true;
  List<Map<String, dynamic>> _publications = [];

  @override
  void initState() {
    super.initState();
    _loadPublications();
  }

  Future<void> _loadPublications() async {
    try {
      setState(() => _isLoading = true);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('web_posts')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      if (mounted) {
        setState(() {
          _publications = querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'author': data['authorName'] ?? 'Admin',
              'authorImage': '',
              'content': data['content'] ?? '',
              'image': data['imageUrl'] ?? '',
              'hasMore': (data['content'] ?? '').length > 100,
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Nurse Publication] Error loading publications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Builds the nurse publication feed UI with articles and content.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title, back button, and menu
  /// - Publication feed with scrollable list of articles
  /// - Publication cards showing author, content, and images
  /// - "Read more" buttons for expandable content
  /// - Bottom navigation bar for accessing other nurse pages
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete nurse publication feed UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
            // Status bar
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_4_bar,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.battery_full,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                      'المنشورات',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Backend Integration - Add new publication
                    },
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _publications.length,
                itemBuilder: (context, index) {
                  return _buildPublicationCard(_publications[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildPublicationCard(Map<String, dynamic> publication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    publication['authorImage'] != null &&
                            publication['authorImage'].isNotEmpty
                        ? NetworkImage(publication['authorImage'])
                        : null,
                child:
                    publication['authorImage'] == null ||
                            publication['authorImage'].isEmpty
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
              ),
              const SizedBox(width: 12),
              Text(
                publication['author'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            publication['content'],
            style: const TextStyle(fontSize: 14),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (publication['hasMore'])
            GestureDetector(
              onTap: () {
                // todo: Show full content
              },
              child: const Text(
                'See more',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B46C1)),
              ),
            ),
          const SizedBox(height: 12),
          // Image
          if (publication['image'] != null && publication['image'].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                publication['image'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        // Navigate to different pages based on index
        Widget? destination;
        switch (index) {
          case 0:
            destination = const NurseDashboard();
            break;
          case 1:
            destination = const NurseAppointmentManagement();
            break;
          case 2:
            destination = const NurseMedicationManagement();
            break;
          case 3:
            // Already on Message/Publication page
            return;
          case 4:
            destination = const NursePatientManagement();
            break;
          case 5:
            destination = const NurseProfile(); // Account/Profile
            break;
        }

        if (destination != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination!),
          );
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        inherit: true,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        inherit: true,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'المواعيد',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'الأدوية',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'الرسائل'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المرضى'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
      ],
    );
  }
}
