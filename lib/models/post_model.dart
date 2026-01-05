import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String? title;
  final String? content;
  final String? authorId;
  final String? authorName;
  final String? category;
  final String? image;
  final int likes;
  final List<Map<String, dynamic>> comments;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    this.title,
    this.content,
    this.authorId,
    this.authorName,
    this.category,
    this.image,
    this.likes = 0,
    this.comments = const [],
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
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

    // Parse comments
    List<Map<String, dynamic>> comments = [];
    if (json['comments'] != null) {
      if (json['comments'] is List) {
        comments = List<Map<String, dynamic>>.from(
          json['comments'].map((comment) {
            if (comment is Map) {
              return Map<String, dynamic>.from(comment);
            }
            return {};
          }),
        );
      }
    }

    return PostModel(
      id: id,
      title: json['title'] as String?,
      content: json['content'] as String?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      category: json['category'] as String?,
      image: json['image'] as String?,
      likes: (json['likes'] as int?) ?? 0,
      comments: comments,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'category': category,
      'image': image,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}


