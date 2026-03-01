import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/message_model.dart';
import '../../../data/services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';
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
  int _autoPlayAudioIndex = -1;

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
    final storage = context.watch<StorageService>();
    final strings = AppStrings.forLanguage(storage.language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.healthTitle)),
      body: Column(
        children: [
          // Emergency banner
          if (_isEmergency)
            Container(
              width: double.infinity,
              color: AppColors.emergency,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.emergencyBanner,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(strings: strings, onSuggestionTap: _sendText)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) {
                        return _TypingIndicator(strings: strings);
                      }
                      final msg = _messages[i];
                      final shouldAutoPlay = msg.audioUrl != null && i == _autoPlayAudioIndex;

                      Widget? audioWidget;
                      if (msg.audioUrl != null) {
                        audioWidget = AudioPlayerWidget(
                          url: msg.audioUrl!,
                          autoPlay: shouldAutoPlay,
                          onAutoPlayStarted: shouldAutoPlay
                              ? () => setState(() => _autoPlayAudioIndex = -1)
                              : null,
                          playLabel: strings.playAudio,
                          pauseLabel: strings.pauseAudio,
                        );
                      } else if (msg.isVoiceMessage && msg.localFilePath != null && !msg.isUploading) {
                        audioWidget = AudioPlayerWidget(
                          url: Uri.file(msg.localFilePath!).toString(),
                          playLabel: strings.playAudio,
                          pauseLabel: strings.pauseAudio,
                          tintColor: Colors.white,
                        );
                      }

                      return MessageBubble(
                        message: msg,
                        audioWidget: audioWidget,
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
                label: Text(strings.getDoctorSummary),
              ),
            ),

          // Input bar
          _InputBar(
            strings: strings,
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
    final result = await _audioService.requestMicPermission();
    if (result == MicPermissionResult.granted) {
      await _audioService.startRecording();
      setState(() => _isRecording = true);
      return;
    }
    if (!mounted) return;
    if (result == MicPermissionResult.permanentlyDenied) {
      _showMicSettingsDialog();
    } else {
      _showSnack(AppStrings.forLanguage(context.read<StorageService>().language).micPermissionDenied);
    }
  }

  void _showMicSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Microphone Access Required'),
        content: const Text(
          'GramSathi needs microphone access to record your voice.\n\n'
          'Please go to Settings → GramSathi → Microphone and enable it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _stopRecordingAndSend() async {
    setState(() => _isRecording = false);
    final file = await _audioService.stopRecording();
    if (file == null) return;

    // Show user voice bubble + typing indicator immediately
    final voiceIndex = _messages.length;
    setState(() {
      _messages.add(MessageModel.voiceUser(filePath: file.path));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final uploadData = await _apiService.getAudioUploadUrl(
        fileName: file.path.split('/').last,
        contentType: AppConstants.defaultAudioContentType,
      );
      final uploadUrl = uploadData['uploadUrl'] as String;
      final s3Key = uploadData['s3Key'] as String;

      await _apiService.uploadAudioToS3(uploadUrl, await file.readAsBytes());

      final result = await _callApi(audioS3Key: s3Key);

      // Replace voice bubble with transcribed text returned by the server
      final userText = result?['userText'] as String?;
      if (voiceIndex < _messages.length) {
        setState(() {
          _messages[voiceIndex] = _messages[voiceIndex].copyWith(
            content: userText ?? '',
            isVoiceMessage: userText == null || userText.isEmpty,
            isUploading: false,
          );
        });
      }
    } catch (e) {
      if (kDebugMode) print('[Audio Error] $e');
      final strings = AppStrings.forLanguage(context.read<StorageService>().language);
      final errMsg = _extractErrorMessage(e, strings);
      setState(() {
        _isLoading = false;
        _messages.add(MessageModel.assistant('${strings.aiErrorPrefix}$errMsg'));
      });
      _scrollToBottom();
    }
  }

  /// Silently attempt to get the device GPS position.
  /// Returns null if permission denied or location unavailable.
  Future<Position?> _getGpsPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _callApi({String? text, String? audioS3Key}) async {
    final storage = context.read<StorageService>();
    setState(() => _isLoading = true);

    // Fetch GPS silently — backend uses it for nearby clinic/pharmacy searches
    final position = await _getGpsPosition();

    try {
      final result = await _apiService.queryHealth(
        text: text,
        audioS3Key: audioS3Key,
        language: storage.language,
        conversationId: _conversationId,
        pincode: storage.lastSearchedPincode,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      _conversationId = result['conversationId'] as String?;
      final reply = result['text'] as String? ?? '';
      final audioUrl = result['audioUrl'] as String?;
      final isEmergency = result['isEmergency'] as bool? ?? false;

      setState(() {
        _messages.add(MessageModel.assistant(reply, audioUrl: audioUrl));
        _isEmergency = isEmergency;
        _isLoading = false;
        _autoPlayAudioIndex = audioUrl != null ? _messages.length - 1 : -1;
      });
      _scrollToBottom();
      return result;
    } catch (e) {
      final strings = AppStrings.forLanguage(context.read<StorageService>().language);
      final errMsg = _extractErrorMessage(e, strings);
      setState(() {
        _isLoading = false;
        _messages.add(MessageModel.assistant('${strings.aiErrorPrefix}$errMsg'));
      });
      _scrollToBottom();
      return null;
    }
  }

  String _extractErrorMessage(Object e, LocalizedStrings strings) {
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data['error'] != null) {
        return data['error'] as String;
      }
      if (data is String && data.isNotEmpty) return data;
    }
    return strings.networkError;
  }

  Future<void> _getDoctorSummary() async {
    final storage = context.read<StorageService>();
    setState(() => _isLoading = true);
    // Re-use the most recent user message so the backend has text to validate,
    // but only the generateSummary flag actually affects the response.
    final strings = AppStrings.forLanguage(context.read<StorageService>().language);
    final lastUserText = _messages
        .lastWhere((m) => m.isUser, orElse: () => MessageModel.user(strings.fallbackSymptomText))
        .content;
    try {
      final result = await _apiService.queryHealth(
        text: lastUserText,
        language: storage.language,
        conversationId: _conversationId,
        generateSummary: true,
        pincode: storage.lastSearchedPincode,
      ); // No GPS needed for doctor summary
      final summary = result['doctorSummary'] as String? ?? '';
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(strings.doctorSummaryTitle),
            content: SingleChildScrollView(child: Text(summary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.closeButton),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showSnack(_extractErrorMessage(e, AppStrings.forLanguage(context.read<StorageService>().language)));
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
  final LocalizedStrings strings;
  final void Function(String) onSuggestionTap;
  const _EmptyState({required this.strings, required this.onSuggestionTap});

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
              strings.describeSymptoms,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              strings.describeSymptomsSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: strings.healthSuggestions
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
  final LocalizedStrings strings;
  const _TypingIndicator({required this.strings});

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                child: LinearProgressIndicator(minHeight: 2),
              ),
              const SizedBox(width: 8),
              Text(strings.thinkingIndicator, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _InputBar extends StatelessWidget {
  final LocalizedStrings strings;
  final TextEditingController controller;
  final bool isRecording;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onVoiceStart;
  final VoidCallback onVoiceStop;

  const _InputBar({
    required this.strings,
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
                decoration: InputDecoration(
                  hintText: strings.typeMessage,
                ),
                onSubmitted: (_) => onSend(),
                maxLines: null,
                maxLength: AppConstants.maxTextInputLength,
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
