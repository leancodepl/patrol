/// Configuration for Android video recording during test execution.
class VideoRecordingConfig {
  const VideoRecordingConfig({
    required this.enabled,
    required this.outputDirectory,
    this.size,
    this.bitRate,
    this.timeLimit = 180, // Default Android screenrecord limit
  });

  /// Creates a VideoRecordingConfig from command line arguments.
  factory VideoRecordingConfig.fromArgs({
    required bool recordVideo,
    required String videoOutputDir,
    String? videoSize,
    String? videoBitRate,
  }) {
    return VideoRecordingConfig(
      enabled: recordVideo,
      outputDirectory: videoOutputDir,
      size: videoSize,
      bitRate: videoBitRate != null ? int.tryParse(videoBitRate) : null,
    );
  }

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
    final sanitizedTestName = testName.replaceAll(RegExp(r'[^\w\-_]'), '_');
    final sanitizedDeviceId = deviceId.replaceAll(RegExp(r'[^\w\-_]'), '_');
    return 'patrol_${sanitizedTestName}_${sanitizedDeviceId}_$timestamp.mp4';
  }

  /// Path on the Android device where the video will be temporarily stored.
  String getDeviceVideoPath(String filename) {
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
