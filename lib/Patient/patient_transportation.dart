import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import 'patient_common_widgets.dart';

/// Patient Transportation Request Page
///
/// This page allows patients to request transportation services to hospitals.
/// Features include:
/// - Hospital selector dropdown with available hospital options
/// - Reason field for transportation request details
/// - Submit transportation request functionality
/// - View request history with status (approved, rejected, pending)
/// - Request status tracking and timestamps
///
/// The page helps patients coordinate medical transportation needs, ensuring
/// they can get to appointments and medical facilities when needed.
class PatientTransportation extends StatefulWidget {
  const PatientTransportation({super.key});

  @override
  State<PatientTransportation> createState() => _PatientTransportationState();
}

/// State class for Patient Transportation Request Page
///
/// Manages:
/// - Current navigation index
/// - Selected hospital for transportation request
/// - Reason text controller for request details
/// - List of available hospitals
/// - Transportation request history
/// - UI state and form submission
class _PatientTransportationState extends State<PatientTransportation> {
  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Patient Transportation
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores transportation requests from Firebase.
  // To modify the data source:
  // - Change query filters in FirebaseServices.getPatientTransportationRequests()
  // - Update request creation in FirebaseServices.createTransportationRequest()
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  /// Currently selected hospital from the dropdown
  String? _selectedHospital;

  /// Controller for the reason text field explaining transportation need
  final TextEditingController _reasonController = TextEditingController();

  // List of available hospitals (can be extended to fetch from Firebase)
  final List<String> _hospitals = [
    'Abdali Hospital',
    'Jordan University',
    'Jordan Hospital',
  ];

  // Previous transportation requests from Firebase
  List<Map<String, dynamic>> _lastRequests = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransportationRequests();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads transportation requests from Firebase.
  //
  // To modify:
  // - Change the query filters in FirebaseServices.getPatientTransportationRequests()
  // - Update the data mapping if request structure changes
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadTransportationRequests() async {
    try {
      setState(() => _isLoading = true);

      // Load transportation requests
      final requests = await _firebaseServices
          .getPatientTransportationRequests();
      _lastRequests = requests.map((req) {
        final createdAt = (req['createdAt'] as dynamic)?.toDate();
        return {
          'id': req['id'],
          'sendTime': createdAt != null
              ? _formatDateTime(createdAt)
              : 'غير متاح',
          'state': _getStatusText(req['status'] ?? 'pending'),
          'status': req['status'] ?? 'pending',
          'destination': req['destination'] ?? 'غير متاح',
        };
      }).toList();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print(
        '[PatientTransportation] Error loading transportation requests: $e',
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل طلبات النقل: $e')));
      }
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} في ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return 'مقبول';
      case 'rejected':
      case 'denied':
        return 'مرفوض';
      case 'pending':
        return 'قيد الانتظار';
      default:
        return 'غير معروف';
    }
  }

  /// Clean up resources when widget is disposed.
  ///
  /// Disposes the reason text controller to prevent memory leaks.
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Builds the patient transportation request UI with form and history.
  ///
  /// Creates an interface including:
  /// - Status bar simulation at the top
  /// - Header with page title and back button
  /// - Transportation request form (hospital selector, reason field, submit button)
  /// - Request history section showing previous requests and their status
  /// - Status indicators with appropriate colors (approved/rejected/pending)
  ///
  /// [context] - BuildContext for building the widget tree
  /// Returns: Widget - The complete patient transportation request UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildPatientDrawer(context, theme),
      bottomNavigationBar: buildPatientBottomNavBar(
        context,
        theme,
        currentIndex: 0, // الرئيسية
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
                    '9:53',
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
                      'النقل الطبي',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Backend Integration - View request history
                    },
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      'طلب النقل الطبي',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Hospital selection buttons
                    _buildHospitalSelection(context),
                    const SizedBox(height: 16),
                    // Reason text area
                    _buildReasonTextArea(context),
                    const SizedBox(height: 16),
                    // Send button
                    _buildSendButton(context),
                    const SizedBox(height: 32),
                    // Last requests heading
                    Text(
                      'الطلبات السابقة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Last requests list
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_lastRequests.isEmpty)
                      Center(
                        child: Text(
                          'لا توجد طلبات سابقة',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      )
                    else
                      ..._lastRequests.map(
                        (request) => _buildRequestHistoryItem(request),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalSelection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedHospital ?? 'Choose New Hospital',
                style: TextStyle(
                  color: _selectedHospital != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Hospital buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _hospitals.map((hospital) {
            final isSelected = _selectedHospital == hospital;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHospital = hospital;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  hospital,
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonTextArea(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سبب طلب النقل',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _reasonController,
            maxLines: 5,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'أدخل سبب طلب النقل...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_selectedHospital == null || _reasonController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('الرجاء اختيار المستشفى وإدخال السبب'),
              ),
            );
            return;
          }

          setState(() => _isLoading = true);
          try {
            // ═══════════════════════════════════════════════════════════════════════════
            // FIREBASE DATA SUBMISSION METHOD
            // ═══════════════════════════════════════════════════════════════════════════
            //
            // This method creates a transportation request in Firebase.
            // It uses the `FirebaseServices.createTransportationRequest()` method.
            //
            // To modify:
            // - Adjust the parameters passed to createTransportationRequest()
            // - Change error handling or success feedback
            //
            // ═══════════════════════════════════════════════════════════════════════════
            final success = await _firebaseServices.createTransportationRequest(
              pickupLocation:
                  'موقع المريض', // Can be enhanced with actual location
              destination: _selectedHospital!,
              requestedTime: DateTime.now().add(const Duration(hours: 1)),
              notes: _reasonController.text.trim(),
            );

            if (mounted) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
                );
                setState(() {
                  _selectedHospital = null;
                  _reasonController.clear();
                });
                await _loadTransportationRequests(); // Reload requests
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل إرسال الطلب')),
                );
              }
            }
          } catch (e) {
            print(
              '[PatientTransportation] Error creating transportation request: $e',
            );
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('خطأ في إرسال الطلب: $e')));
            }
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('إرسال الطلب'),
      ),
    );
  }

  Widget _buildRequestHistoryItem(Map<String, dynamic> request) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send Time:',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                request['sendTime'],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'State:',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                request['state'],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: request['status'] == 'rejected'
                      ? Colors.red
                      : request['status'] == 'accepted'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
