import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_services.dart';
import '../models/lab_result_model.dart';
import 'doctor_common_widgets.dart';

/// Lab Results Review Page (UI Layer)
///
/// This page allows doctors to:
/// - View all lab results for a patient
/// - Add notes to pending lab results
/// - View details of completed lab results
class LabResultsReview extends StatefulWidget {
  const LabResultsReview({super.key});

  @override
  State<LabResultsReview> createState() => _LabResultsReviewState();
}

/// State class for Lab Results Review Page
class _LabResultsReviewState extends State<LabResultsReview> {
  // Current page index for bottom navigation (2 = Lab Results)
  static const int pageIndex = 2;

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Lab Results Review
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores lab results for review by the doctor.
  // To modify the data source:
  // 1. Change the query in FirebaseServices (add method for doctor's lab results)
  // 2. Update field mappings in _loadLabResults()
  // 3. Modify LabResultModel if new fields are needed
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// List of all lab results (loaded from Firebase)
  List<Map<String, dynamic>> _labResults = [];

  // Loading state
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load lab results from Firebase
    _loadLabResults();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads lab results from Firebase.
  //
  // To modify:
  // - Change query: query 'mobile_lab_results' collection filtered by doctorId
  // - Add patient filter: filter by specific patientId if needed
  // - Add sorting: order by createdAt descending
  // - Add pagination: use startAfterDocument() for infinite scroll
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadLabResults() async {
    try {
      setState(() => _isLoading = true);

      print('[Lab Results Review] Loading lab results...');
      final doctorId = _firebaseServices.currentUserId;
      if (doctorId == null) {
        print('[Lab Results Review] No doctor ID found');
        if (mounted) {
          setState(() {
            _labResults = [];
            _isLoading = false;
          });
        }
        return;
      }

      // ═══════════════════════════════════════════════════════════════════════
      // FIREBASE QUERY - Lab Results for Doctor
      // ═══════════════════════════════════════════════════════════════════════
      // Strategy: Get lab results through lab test requests
      // 1. Get all lab test requests for this doctor from 'mobile_lab_test_requests'
      // 2. Get requestIds from those requests
      // 3. Query 'mobile_lab_results' where requestId matches
      //
      // Alternative: Get all patients for doctor, then get their lab results
      // This approach is simpler and more efficient
      // ═══════════════════════════════════════════════════════════════════════

      // Use the new method that filters by doctorId directly
      // This is more efficient and ensures all results belong to the doctor
      final allResults = await _firebaseServices.getDoctorLabResults(doctorId);

      print(
        '[Lab Results Review] Loaded ${allResults.length} lab results for doctor',
      );

      // Fallback: If no results found with doctorId, try alternative method
      // Get all lab results and check if they belong to doctor's patients
      if (allResults.isEmpty) {
        print(
          '[Lab Results Review] No results found, trying fallback: getting all results and matching by doctor...',
        );
        try {
          // Get patients for this doctor (needed for matching)
          final patients = await _firebaseServices.getDoctorPatients();
          final patientIds = patients
              .map((p) => p['id'] as String?)
              .where((id) => id != null && id.isNotEmpty)
              .toList();

          // Get all lab results
          final allLabResultsSnapshot = await FirebaseFirestore.instance
              .collection('mobile_lab_results')
              .get();

          print(
            '[Lab Results Review] Fallback: Found ${allLabResultsSnapshot.docs.length} total results',
          );

          // Get all requests for this doctor to match results
          final doctorRequestsSnapshot = await FirebaseFirestore.instance
              .collection('mobile_lab_test_requests')
              .where('doctorId', isEqualTo: doctorId)
              .get();

          print(
            '[Lab Results Review] Fallback: Found ${doctorRequestsSnapshot.docs.length} requests for doctor',
          );

          // Create a map of requestId -> patientId for matching
          final Map<String, String> requestIdToPatientId = {};
          final Map<String, String> requestIdToPatientName = {};
          final Set<String> doctorRequestIds =
              {}; // Set of all request IDs for this doctor

          for (var requestDoc in doctorRequestsSnapshot.docs) {
            final requestId = requestDoc.id;
            final requestData = requestDoc.data();
            final requestPatientId = requestData['patientId'] as String?;
            final requestPatientName = requestData['patientName'] as String?;

            doctorRequestIds.add(requestId); // Add to set

            if (requestPatientId != null) {
              requestIdToPatientId[requestId] = requestPatientId;
              if (requestPatientName != null) {
                requestIdToPatientName[requestId] = requestPatientName;
              }
            }
          }

          print(
            '[Lab Results Review] Fallback: Doctor request IDs: ${doctorRequestIds.toList()}',
          );

          for (var doc in allLabResultsSnapshot.docs) {
            final data = doc.data();
            try {
              final result = LabResultModel.fromJson(data, doc.id);
              final resultRequestId = data['requestId'] as String?;
              final resultPatientId = data['patientId'] as String?;

              // Try to find patient name and verify it belongs to this doctor
              String? patientName;
              String? matchedPatientId;
              bool shouldInclude = false;

              // Method 1: Match by requestId (most reliable)
              if (resultRequestId != null &&
                  requestIdToPatientId.containsKey(resultRequestId)) {
                matchedPatientId = requestIdToPatientId[resultRequestId];
                patientName = requestIdToPatientName[resultRequestId];
                shouldInclude = true;
                print(
                  '[Lab Results Review] Fallback: ✓ Matched result via requestId: $resultRequestId -> Patient: $patientName',
                );
              }
              // Method 2: Match by patientId (if patientId matches doctor's patients)
              else if (resultPatientId != null &&
                  patientIds.contains(resultPatientId)) {
                matchedPatientId = resultPatientId;
                // Get patient name from patients list
                final patient = patients.firstWhere(
                  (p) => p['id'] == resultPatientId,
                  orElse: () => <String, dynamic>{'name': 'غير معروف'},
                );
                patientName = patient['name'] as String? ?? 'غير معروف';
                shouldInclude = true;
                print(
                  '[Lab Results Review] Fallback: ✓ Matched result via patientId: $resultPatientId -> Patient: $patientName',
                );
              }
              // Method 3: Try to get patient name from patientId (even if not in list)
              else if (resultPatientId != null) {
                print(
                  '[Lab Results Review] Fallback: Trying to get patient name for patientId: $resultPatientId',
                );
                try {
                  final patientDoc = await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(resultPatientId)
                      .get();
                  if (patientDoc.exists) {
                    final patientData = patientDoc.data();
                    patientName = patientData?['name'] as String?;
                    matchedPatientId = resultPatientId;
                    // Check if this patient is assigned to this doctor
                    final assignedDoctorId =
                        patientData?['assignedDoctorId'] as String? ??
                        patientData?['doctorId'] as String?;
                    if (assignedDoctorId == doctorId) {
                      shouldInclude = true;
                      print(
                        '[Lab Results Review] Fallback: ✓ Patient $patientName is assigned to this doctor',
                      );
                    } else {
                      print(
                        '[Lab Results Review] Fallback: ⚠️ Patient $patientName is not assigned to this doctor',
                      );
                    }
                  }
                } catch (e) {
                  print('[Lab Results Review] Error fetching patient name: $e');
                }
              }

              // Method 4: If result has requestId but doesn't match, try to find patient from request directly
              if (!shouldInclude && resultRequestId != null) {
                print(
                  '[Lab Results Review] Fallback: Trying to get patient from requestId directly: $resultRequestId',
                );
                try {
                  final requestDoc = await FirebaseFirestore.instance
                      .collection('mobile_lab_test_requests')
                      .doc(resultRequestId)
                      .get();
                  if (requestDoc.exists) {
                    final requestData = requestDoc.data();
                    final requestDoctorId = requestData?['doctorId'] as String?;
                    // Only include if the request belongs to this doctor
                    if (requestDoctorId == doctorId) {
                      final requestPatientId =
                          requestData?['patientId'] as String?;
                      final requestPatientName =
                          requestData?['patientName'] as String?;
                      if (requestPatientName != null) {
                        patientName = requestPatientName;
                        matchedPatientId = requestPatientId;
                        shouldInclude = true;
                        print(
                          '[Lab Results Review] Fallback: ✓ Matched via requestId (direct): $patientName',
                        );
                      }
                    } else {
                      print(
                        '[Lab Results Review] Fallback: Request belongs to different doctor: $requestDoctorId',
                      );
                    }
                  } else {
                    print(
                      '[Lab Results Review] Fallback: Request not found: $resultRequestId',
                    );
                  }
                } catch (e) {
                  print('[Lab Results Review] Error fetching request: $e');
                }
              }

              // Only add if we should include this result
              if (!shouldInclude) {
                print(
                  '[Lab Results Review] Fallback: Skipping result ${doc.id} (does not belong to doctor\'s patients)',
                );
                continue;
              }

              allResults.add({
                'id': result.id,
                'testName':
                    result.testName ?? result.testType ?? 'تحليل غير محدد',
                'date': result.createdAt != null
                    ? '${result.createdAt!.day}/${result.createdAt!.month}/${result.createdAt!.year}'
                    : 'غير متوفر',
                'status': result.status == 'completed'
                    ? 'مكتمل'
                    : 'قيد الانتظار',
                'patientName': patientName ?? 'غير معروف',
                'patientId': matchedPatientId ?? resultPatientId,
                'doctorNotes': result.doctorNotes,
                'results': result.results,
                'createdAt': result.createdAt,
              });
            } catch (e) {
              print(
                '[Lab Results Review] Error parsing result in fallback: $e',
              );
            }
          }
          print(
            '[Lab Results Review] Fallback: Added ${allResults.length} results',
          );
        } catch (e) {
          print('[Lab Results Review] Error in fallback: $e');
        }
      }

      // Sort by date (newest first)
      allResults.sort((a, b) {
        final dateA = a['createdAt'] as DateTime?;
        final dateB = b['createdAt'] as DateTime?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      print('[Lab Results Review] Loaded ${allResults.length} lab results');

      if (mounted) {
        setState(() {
          _labResults = allResults;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('[Lab Results Review] ERROR loading lab results: $e');
      print('[Lab Results Review] Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل النتائج: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Get appropriate icon for a test type
  IconData _getIconForTest(String testName) {
    final lowerName = testName.toLowerCase();
    if (lowerName.contains('blood') ||
        lowerName.contains('cbc') ||
        lowerName.contains('دم')) {
      return Icons.bloodtype;
    } else if (lowerName.contains('urine') || lowerName.contains('بول')) {
      return Icons.science;
    } else if (lowerName.contains('ekg') || lowerName.contains('قلب')) {
      return Icons.favorite;
    }
    return Icons.analytics;
  }

  /// Get status color
  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'مكتمل':
      case 'completed':
        return theme.colorScheme.secondary;
      case 'قيد الانتظار':
      case 'pending':
        return const Color(0xFFFFB74D);
      default:
        return Colors.grey;
    }
  }

  /// View detailed information about a lab test result
  void _viewTestDetails(Map<String, dynamic> result) {
    final results = result['results'] as Map<String, dynamic>?;
    final doctorNotes = result['doctorNotes'] as String?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['testName'] as String? ?? 'نتيجة التحليل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'المريض',
                result['patientName'] as String? ?? 'غير معروف',
              ),
              _buildDetailRow(
                'التاريخ',
                result['date'] as String? ?? 'غير متوفر',
              ),
              _buildDetailRow(
                'الحالة',
                result['status'] as String? ?? 'غير محدد',
              ),
              if (doctorNotes != null && doctorNotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'ملاحظات الطبيب:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  doctorNotes,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (results != null && results.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'نتائج التحليل:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...results.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
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

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Add Notes to Lab Result
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method adds doctor notes to a lab result in Firebase.
  //
  // To modify:
  // - Change collection: modify FirebaseServices.addDoctorNotesToLabResult()
  // - Add validation: check if notes are not empty, result exists
  // - Add notifications: notify patient when notes are added
  // - Add audit log: log who added notes and when
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _addNotes(Map<String, dynamic> testResult) async {
    final notesController = TextEditingController();

    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ملاحظات'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: const InputDecoration(
            hintText: 'أدخل الملاحظات...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (dialogResult == true && notesController.text.isNotEmpty) {
      try {
        final resultId = testResult['id'] as String? ?? '';
        if (resultId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ: معرف النتيجة غير صحيح')),
          );
          return;
        }

        // Add doctor notes to lab result in Firebase
        // This updates the 'mobile_lab_results' collection document
        // Updates:
        // - doctorNotes: The notes text
        // - notesAddedBy: Current doctor's UID (should match doctors.uid)
        // - notesAddedAt: Server timestamp
        // This is a mobile-specific collection (not in web app)
        await _firebaseServices.addDoctorNotesToLabResult(
          resultId,
          notesController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ الملاحظات بنجاح')),
          );
          // Reload results to show updated status
          _loadLabResults();
        }
      } catch (e) {
        print('[Lab Results Review] Error adding notes: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
          ).showSnackBar(SnackBar(content: Text('خطأ في حفظ الملاحظات: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildDoctorDrawer(context, theme),
      appBar: AppBar(
        title: const Text('نتائج التحاليل'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh lab results from Firebase
              _loadLabResults();
            },
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            // Patient info card - Show summary if results exist
            if (_labResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
                        Icons.analytics,
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
                            'إجمالي النتائج: ${_labResults.length}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            'مكتملة: ${_labResults.where((r) => (r['status'] as String?) == 'مكتمل').length} | معلقة: ${_labResults.where((r) => (r['status'] as String?) == 'قيد الانتظار').length}',
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

            if (_labResults.isNotEmpty) const SizedBox(height: 16),

            // Lab results list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadLabResults,
              child: _labResults.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                                ),
                      ),
                    )
                  : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                      itemCount: _labResults.length,
                      itemBuilder: (context, index) {
                        final result = _labResults[index];
                                final isPending =
                                    result['status'] == 'قيد الانتظار';
                        final statusColor = _getStatusColor(
                          result['status'],
                          theme,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Test icon
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                  ),
                                  child: Icon(
                                    _getIconForTest(result['testName']),
                                    color: statusColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Test info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                                result['testName'] as String? ??
                                                    'تحليل غير محدد',
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'المريض: ${result['patientName'] as String? ?? 'غير معروف'}',
                                                style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                      color: Colors.grey[600],
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                                result['date'] as String? ??
                                                    'غير متوفر',
                                        style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                                  result['status'] as String? ??
                                                      'غير محدد',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: statusColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action button
                                ElevatedButton(
                                  onPressed: () {
                                    if (isPending) {
                                      _addNotes(result);
                                    } else {
                                      _viewTestDetails(result);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: statusColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(100, 40),
                                    shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    isPending
                                        ? 'إضافة ملاحظات'
                                        : 'عرض التفاصيل',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
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
