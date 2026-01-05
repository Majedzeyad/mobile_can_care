import 'package:cloud_firestore/cloud_firestore.dart';

class LabResultModel {
  final String id;
  final String? requestId;
  final String? patientId;
  final Map<String, dynamic>? results;
  final String? doctorNotes;
  final String? notesAddedBy;
  final DateTime? createdAt;
  final DateTime? notesAddedAt;

  LabResultModel({
    required this.id,
    this.requestId,
    this.patientId,
    this.results,
    this.doctorNotes,
    this.notesAddedBy,
    this.createdAt,
    this.notesAddedAt,
  });

  factory LabResultModel.fromJson(Map<String, dynamic> json, String id) {
    return LabResultModel(
      id: id,
      requestId: json['requestId'] as String?,
      patientId: json['patientId'] as String?,
      results: json['results'] as Map<String, dynamic>?,
      doctorNotes: json['doctorNotes'] as String?,
      notesAddedBy: json['notesAddedBy'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      notesAddedAt: _parseTimestamp(json['notesAddedAt']),
    );
  }

  String? get testType => results?['testType'] as String?;
  String get status => doctorNotes != null && doctorNotes!.isNotEmpty ? 'completed' : 'pending';
  String? get testName => results?['testType'] as String? ?? requestId;

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

