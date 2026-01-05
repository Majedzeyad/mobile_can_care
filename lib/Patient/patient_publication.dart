import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';
import '../services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_common_widgets.dart';

/// Patient Publication Page
///
/// This page displays a feed of healthcare publications, news articles, and
/// educational content for patients. Features include:
/// - Publication feed with articles and posts
/// - Author information with profile images
/// - Publication content with text and images
/// - "Read more" functionality for longer articles
/// - Search functionality to find specific publications
///
/// The page provides patients with access to health education materials, news
/// updates, and community publications to help them stay informed about healthcare topics.
class PatientPublication extends StatefulWidget {
  const PatientPublication({super.key});

  @override
  State<PatientPublication> createState() => _PatientPublicationState();
}

/// State class for Patient Publication Page
///
/// Manages:
/// - Current navigation index
/// - Search controller for filtering publications
/// - List of publications with author and content information
/// - UI state and interactions
class _PatientPublicationState extends State<PatientPublication> {
  /// Current navigation index (0 for publications page)
  int _currentIndex = 0;

  /// Controller for the search text field to filter publications
  final TextEditingController _searchController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Publication
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores publications/posts from Firebase 'web_posts' collection.
  // To modify the data source:
  // - Change query filters in the _loadPublications() method
  // - Update the data mapping if post structure changes
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Publications from Firebase
  List<Map<String, dynamic>> _allPublications = [];
  List<Map<String, dynamic>> _publications = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPublications();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads publications from Firebase 'web_posts' collection.
  // The web app uses 'web_posts' for publications, so we align with that structure.
  //
  // To modify:
  // - Change the query filters (orderBy, where, limit)
  // - Update the data mapping if post structure changes
  // - Add filtering by category or author if needed
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadPublications() async {
    try {
      setState(() => _isLoading = true);

      // Load publications from 'web_posts' collection (aligned with web app)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('web_posts')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      _allPublications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'author': data['authorName'] ?? data['author'] ?? 'Admin',
          'authorImage': data['authorImage'] ?? '',
          'content': data['content'] ?? data['text'] ?? '',
          'image': data['imageUrl'] ?? data['image'] ?? '',
          'hasMore': (data['content'] ?? '').length > 100,
          'createdAt': data['createdAt'],
        };
      }).toList();

      _publications = _allPublications;

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[PatientPublication] Error loading publications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المنشورات: $e')));
      }
    }
  }

  // void _searchPublications(String query) {
  //   if (query.isEmpty) {
  //     setState(() {
  //       _publications = _allPublications;
  //     });
  //     return;
  //   }
  //
  //   setState(() {
  //     _publications = _allPublications.where((pub) {
  //       final content = (pub['content'] ?? '').toLowerCase();
  //       final author = (pub['author'] ?? '').toLowerCase();
  //       return content.contains(query.toLowerCase()) ||
  //           author.contains(query.toLowerCase());
  //     }).toList();
  //   });
  // }

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the patient publication feed UI with articles and content.
  ///
  /// Creates an interface displaying:
  /// - Status bar simulation at the top
  /// - Header with page title, back button, menu, and search functionality
  /// - Publication feed with scrollable list of articles
  /// - Publication cards showing author, content, and images
  /// - "Read more" buttons for expandable content
  /// - Search functionality to filter publications
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient publication feed UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildPatientDrawer(context, theme),
      bottomNavigationBar: buildPatientBottomNavBar(
        context,
        theme,
        currentIndex: 1, // المنشورات
      ),
      body: SafeArea(
        child: Column(
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
                      Icons.search,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // Search functionality is handled by _searchPublications
                    },
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _publications.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد منشورات',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
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
}
