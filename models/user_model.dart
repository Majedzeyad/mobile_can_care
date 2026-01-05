import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final Map<String, dynamic>? profile;
  final String? activeRole;
  final List<String>? platforms;
  final Map<String, dynamic>? preferences;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? lastLoginPlatform;

  UserModel({
    required this.uid,
    this.email,
    this.profile,
    this.activeRole,
    this.platforms,
    this.preferences,
    this.createdAt,
    this.lastLoginAt,
    this.lastLoginPlatform,
  });

  /// Factory constructor for creating UserModel from Firestore document data
  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      email: json['email'] as String?,
      profile: json['profile'] as Map<String, dynamic>?,
      activeRole: json['activeRole'] as String?,
      platforms: json['platforms'] != null
          ? List<String>.from(json['platforms'] as List)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
      lastLoginAt: _parseTimestamp(json['lastLoginAt']),
      lastLoginPlatform: json['lastLoginPlatform'] as String?,
    );
  }

  /// Parse timestamp from Firestore (Timestamp object) or other formats
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    // Handle Firestore Timestamp object
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    // Handle Map format (for JSON exports - analysis only)
    if (timestamp is Map<String, dynamic>) {
      if (timestamp.containsKey('_firestore_timestamp')) {
        return DateTime.parse(timestamp['_firestore_timestamp'] as String);
      } else if (timestamp.containsKey('_seconds')) {
        final seconds = timestamp['_seconds'] as int;
        final nanoseconds = timestamp['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
      }
    }

    // Handle String format
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }

    return null;
  }

  String? get name => profile?['name'] as String?;
}
