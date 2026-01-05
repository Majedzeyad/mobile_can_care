import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_services.dart';
import 'doctor_common_widgets.dart';

/// Incoming Requests Page (UI Layer)
///
/// This page displays transfer requests from other doctors/nurses
/// to transfer patients to the current doctor.
/// Features:
/// - List of pending transfer requests
/// - Accept/reject request functionality
/// - Search functionality
///
/// **Architecture**: Uses RequestService to handle
/// all Firebase operations, keeping UI separate from data logic.
class IncomingRequests extends StatefulWidget {
  const IncomingRequests({super.key});

  @override
  State<IncomingRequests> createState() => _IncomingRequestsState();
}

/// State class for Incoming Requests Page
///
/// Manages:
/// - List of transfer requests
/// - Filtered/search results
/// - Search controller
/// - Navigation state
class _IncomingRequestsState extends State<IncomingRequests> {
  // ==================== State Variables ====================

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // This page doesn't have a specific index in bottom nav (not in main 4 tabs)
  // It's accessible from drawer only

  // ==================== Transfer Requests Data ====================

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Incoming Transfer Requests
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores transfer requests from other doctors/nurses.
  // NOTE: This feature may need a new collection in Firestore.
  // To implement:
  // 1. Create 'transfer_requests' collection in Firestore
  // 2. Add methods to FirebaseServices for transfer requests
  // 3. Query requests where targetDoctorId = currentUserId
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Complete list of all transfer requests (unfiltered)
  List<Map<String, dynamic>> _requests = [];

  /// Filtered list of requests based on search query
  List<Map<String, dynamic>> _filteredRequests = [];

