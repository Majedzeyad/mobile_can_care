import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_medication_management.dart';
import 'patient_medical_record.dart';
import 'patient_profile.dart';

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

  // TODO: Connect Firebase - Fetch from 'publications' collection
  /// List of publications/articles in the feed
  /// Each publication contains: author, authorImage (Firebase Storage URL),
  /// content (article text), image (publication image URL), hasMore (boolean for expandable content)
  /// Currently using dummy data, should be fetched from Firebase in production
  final List<Map<String, dynamic>> _publications = [
    {
      'author': 'Admin',
      'authorImage': '', // todo: Load from Firebase Storage
      'content':
          'At Group, we take great pride in fostering a culture that values and celebrates accomplishments...',
      'image': '', // todo: Load from Firebase Storage
      'hasMore': true,
    },
    {
      'author': 'ABC Product',
      'authorImage': '', // todo: Load from Firebase Storage
      'content':
          'To collaborate effectively with colleagues, it\'s essential to establish clear and open lines of...',
      'image': '', // todo: Load from Firebase Storage
      'hasMore': true,
    },
  ];

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
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Publication',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF6B46C1)),
                    onPressed: () {
                      // todo: Implement search functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF6B46C1)),
                    onPressed: () {},
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
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildBottomNavigationBar() {
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
            destination = const PatientDashboard();
            break;
          case 1:
            destination = const PatientMedicationManagement();
            break;
          case 2:
            // Already on Message/Publication page
            return;
          case 3:
            destination = const PatientMedicalRecord(); // Record page
            break;
          case 4:
            destination = const PatientProfile();
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
      selectedItemColor: const Color(0xFF6B46C1),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Record'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
