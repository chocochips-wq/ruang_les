import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPostModel {
  final String? postId;
  final String userId;
  final String authorName;
  final String title;
  final String content;
  final int likes;
  final int replies;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> likedBy; // List of user IDs who liked this post

  ForumPostModel({
    this.postId,
    required this.userId,
    required this.authorName,
    required this.title,
    required this.content,
    this.likes = 0,
    this.replies = 0,
    this.likedBy = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'likes': likes,
      'replies': replies,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ForumPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumPostModel(
      postId: doc.id,
      userId: data['userId'] ?? '',
      authorName: data['authorName'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      replies: data['replies'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  ForumPostModel copyWith({
    String? postId,
    String? userId,
    String? authorName,
    String? title,
    String? content,
    int? likes,
    int? replies,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ForumPostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
