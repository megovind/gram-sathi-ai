import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/message_model.dart';
import 'formatted_message.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final Widget? audioWidget;

  const MessageBubble({super.key, required this.message, this.audioWidget});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: _BubbleContainer(
          isUser: true,
          margin: const EdgeInsets.only(top: 4, bottom: 4, left: 64),
          message: message,
          audioWidget: audioWidget,
        ),
      );
    }

    // Assistant: avatar + bubble
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AssistantAvatar(),
          const SizedBox(width: 6),
          Flexible(
            child: _BubbleContainer(
              isUser: false,
              margin: const EdgeInsets.only(top: 4, bottom: 4, right: 64),
              message: message,
              audioWidget: audioWidget,
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleContainer extends StatelessWidget {
  final bool isUser;
  final EdgeInsets margin;
  final MessageModel message;
  final Widget? audioWidget;

  const _BubbleContainer({
    required this.isUser,
    required this.margin,
    required this.message,
    this.audioWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppColors.userBubble : AppColors.assistantBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isVoiceMessage)
            _VoiceMessageContent(isUploading: message.isUploading)
          else
            FormattedMessage(
              text: message.content,
              textColor: isUser ? Colors.white : AppColors.textPrimary,
              isUser: isUser,
            ),
          if (audioWidget != null) ...[
            const SizedBox(height: 8),
            audioWidget!,
          ],
          const SizedBox(height: 4),
          _Timestamp(
            timestamp: message.timestamp,
            isUser: isUser,
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
    );
  }
}

class _VoiceMessageContent extends StatelessWidget {
  final bool isUploading;
  const _VoiceMessageContent({this.isUploading = false});

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Sending...',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mic_rounded, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Row(
          children: List.generate(
            10,
            (i) => Container(
              width: 3,
              height: (i % 3 == 0 ? 14 : i % 2 == 0 ? 10 : 6).toDouble(),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Timestamp extends StatelessWidget {
  final DateTime timestamp;
  final bool isUser;

  const _Timestamp({required this.timestamp, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        '$hour:$minute',
        style: TextStyle(
          fontSize: 10,
          color: isUser ? Colors.white54 : AppColors.textHint,
        ),
      ),
    );
  }
}
