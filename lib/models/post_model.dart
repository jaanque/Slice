class PostModel {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  String? username; // Campo opcional para almacenar el nombre del usuario

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.username,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}