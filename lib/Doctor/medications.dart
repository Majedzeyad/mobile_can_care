import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import 'doctor_common_widgets.dart';

/// Medications Page (UI Layer)
///
/// This page displays all available medications that doctors can order.
/// Features:
/// - List of all medications with name and dosage
/// - Search functionality to find medications
/// - Order medication button
class Medications extends StatefulWidget {
  const Medications({super.key});

  @override
  State<Medications> createState() => _MedicationsState();
}

/// State class for Medications Page
class _MedicationsState extends State<Medications> {
  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // This page doesn't have a specific index in bottom nav (not in main 4 tabs)
  // It's accessible from drawer only

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Medications Catalog
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This stores the medication catalog that doctors can order from.
  // To modify the data source:
  // 1. Change the query in FirebaseServices.getAllMedications()
  // 2. Update field mappings in _loadMedications()
  // 3. Add new fields: extend the medication data structure
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Complete list of all medications (unfiltered)
  List<Map<String, dynamic>> _medications = [];

  /// Filtered list of medications based on search query
  List<Map<String, dynamic>> _filteredMedications = [];

  // Loading state
  bool _isLoading = true;

  // Firebase service instance
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  @override
  void initState() {
    super.initState();
    // Load medications from Firebase
    _loadMedications();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE DATA LOADING METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method loads medications catalog from Firebase.
  //
  // To modify:
  // - Change collection name: modify FirebaseServices.getAllMedications()
  // - Add filters: filter by category, availability, etc.
  // - Add pagination: use startAfterDocument() for large catalogs
  // - Add search: implement server-side search if needed
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadMedications() async {
    try {
      setState(() => _isLoading = true);

      // Load medications from Firebase
      // This queries the 'medications' collection
      // This is a shared catalog collection (used by both web and mobile)
      // Structure:
      // - name: Medication name
      // - dosage: Dosage information
      // - category: Medication category
      final medications = await _firebaseServices.getAllMedications();

      if (mounted) {
        setState(() {
          _medications = medications.map((med) {
            return {
              'id': med['id'] ?? '',
              'name': med['name'] ?? 'غير معروف',
              'dosage': med['dosage'] ?? 'لا يوجد جرعة',
              'category': med['category'] ?? 'غير محدد',
            };
          }).toList();
    _filteredMedications = _medications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Medications] Error loading medications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الأدوية: $e')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handle search input and filter the medication list
  void _searchMedications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedications = _medications;
      } else {
        _filteredMedications = _medications.where((med) {
          final name = (med['name'] ?? '').toString().toLowerCase();
          final category = (med['category'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || category.contains(searchLower);
        }).toList();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INTEGRATION - Create Medication Order
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This method creates a medication order in Firebase.
  //
  // To modify:
  // - Change collection name: modify FirebaseServices.createMedicationOrder()
  // - Add validation: check medication exists, doctor is authorized
  // - Add notifications: notify pharmacy when order is created
  // - Add quantity: add quantity field to order
  //
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _orderMedication(Map<String, dynamic> medication) async {
    try {
      final medicationId = medication['id'] as String? ?? '';
      final medicationName = medication['name'] as String? ?? '';

      if (medicationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرف الدواء غير صحيح')),
        );
        return;
      }

      // Create medication order in Firebase
      // This adds a document to 'mobile_medication_orders' collection
      // Note: doctorId should match doctors.uid (not document ID)
      // This is a mobile-specific collection (not in web app)
      // Structure:
      // - doctorId: Doctor's UID
      // - medicationId: Medication document ID from 'medications' collection
      // - medicationName: Medication name
      // - status: 'pending' (default)
      // - createdAt: Server timestamp
      await _firebaseServices.createMedicationOrder(
        medicationId,
        medicationName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم طلب ${medicationName} بنجاح')),
      );
      }
    } catch (e) {
      print('[Medications] Error creating order: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في إنشاء الطلب: $e')));
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
        title: const Text('الأدوية'),
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
                  onChanged: _searchMedications,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن دواء...',
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

            // Medications count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'إجمالي الأدوية: ${_filteredMedications.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Medications list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMedications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'لا توجد أدوية متاحة'
                                : 'لا توجد نتائج',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMedications,
                      child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredMedications.length,
                      itemBuilder: (context, index) {
                        final medication = _filteredMedications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.secondary.withOpacity(
                                0.2,
                              ),
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
                                // Medication icon
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.medication,
                                    color: theme.colorScheme.secondary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Medication info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medication['name'] ?? 'غير معروف',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          medication['dosage'] ??
                                              'لا يوجد جرعة',
                                        style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        medication['category'] ?? '',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Order button
                                ElevatedButton(
                                    onPressed: () =>
                                        _orderMedication(medication),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(90, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'طلب',
                                    style: TextStyle(fontSize: 14),
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
      bottomNavigationBar: buildDoctorBottomNavBar(context, theme, currentIndex: 0),
    );
  }
}
