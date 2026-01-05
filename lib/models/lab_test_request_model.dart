import 'package:cloud_firestore/cloud_firestore.dart';

class LabTestRequestModel {
  final String id;
  final String? doctorId;
  final String? patientId;
  final String? patientName;
  final String? testType;
  final String? test;
  final String? urgency;
  final String? notes;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LabTestRequestModel({
    required this.id,
    this.doctorId,
    this.patientId,
    this.patientName,
    this.testType,
    this.test,
    this.urgency,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory LabTestRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return LabTestRequestModel(
      id: id,
      doctorId: json['doctorId'] as String?,
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      testType: json['testType'] as String?,
      test: json['test'] as String?,
      urgency: json['urgency'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
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

