import 'package:cloud_firestore/cloud_firestore.dart';

class NurseModel {
  final String uid;
  final String? name;
  final String? department;
  final String? phone;
  final String? shift;
  final Map<String, dynamic>? stats;
  final DateTime? createdAt;

  NurseModel({
    required this.uid,
    this.name,
    this.department,
    this.phone,
    this.shift,
    this.stats,
    this.createdAt,
  });

  factory NurseModel.fromJson(Map<String, dynamic> json, String uid) {
    return NurseModel(
      uid: uid,
      name: json['name'] as String?,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      shift: json['shift'] as String?,
      stats: json['stats'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is Map<String, dynamic>) {
      if (timestamp.containsKey('_seconds')) {
        final seconds = timestamp['_seconds'] as int;
        final nanoseconds = timestamp['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
      }
    }
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }
}

