import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final String? department;
  final String? specialization;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? workSchedule;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorModel({
    required this.uid,
    this.name,
    this.email,
    this.phone,
    this.department,
    this.specialization,
    this.stats,
    this.workSchedule,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json, String uid) {
    return DoctorModel(
      uid: uid,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      department: json['department'] as String?,
      specialization: json['specialization'] as String?,
      stats: json['stats'] as Map<String, dynamic>?,
      workSchedule: json['workSchedule'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
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

