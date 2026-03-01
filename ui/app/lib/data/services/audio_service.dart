import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

enum MicPermissionResult { granted, denied, permanentlyDenied }

/// Handles microphone recording only.
/// Audio playback is handled independently by [AudioPlayerWidget],
/// which owns its own [AudioPlayer] instance per message bubble.
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();

  // ── Recording ─────────────────────────────────────────────

  Future<MicPermissionResult> requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) return MicPermissionResult.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MicPermissionResult.permanentlyDenied;
    }
    return MicPermissionResult.denied;
  }

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.m4a');

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );
  }

  Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return File(path);
  }

  Future<bool> get isRecording => _recorder.isRecording();

  // ── Cleanup ───────────────────────────────────────────────

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
