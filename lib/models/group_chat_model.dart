import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatModel {
  final String id;
  final String? name;
  final String? description;
  final List<String> memberIds;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GroupChatModel({
    required this.id,
    this.name,
    this.description,
    this.memberIds = const [],
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json, String id) {
    // Parse memberIds
    List<String> memberIds = [];
    if (json['memberIds'] != null) {
      if (json['memberIds'] is List) {
        memberIds = List<String>.from(
          json['memberIds'].map((id) => id.toString()),
        );
      }
    }

    // Parse dates
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        createdAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        try {
          createdAt = DateTime.parse(json['createdAt']);
        } catch (e) {
          createdAt = null;
        }
      }
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      if (json['updatedAt'] is Timestamp) {
        updatedAt = (json['updatedAt'] as Timestamp).toDate();
      } else if (json['updatedAt'] is String) {
        try {
          updatedAt = DateTime.parse(json['updatedAt']);
        } catch (e) {
          updatedAt = null;
        }
      }
    }

    return GroupChatModel(
      id: id,
      name: json['name'] as String?,
      description: json['description'] as String?,
      memberIds: memberIds,
      createdBy: json['createdBy'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  bool isMember(String userId) {
    return memberIds.contains(userId);
  }
}


