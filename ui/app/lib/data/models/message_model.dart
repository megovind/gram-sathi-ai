import '../../core/constants/app_constants.dart';

class MessageModel {
  final String role; // 'user' | 'assistant'
  final String content;
  final String? audioUrl;
  final DateTime timestamp;
  final bool isVoiceMessage;
  // Local file path for user voice messages (playback before upload completes)
  final String? localFilePath;
  // True while audio is being uploaded + transcribed
  final bool isUploading;

  const MessageModel({
    required this.role,
    required this.content,
    this.audioUrl,
    required this.timestamp,
    this.isVoiceMessage = false,
    this.localFilePath,
    this.isUploading = false,
  });

  bool get isUser => role == AppConstants.roleUser;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        role: json['role'] as String,
        content: json['content'] as String,
        audioUrl: json['audioUrl'] as String?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );

  factory MessageModel.user(String content) => MessageModel(
        role: AppConstants.roleUser,
        content: content,
        timestamp: DateTime.now(),
      );

  factory MessageModel.voiceUser({String? filePath}) => MessageModel(
        role: AppConstants.roleUser,
        content: '',
        isVoiceMessage: true,
        isUploading: true,
        localFilePath: filePath,
        timestamp: DateTime.now(),
      );

  MessageModel copyWith({
    String? content,
    bool? isVoiceMessage,
    bool? isUploading,
    String? localFilePath,
  }) =>
      MessageModel(
        role: role,
        content: content ?? this.content,
        audioUrl: audioUrl,
        timestamp: timestamp,
        isVoiceMessage: isVoiceMessage ?? this.isVoiceMessage,
        isUploading: isUploading ?? this.isUploading,
        localFilePath: localFilePath ?? this.localFilePath,
      );

  factory MessageModel.assistant(String content, {String? audioUrl}) => MessageModel(
        role: AppConstants.roleAssistant,
        content: content,
        audioUrl: audioUrl,
        timestamp: DateTime.now(),
      );
}
