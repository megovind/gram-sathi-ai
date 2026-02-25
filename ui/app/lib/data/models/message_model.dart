class MessageModel {
  final String role; // 'user' | 'assistant'
  final String content;
  final String? audioUrl;
  final DateTime timestamp;

  const MessageModel({
    required this.role,
    required this.content,
    this.audioUrl,
    required this.timestamp,
  });

  bool get isUser => role == 'user';

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        role: json['role'] as String,
        content: json['content'] as String,
        audioUrl: json['audioUrl'] as String?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );

  factory MessageModel.user(String content) => MessageModel(
        role: 'user',
        content: content,
        timestamp: DateTime.now(),
      );

  factory MessageModel.assistant(String content, {String? audioUrl}) => MessageModel(
        role: 'assistant',
        content: content,
        audioUrl: audioUrl,
        timestamp: DateTime.now(),
      );
}
