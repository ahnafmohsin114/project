class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.color = '#22D3EE',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: map['color'] ?? '#22D3EE',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'color': color,
    };
  }

  Note copyWith({String? title, String? content, String? color}) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
