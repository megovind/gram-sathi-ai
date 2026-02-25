import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/message_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/audio_player_widget.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _audioService = AudioService();
  late ApiService _apiService;

  final List<MessageModel> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  bool _isRecording = false;
  bool _isEmergency = false;

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.healthTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital_outlined),
            tooltip: 'Nearby Clinics',
            onPressed: () => context.push(AppRoutes.nearby),
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency banner
          if (_isEmergency)
            Container(
              width: double.infinity,
              color: AppColors.emergency,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.emergencyBanner,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(onSuggestionTap: _sendText)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) {
                        return const _TypingIndicator();
                      }
                      final msg = _messages[i];
                      return MessageBubble(
                        message: msg,
                        audioWidget: msg.audioUrl != null
                            ? AudioPlayerWidget(url: msg.audioUrl!)
                            : null,
                      );
                    },
                  ),
          ),

          // Doctor summary button (shows after some messages)
          if (_messages.length >= 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: _getDoctorSummary,
                icon: const Icon(Icons.summarize_outlined),
                label: const Text(AppStrings.getDoctorSummary),
              ),
            ),

          // Input bar
          _InputBar(
            controller: _textController,
            isRecording: _isRecording,
            isLoading: _isLoading,
            onSend: () => _sendText(_textController.text),
            onVoiceStart: _startRecording,
            onVoiceStop: _stopRecordingAndSend,
          ),
        ],
      ),
    );
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _addUserMessage(text);
    await _callApi(text: text);
  }

  Future<void> _startRecording() async {
    final granted = await _audioService.requestMicPermission();
    if (!granted) {
      _showSnack(AppStrings.micPermissionDenied);
      return;
    }
    await _audioService.startRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecordingAndSend() async {
    setState(() => _isRecording = false);
    final file = await _audioService.stopRecording();
    if (file == null) return;

    setState(() => _isLoading = true);

    try {
      // Get presigned S3 upload URL
      final uploadData = await _apiService.getAudioUploadUrl(
        fileName: file.path.split('/').last,
        contentType: 'audio/m4a',
      );
      final uploadUrl = uploadData['uploadUrl'] as String;
      final s3Key = uploadData['s3Key'] as String;

      // Upload audio directly to S3
      await _apiService.uploadAudioToS3(uploadUrl, await file.readAsBytes());

      // Call API with S3 key
      await _callApi(audioS3Key: s3Key);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack(AppStrings.networkError);
    }
  }

  Future<void> _callApi({String? text, String? audioS3Key}) async {
    final storage = context.read<StorageService>();
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.queryHealth(
        text: text ?? '',
        language: storage.language,
        conversationId: _conversationId,
      );

      _conversationId = result['conversationId'] as String?;
      final reply = result['text'] as String? ?? '';
      final audioUrl = result['audioUrl'] as String?;
      final isEmergency = result['isEmergency'] as bool? ?? false;

      setState(() {
        _messages.add(MessageModel.assistant(reply, audioUrl: audioUrl));
        _isEmergency = isEmergency;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
      _showSnack(AppStrings.networkError);
    }
  }

  Future<void> _getDoctorSummary() async {
    final storage = context.read<StorageService>();
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.queryHealth(
        text: 'generate summary',
        language: storage.language,
        conversationId: _conversationId,
        generateSummary: true,
      );
      final summary = result['doctorSummary'] as String? ?? '';
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Doctor Summary'),
            content: SingleChildScrollView(child: Text(summary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      _showSnack(AppStrings.genericError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addUserMessage(String text) {
    setState(() => _messages.add(MessageModel.user(text)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _EmptyState extends StatelessWidget {
  final void Function(String) onSuggestionTap;
  const _EmptyState({required this.onSuggestionTap});

  static const suggestions = [
    'मुझे बुखार है',
    'सिरदर्द हो रहा है',
    'पेट में दर्द है',
    'खाँसी और जुकाम है',
  ];

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety_outlined,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'अपने लक्षण बताएँ',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe your symptoms below or tap a suggestion',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((s) => ActionChip(
                        label: Text(s),
                        onPressed: () => onSuggestionTap(s),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.assistantBubble,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                child: LinearProgressIndicator(minHeight: 2),
              ),
              SizedBox(width: 8),
              Text('सोच रहा हूँ...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onVoiceStart;
  final VoidCallback onVoiceStop;

  const _InputBar({
    required this.controller,
    required this.isRecording,
    required this.isLoading,
    required this.onSend,
    required this.onVoiceStart,
    required this.onVoiceStop,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            VoiceButton(
              isRecording: isRecording,
              onStart: onVoiceStart,
              onStop: onVoiceStop,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: AppStrings.typeMessage,
                ),
                onSubmitted: (_) => onSend(),
                maxLines: null,
                maxLength: 1000,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: isLoading ? null : onSend,
              icon: const Icon(Icons.send_rounded),
              color: AppColors.primary,
              iconSize: 28,
            ),
          ],
        ),
      );
}
