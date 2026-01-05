import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import 'doctor_common_widgets.dart';

/// Override Requests Page (UI Layer)
///
/// This page displays override requests from nurses asking doctors
/// to approve medication dosage overrides.
/// Features:
/// - List of pending override requests
/// - Select request to view details
/// - Approve/reject override functionality
/// - Search functionality
///
/// **Architecture**: Uses RequestService to handle
/// all Firebase operations, keeping UI separate from data logic.
class OverrideRequests extends StatefulWidget {
  const OverrideRequests({super.key});

  @override
  State<OverrideRequests> createState() => _OverrideRequestsState();
}

/// State class for Override Requests Page
///
/// Manages:
/// - List of override requests
/// - Filtered/search results
/// - Selected request for details view
/// - Search controller
/// - Navigation state
class _OverrideRequestsState extends State<OverrideRequests> {
  // ==================== State Variables ====================

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();


  // ==================== Override Requests Data ====================

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Override Requests
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // This stores override requests from nurses asking for doctor approval.
  // To modify the data source:
  // 1. Change the query in FirebaseServices.getDoctorPendingOverrideRequests()
  // 2. Update field mappings in _loadOverrideRequests()
  // 3. Modify OverrideRequestModel if new fields are needed
  //
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Complete list of all override requests (unfiltered)
  List<Map<String, dynamic>> _requests = [];

  /// Filtered list of requests based on search query
  List<Map<String, dynamic>> _filteredRequests = [];

  /// Currently selected request to show details
  Map<String, dynamic>? _selectedRequest;
  
  // Loading state
  bool _isLoading = true;
  
  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load override requests from Firebase
    _loadOverrideRequests();
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // This method loads override requests from Firebase.
  // 
  // To modify:
  // - Change query filters: modify FirebaseServices.getDoctorPendingOverrideRequests()
  // - Add status filter: show approved/rejected requests
  // - Add date range: filter by date range
  // - Add pagination: use startAfterDocument() for large lists
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadOverrideRequests() async {
    try {
      setState(() => _isLoading = true);
      
      // Load override requests from Firebase
      // This queries the 'mobile_override_requests' collection filtered by doctorId and status='pending'
      // Note: doctorId should match doctors.uid (not document ID)
      // This is a mobile-specific collection (not in web app)
      // Structure:
      // - doctorId: Doctor's UID (target doctor for approval)
      // - nurseId: Nurse's UID (requesting nurse)
      // - patientId: Patient document ID
      // - medicationName, currentDosage, requestedDosage: Medication details
      // - reason: Reason for override request
      // - status: 'pending', 'approved', or 'rejected'
      // - createdAt: Timestamp
      final requests = await _firebaseServices.getDoctorPendingOverrideRequests();
      
      if (mounted) {
        setState(() {
          _requests = requests.map((req) {
            return {
              'id': req['id'] ?? '',
              'name': req['nurseName'] ?? 'غير معروف',
              'timestamp': req['formattedDate'] ?? 'غير متوفر',
              'description': req['description'] ?? 'لا يوجد وصف',
            };
          }).toList();
    _filteredRequests = _requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Override Requests] Error loading requests: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الطلبات: $e')),
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

  // Removed: _loadOverrideRequests() - TODO: Backend Integration

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

  void _selectRequest(Map<String, dynamic> request) {
    setState(() {
      _selectedRequest = {
        'id': request['id'],
        'name': request['name'],
        'description': request['description'] ?? 'لا يوجد وصف',
        'timestamp': request['timestamp'],
      };
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Approve Override Request
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // This method approves an override request in Firebase.
  // 
  // To modify:
  // - Change collection: modify FirebaseServices.approveOverrideRequest()
  // - Add validation: check request exists, doctor is authorized
  // - Add notifications: notify nurse when request is approved
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _createNewOverride() async {
    if (_selectedRequest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار طلب أولاً')),
      );
      return;
    }

    try {
      final requestId = _selectedRequest!['id'] as String? ?? '';
      if (requestId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف الطلب غير صحيح')),
        );
        return;
      }

      // Approve override request in Firebase
      // This updates the 'mobile_override_requests' collection document
      // Updates:
      // - status: 'approved'
      // - approvedBy: Current doctor's UID
      // - approvedAt: Server timestamp
      await _firebaseServices.approveOverrideRequest(requestId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الموافقة على الطلب بنجاح')),
        );
        setState(() {
          _selectedRequest = null;
        // Remove approved request from list
          _requests.removeWhere((req) => req['id'] == requestId);
        _filteredRequests = _requests;
      });
      }
    } catch (e) {
      print('[Override Requests] Error approving request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الموافقة على الطلب: $e')),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Reject Override Request
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // This method rejects an override request in Firebase.
  // 
  // To modify:
  // - Change collection: modify FirebaseServices.rejectOverrideRequest()
  // - Add validation: check request exists, doctor is authorized
  // - Add notifications: notify nurse when request is rejected
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

      // Reject override request in Firebase
      // This updates the 'mobile_override_requests' collection document
      // Updates:
      // - status: 'rejected'
      // - rejectedBy: Current doctor's UID
      // - rejectedAt: Server timestamp
      await _firebaseServices.rejectOverrideRequest(requestId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض الطلب بنجاح')),
        );
        setState(() {
          _selectedRequest = null;
          // Remove rejected request from list
          _requests.removeWhere((req) => req['id'] == requestId);
          _filteredRequests = _requests;
        });
      }
    } catch (e) {
      print('[Override Requests] Error rejecting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في رفض الطلب: $e')),
        );
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
        title: const Text('طلبات التجاوز'),
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
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'ابحث في طلبات التجاوز...',
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
                            Icons.medical_services_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'لا توجد طلبات تجاوز'
                                : 'لا توجد نتائج',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOverrideRequests,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ..._filteredRequests.map((request) {
                      return InkWell(
                        onTap: () => _selectRequest(request),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedRequest?['name'] == request['name']
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRequest?['name'] == request['name']
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.2),
                              width: _selectedRequest?['name'] == request['name'] ? 2 : 1,
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
                                  color: theme.colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: theme.colorScheme.secondary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                              Text(
                                      request['name'] ?? 'غير معروف',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                              Text(
                                      request['timestamp'] ?? '',
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
                      );
                    }),
                    const SizedBox(height: 16),
                    // Request details card
                    if (_selectedRequest != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل طلب التجاوز',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedRequest!['name'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedRequest!['description'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                            Text(
                                  _selectedRequest!['timestamp'] ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                              ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _rejectRequest(_selectedRequest!),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('رفض'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                              child: ElevatedButton(
                                onPressed: _createNewOverride,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('موافقة'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildDoctorBottomNavBar(context, theme, currentIndex: 0),
    );
  }
}
