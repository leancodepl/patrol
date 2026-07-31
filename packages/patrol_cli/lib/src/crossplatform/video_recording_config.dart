/// Configuration for video recording during test execution.
class VideoRecordingConfig {
  const VideoRecordingConfig({
    required this.enabled,
    required this.outputDirectory,
    this.size,
    this.bitRate,
    this.timeLimit = 180, // Default Android screenrecord limit
  });

  /// Whether video recording is enabled.
  final bool enabled;

  /// Directory where videos will be saved.
  final String outputDirectory;

  /// Video recording size (e.g., "1280x720").
  final String? size;

  /// Video bit rate in bits per second.
  final int? bitRate;

  /// Maximum recording time in seconds (max: 180).
  final int timeLimit;

  /// Generates a unique filename for the video recording.
  String generateVideoFilename({
    required String deviceId,
    required String testName,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedTestName = testName.replaceAll(RegExp(r'[^\w\-]'), '_');
    final sanitizedDeviceId = deviceId.replaceAll(RegExp(r'[^\w\-]'), '_');
    return 'patrol_${sanitizedTestName}_${sanitizedDeviceId}_$timestamp.mp4';
  }

  /// Path on the Android device where the video will be temporarily stored.
  String getAndroidDeviceVideoPath(String filename) {
    return '/sdcard/$filename';
  }

  @override
  String toString() {
    return 'VideoRecordingConfig('
        'enabled: $enabled, '
        'outputDirectory: $outputDirectory, '
        'size: $size, '
        'bitRate: $bitRate, '
        'timeLimit: $timeLimit'
        ')';
  }
}
