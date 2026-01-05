import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatMessageModel {
  final String id;
  final String groupChatId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'doctor', 'nurse', 'patient'
  final String message;
  final DateTime? createdAt;
  final Map<String, bool>? readBy; // userId -> read status

  GroupChatMessageModel({
    required this.id,
    required this.groupChatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    this.createdAt,
    this.readBy,
  });

  factory GroupChatMessageModel.fromJson(Map<String, dynamic> json, String id) {
    // Parse createdAt
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

    // Parse readBy
    Map<String, bool>? readBy;
    if (json['readBy'] != null) {
      if (json['readBy'] is Map) {
        readBy = Map<String, bool>.from(
          json['readBy'].map((key, value) => MapEntry(
                key.toString(),
                value is bool ? value : false,
              )),
        );
      }
    }

    // Support both 'message' and 'content' fields (legacy messages use 'content')
    final messageContent = json['message'] as String? ?? 
                          json['content'] as String? ?? 
                          '';
    
    // Support both 'groupChatId' and 'groupId' fields (legacy messages use 'groupId')
    final chatId = json['groupChatId'] as String? ?? 
                   json['groupId'] as String? ?? 
                   '';

    return GroupChatMessageModel(
      id: id,
      groupChatId: chatId,
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'مستخدم',
      senderRole: json['senderRole'] as String? ?? 'patient',
      message: messageContent,
      createdAt: createdAt,
      readBy: readBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupChatId': groupChatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'readBy': readBy ?? {},
    };
  }

  bool isReadBy(String userId) {
    return readBy?[userId] ?? false;
  }
}

