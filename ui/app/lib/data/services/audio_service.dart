import 'dart:io';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;

  // ── Recording ─────────────────────────────────────────────

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    _currentRecordingPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.m4a');

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: _currentRecordingPath!,
    );
  }

  Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return File(path);
  }

  bool get isRecording => _recorder.isRecording() as bool;

  // ── Playback ──────────────────────────────────────────────

  Future<void> playFromUrl(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> stopPlayback() async {
    await _player.stop();
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get isPlaying => _player.playing;

  // ── Cleanup ───────────────────────────────────────────────

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
