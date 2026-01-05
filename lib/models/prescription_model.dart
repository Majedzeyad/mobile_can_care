import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionModel {
  final String id;
  final String? doctorId;
  final String? patientId;
  final String? patientName;
  final String? medicationName;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? notes;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrescriptionModel({
    required this.id,
    this.doctorId,
    this.patientId,
    this.patientName,
    this.medicationName,
    this.dosage,
    this.frequency,
    this.duration,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json, String id) {
    return PrescriptionModel(
      id: id,
      doctorId: json['doctorId'] as String?,
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      medicationName: json['medicationName'] as String?,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      duration: json['duration'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
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

