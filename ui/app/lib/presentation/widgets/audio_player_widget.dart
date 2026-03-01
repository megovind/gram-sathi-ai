import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/app_colors.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final VoidCallback? onAutoPlayStarted;
  final String playLabel;
  final String pauseLabel;
  final Color? tintColor;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.onAutoPlayStarted,
    this.playLabel = 'Play',
    this.pauseLabel = 'Pause',
    this.tintColor,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) setState(() => _isPlaying = false);
      }
    });
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoPlay());
    }
  }

  Future<void> _startAutoPlay() async {
    if (!mounted) return;
    widget.onAutoPlayStarted?.call();
    await _toggle();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _player.setUrl(widget.url);
      await _player.play();
      setState(() => _isPlaying = true);
    } catch (_) {
      // silently fail — audio is optional
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: widget.tintColor ?? AppColors.primary,
                size: 22,
              ),
            const SizedBox(width: 6),
            Text(
              _isPlaying ? widget.pauseLabel : widget.playLabel,
              style: TextStyle(
                color: widget.tintColor ?? AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
