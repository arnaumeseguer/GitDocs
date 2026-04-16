/// Model — ChatMessage
class ChatMessage {
  final String id;
  final String role;   // 'user' | 'bot'
  final String content;
  final String? readme;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.readme,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'readme': readme,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        readme: json['readme'] as String?,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      );
}

/// Model — Chat
class Chat {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });
}
