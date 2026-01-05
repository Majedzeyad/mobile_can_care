import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? bloodType;
  final String? status;
  final String? assignedDoctorId;
  final String? assignedNurseId;
  final Map<String, dynamic>? webData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PatientModel({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.dob,
    this.gender,
    this.bloodType,
    this.status,
    this.assignedDoctorId,
    this.assignedNurseId,
    this.webData,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json, String id) {
    // Parse dob - can be String, Timestamp, or DateTime
    String? dobString;
    final dobValue = json['dob'];
    if (dobValue != null) {
      if (dobValue is String) {
        dobString = dobValue;
      } else if (dobValue is Timestamp) {
        final date = dobValue.toDate();
        dobString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } else if (dobValue is DateTime) {
        dobString = '${dobValue.year}-${dobValue.month.toString().padLeft(2, '0')}-${dobValue.day.toString().padLeft(2, '0')}';
      }
    }

    return PatientModel(
      id: id,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dob: dobString,
      gender: json['gender'] as String?,
      bloodType: json['bloodType'] as String?,
      status: json['status'] as String?,
      assignedDoctorId: json['assignedDoctorId'] as String? ?? json['doctorId'] as String?,
      assignedNurseId: json['assignedNurseId'] as String? ?? json['nurseId'] as String?,
      webData: json['webData'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  String? get diagnosis => webData?['diagnosis'] as String?;

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

