class Post {
  final int? id;
  final String title;
  final String body;
  final String author;
  final String createdAt;

  Post({
    this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.createdAt,
  });

  // Convert a Post into a Map (for SQLite insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'author': author,
      'created_at': createdAt,
    };
  }

  // Create a Post from a Map (when reading from SQLite)
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int?,
      title: map['title'] as String,
      body: map['body'] as String,
      author: map['author'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  // CopyWith for editing
  Post copyWith({
    int? id,
    String? title,
    String? body,
    String? author,
    String? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
