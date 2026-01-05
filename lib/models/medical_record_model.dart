import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordModel {
  final String id;
  final String? doctorId;
  final String? patientId;
  final String? category;
  final String? description;
  final List<dynamic>? attachments;
  final DateTime? createdAt;

  MedicalRecordModel({
    required this.id,
    this.doctorId,
    this.patientId,
    this.category,
    this.description,
    this.attachments,
    this.createdAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json, String id) {
    return MedicalRecordModel(
      id: id,
      doctorId: json['doctorId'] as String?,
      patientId: json['patientId'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      attachments: json['attachments'] as List<dynamic>?,
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

