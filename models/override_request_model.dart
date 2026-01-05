import 'package:cloud_firestore/cloud_firestore.dart';

class OverrideRequestModel {
  final String id;
  final String? nurseId;
  final String? doctorId;
  final String? patientId;
  final String? medicationName;
  final String? currentDosage;
  final String? requestedDosage;
  final String? reason;
  final String? status;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? approvedAt;

  OverrideRequestModel({
    required this.id,
    this.nurseId,
    this.doctorId,
    this.patientId,
    this.medicationName,
    this.currentDosage,
    this.requestedDosage,
    this.reason,
    this.status,
    this.approvedBy,
    this.createdAt,
    this.approvedAt,
  });

  factory OverrideRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return OverrideRequestModel(
      id: id,
      nurseId: json['nurseId'] as String?,
      doctorId: json['doctorId'] as String?,
      patientId: json['patientId'] as String?,
      medicationName: json['medicationName'] as String?,
      currentDosage: json['currentDosage'] as String?,
      requestedDosage: json['requestedDosage'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'pending',
      approvedBy: json['approvedBy'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      approvedAt: _parseTimestamp(json['approvedAt']),
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

