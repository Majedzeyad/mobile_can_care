import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_services.dart';
import 'doctor_common_widgets.dart';

/// Medical Records Page (UI Layer)
///
/// This page displays all medical records for the current doctor.
/// Features:
/// - List of medical records organized by category
/// - Search functionality to filter records
/// - View record details
class MedicalRecords extends StatefulWidget {
  const MedicalRecords({super.key});

  @override
  State<MedicalRecords> createState() => _MedicalRecordsState();
}

/// State class for Medical Records Page
class _MedicalRecordsState extends State<MedicalRecords> {
  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // Current page index for bottom navigation (3 = Medical Records)
  static const int pageIndex = 3;

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Medical Records
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores medical records created by the current doctor.
  // To modify the data source:
  // 1. Change the query in FirebaseServices.getDoctorMedicalRecords()
  // 2. Update field mappings in _loadMedicalRecords()
  // 3. Modify MedicalRecordModel if new fields are needed
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Complete list of all medical records (unfiltered)
  List<Map<String, dynamic>> _records = [];

  /// Filtered list of records based on search query
  List<Map<String, dynamic>> _filteredRecords = [];

  // Loading state
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load medical records from Firebase
    _loadMedicalRecords();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads medical records from Firebase.
  //
  // To modify:
  // - Change query filters: modify FirebaseServices.getDoctorMedicalRecords()
  // - Add patient filter: filter by specific patientId if needed
  // - Add category filter: filter by category type
  // - Add pagination: use startAfterDocument() for infinite scroll
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadMedicalRecords() async {
    try {
      setState(() => _isLoading = true);

      // Load medical records from Firebase
      // This queries the 'mobile_medical_records' collection filtered by doctorId
      // Note: doctorId should match doctors.uid (not document ID)
      // This is a mobile-specific collection (not in web app)
      // Structure:
      // - doctorId: Doctor's UID
      // - patientId: Patient document ID
      // - category: Record category
      // - description: Record description
      // - createdAt: Timestamp
      final records = await _firebaseServices.getDoctorMedicalRecords();

      print('[Medical Records] Loaded ${records.length} records from Firebase');

      // Get patient names for all records
      final Set<String> patientIds = records
          .map((r) => r['patientId'] as String?)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();

      // Create a map of patientId -> patientName
      final Map<String, String> patientIdToName = {};
      for (final patientId in patientIds) {
        try {
          final patientDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .get();
          if (patientDoc.exists) {
            final patientName = patientDoc.data()?['name'] as String?;
            if (patientName != null) {
              patientIdToName[patientId] = patientName;
            }
          }
        } catch (e) {
          print(
            '[Medical Records] Error fetching patient name for $patientId: $e',
          );
        }
      }

      if (mounted) {
        setState(() {
          _records = records.map((record) {
            // Format date if available
            String formattedDate = 'غير متوفر';
            final createdAt = record['createdAt'] as DateTime?;
            if (createdAt != null) {
              formattedDate =
                  '${createdAt.day}/${createdAt.month}/${createdAt.year}';
            }

            // Get patient name
            final patientId = record['patientId'] as String?;
            final patientName = patientId != null && patientId.isNotEmpty
                ? (patientIdToName[patientId] ?? 'غير معروف')
                : 'غير معروف';

            return {
              'id': record['id'] ?? '',
              'category': record['category'] ?? 'غير محدد',
              'description': record['description'] ?? 'لا يوجد وصف',
              'date': formattedDate,
              'patientName': patientName,
              'patientId': patientId,
              'createdAt': createdAt,
            };
          }).toList();
    _filteredRecords = _records;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Medical Records] Error loading records: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل السجلات: $e')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get appropriate icon for a medical record category
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'تشخيص':
      case 'diagnosis':
        return Icons.medical_information;
      case 'علاج':
      case 'treatment':
        return Icons.medication;
      case 'جراحة':
      case 'surgery':
        return Icons.healing;
      case 'متابعة':
      case 'follow-up':
      case 'followup':
        return Icons.update;
      default:
        return Icons.folder;
    }
  }

  /// Get category color
  Color _getCategoryColor(String category, ThemeData theme) {
    switch (category.toLowerCase()) {
      case 'تشخيص':
      case 'diagnosis':
        return theme.colorScheme.primary;
      case 'علاج':
      case 'treatment':
        return theme.colorScheme.secondary;
      case 'جراحة':
      case 'surgery':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
      }
    }

  /// Handle search input and filter the medical records list
  void _searchRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _records;
      } else {
        _filteredRecords = _records.where((record) {
          final category = (record['category'] ?? '').toString().toLowerCase();
          final description = (record['description'] ?? '')
              .toString()
              .toLowerCase();
          final patientName = (record['patientName'] ?? '')
              .toString()
              .toLowerCase();
          final searchLower = query.toLowerCase();
          return category.contains(searchLower) ||
              description.contains(searchLower) ||
              patientName.contains(searchLower);
        }).toList();
      }
    });
  }

  /// Navigate to medical record details page
  void _viewRecordDetails(Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(record['category'], theme);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForCategory(record['category']),
                color: categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                record['category'] ?? 'سجل طبي',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('المريض', record['patientName'] ?? 'غير معروف'),
              _buildDetailRow('التاريخ', record['date'] ?? 'غير متوفر'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'الوصف:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                record['description'] ?? 'لا يوجد وصف',
                style: theme.textTheme.bodyMedium,
              ),
          ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildDoctorDrawer(context, theme),
      appBar: AppBar(
        title: const Text('السجلات الطبية'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
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
                        onChanged: _searchRecords,
                  style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                    hintText: 'ابحث في السجلات الطبية...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
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
                      vertical: 14,
                        ),
                      ),
                    ),
                  ),
            ),
            
            const SizedBox(height: 16),
            
            // Records count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'إجمالي السجلات: ${_filteredRecords.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Records list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد سجلات',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMedicalRecords,
                      child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                          final categoryColor = _getCategoryColor(
                            record['category'],
                            theme,
                          );
                        
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.3),
                              width: 1,
                            ),
                      boxShadow: [
                        BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _viewRecordDetails(record),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                                    // Category icon
                        Container(
                                      width: 56,
                                      height: 56,
                          decoration: BoxDecoration(
                                        color: categoryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                          ),
                          child: Icon(
                                          _getIconForCategory(
                                            record['category'],
                                          ),
                                        color: categoryColor,
                                        size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                                    
                                    // Record info
                        Expanded(
                          child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                            children: [
                                          Row(
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: categoryColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                ),
                                                child: Text(
                                                  record['category'],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                    color: categoryColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                              Text(
                                            record['description'],
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                            'المريض: ${record['patientName']}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            record['date'] ?? '',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // View button
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        ),
                    ),
                  );
                },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildDoctorBottomNavBar(context, theme, currentIndex: pageIndex),
    );
  }
}