  // Loading state
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load incoming requests from Firebase
    _loadIncomingRequests();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads incoming transfer requests from Firebase.
  //
  // To implement:
  // - Create 'transfer_requests' collection in Firestore
  // - Add getIncomingTransferRequests() method to FirebaseServices
  // - Query where targetDoctorId = currentUserId and status = 'pending'
  // - Include patient name, requesting doctor/nurse name, timestamp
  //
  // Example query structure:
  // final snapshot = await _firestore
  //   .collection('transfer_requests')
  //   .where('targetDoctorId', isEqualTo: currentUserId)
  //   .where('status', isEqualTo: 'pending')
  //   .orderBy('createdAt', descending: true)
  //   .get();
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadIncomingRequests() async {
    try {
      setState(() => _isLoading = true);

      print('[Incoming Requests] Loading transfer requests...');
      final doctorId = _firebaseServices.currentUserId;
      if (doctorId == null) {
        print('[Incoming Requests] No doctor ID found');
        if (mounted) {
          setState(() {
            _requests = [];
            _filteredRequests = _requests;
            _isLoading = false;
          });
        }
        return;
      }

      // Query web_transfers collection for pending transfers assigned to this doctor
      // Note: web_transfers uses 'assignedDoctorId' field
      QuerySnapshot snapshot;
      try {
        // Try with orderBy first
        snapshot = await FirebaseFirestore.instance
            .collection('web_transfers')
            .where('assignedDoctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If index error, try without orderBy
        if (e.toString().contains('index') ||
            e.toString().contains('FAILED_PRECONDITION')) {
          print(
            '[Incoming Requests] Index required, fetching without orderBy...',
          );
          snapshot = await FirebaseFirestore.instance
              .collection('web_transfers')
              .where('assignedDoctorId', isEqualTo: doctorId)
              .where('status', isEqualTo: 'pending')
              .get();
        } else {
          rethrow;
        }
      }

      print(
        '[Incoming Requests] Found ${snapshot.docs.length} transfer requests',
      );

      final List<Map<String, dynamic>> requests = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        requests.add({
          'id': doc.id,
          'name': data['patient'] as String? ?? 'مريض غير معروف',
          'type': 'نقل مريض',
          'timestamp': createdAt != null
              ? '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
              : 'غير متوفر',
          'patientId': data['patientId'] as String?,
          'fromDept': data['fromDept'] as String?,
          'toDept': data['toDept'] as String?,
          'reason': data['reason'] as String?,
          'isNew': true, // Mark as new for visual distinction
          'createdAt': createdAt,
        });
      }

      // Sort by date if not already sorted
      requests.sort((a, b) {
        final dateA = a['createdAt'] as DateTime?;
        final dateB = b['createdAt'] as DateTime?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _requests = requests;
          _filteredRequests = _requests;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('[Incoming Requests] Error loading requests: $e');
      print('[Incoming Requests] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _requests = [];
    _filteredRequests = _requests;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الطلبات: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Clean up resources when widget is disposed
  ///
  /// Disposes the search controller to prevent memory leaks.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== Data Loading Methods ====================

  // Removed: _loadIncomingRequests() - TODO: Backend Integration

  // ==================== UI Action Handlers ====================

  void _searchRequests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRequests = _requests;
      } else {
        _filteredRequests = _requests.where((req) {
          final name = (req['name'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower);
        }).toList();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Accept Transfer Request
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method accepts a transfer request in Firebase.
  //
  // To implement:
  // - Add acceptTransferRequest() method to FirebaseServices
  // - Update transfer request status to 'accepted'
  // - Update patient's assignedDoctorId to current doctor
  // - Send notification to requesting doctor/nurse
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    try {
      final requestId = request['id'] as String? ?? '';
      final patientId = request['patientId'] as String?;

      if (requestId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف الطلب غير صحيح')),
        );
        return;
      }

      final doctorId = _firebaseServices.currentUserId;
      if (doctorId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('خطأ: لا يوجد طبيب مسجل')));
        return;
      }

      // Update transfer request status to 'accepted'
      await FirebaseFirestore.instance
          .collection('web_transfers')
          .doc(requestId)
          .update({
            'status': 'accepted',
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': doctorId,
          });

      // Update patient's assignedDoctorId if patientId exists
      if (patientId != null && patientId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .update({
              'assignedDoctorId': doctorId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم قبول طلب ${request['name']}'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload requests
        _loadIncomingRequests();
      }
    } catch (e) {
      print('[Incoming Requests] Error accepting request: $e');
    if (mounted) {
      ScaffoldMessenger.of(
        context,
        ).showSnackBar(SnackBar(content: Text('خطأ في قبول الطلب: $e')));
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Reject Transfer Request
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method rejects a transfer request in Firebase.
  //
  // To implement:
  // - Add rejectTransferRequest() method to FirebaseServices
  // - Update transfer request status to 'rejected'
  // - Send notification to requesting doctor/nurse
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    try {
      final requestId = request['id'] as String? ?? '';

      if (requestId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف الطلب غير صحيح')),
        );
        return;
      }

      final doctorId = _firebaseServices.currentUserId;
      if (doctorId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('خطأ: لا يوجد طبيب مسجل')));
        return;
      }

      // Update transfer request status to 'rejected'
      await FirebaseFirestore.instance
          .collection('web_transfers')
          .doc(requestId)
          .update({
            'status': 'rejected',
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': doctorId,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفض طلب ${request['name']}'),
            backgroundColor: Colors.orange,
          ),
        );
        // Reload requests
        _loadIncomingRequests();
      }
    } catch (e) {
      print('[Incoming Requests] Error rejecting request: $e');
    if (mounted) {
      ScaffoldMessenger.of(
        context,
        ).showSnackBar(SnackBar(content: Text('خطأ في رفض الطلب: $e')));
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
        title: const Text('الطلبات الواردة'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh incoming requests from Firebase
              _loadIncomingRequests();
            },
            tooltip: 'تحديث',
          ),
        ],
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchRequests,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'ابحث في الطلبات...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Requests list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد طلبات واردة',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سيتم عرض الطلبات هنا عند وصولها',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadIncomingRequests,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = _filteredRequests[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: request['isNew']
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: request['isNew']
                            ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withOpacity(
                                        0.2,
                                      ),
                        width: request['isNew'] ? 2 : 1,
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
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 28,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                            children: [
                              if (request['isNew'])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                  ),
                                  child: Text(
                                    'طلب جديد',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                      if (request['isNew'])
                                        const SizedBox(height: 6),
                              Text(
                                request['name'],
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request['type'],
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request['timestamp'],
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _acceptRequest(request),
                              style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(80, 40),
                                shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                ),
                              ),
                              child: Text(
                                'قبول',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _rejectRequest(request),
                              style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFEF5350,
                                        ),
                                side: const BorderSide(
                                  color: Color(0xFFEF5350),
                                ),
                                minimumSize: const Size(80, 40),
                                shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                ),
                              ),
                              child: Text(
                                'رفض',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildDoctorBottomNavBar(
              context,
        theme,
        currentIndex: 0,
      ),
    );
  }
}
