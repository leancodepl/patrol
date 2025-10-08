import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/android/video_recording_config.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:process/process.dart';

/// Manages video recording for individual test cases.
class VideoRecordingManager {
  VideoRecordingManager({
    required ProcessManager processManager,
    required Directory rootDirectory,
    required Logger logger,
    required VideoRecordingConfig config,
    required Device device,
    required DisposeScope scope,
  }) : _processManager = processManager,
       _rootDirectory = rootDirectory,
       _logger = logger,
       _config = config,
       _device = device,
       _scope = scope;

  final ProcessManager _processManager;
  final Directory _rootDirectory;
  final Logger _logger;
  final VideoRecordingConfig _config;
  final Device _device;
  final DisposeScope _scope;

  Process? _currentRecordingProcess;
  String? _currentVideoFilename;
  String? _currentDeviceVideoPath;
  String? _currentTestName;

  /// Starts video recording for a test case.
  Future<void> startRecording(String testName) async {
    if (!_config.enabled) {
      return;
    }

    // Stop any existing recording first
    await stopRecording();

    _currentTestName = testName;
    _currentVideoFilename = _config.generateVideoFilename(
      deviceId: _device.id,
      testName: _sanitizeTestName(testName),
    );
    _currentDeviceVideoPath = _config.getDeviceVideoPath(
      _currentVideoFilename!,
    );

    _logger
      ..detail('Starting video recording for test: $testName')
      ..detail('Video file: $_currentVideoFilename');

    try {
      _currentRecordingProcess = await _processManager.start([
        'adb',
        if (_device.id.isNotEmpty) ...['-s', _device.id],
        'shell',
        'screenrecord',
        if (_config.size != null) ...['--size', _config.size!],
        if (_config.bitRate != null) ...[
          '--bit-rate',
          _config.bitRate.toString(),
        ],
        if (_config.timeLimit != 180) ...[
          '--time-limit',
          _config.timeLimit.toString(),
        ],
        _currentDeviceVideoPath!,
      ], runInShell: true);
      _currentRecordingProcess!.disposedBy(_scope);

      // Give the recording a moment to start
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } catch (err) {
      _logger.warn('Failed to start video recording for test $testName: $err');
      _currentRecordingProcess = null;
      _currentVideoFilename = null;
      _currentDeviceVideoPath = null;
      _currentTestName = null;
    }
  }

  /// Stops video recording and saves the file.
  Future<void> stopRecording() async {
    if (_currentRecordingProcess == null ||
        _currentVideoFilename == null ||
        _currentDeviceVideoPath == null) {
      return;
    }

    final testName = _currentTestName ?? 'unknown_test';
    _logger.detail('Stopping video recording for test: $testName');

    // Stop the recording process
    _currentRecordingProcess!.kill();

    // Wait a moment for the file to be finalized
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    try {
      // Create output directory if it doesn't exist
      final outputDir = _rootDirectory.childDirectory(_config.outputDirectory);
      if (!outputDir.existsSync()) {
        outputDir.createSync(recursive: true);
      }

      // Pull the video file from device
      final localVideoPath = outputDir.childFile(_currentVideoFilename!).path;
      final pullResult = await _processManager.run([
        'adb',
        if (_device.id.isNotEmpty) ...['-s', _device.id],
        'pull',
        _currentDeviceVideoPath!,
        localVideoPath,
      ], runInShell: true);

      if (pullResult.exitCode != 0) {
        throw Exception('Failed to pull video file: ${pullResult.stderr}');
      }

      // Clean up the file from device
      try {
        final removeResult = await _processManager.run([
          'adb',
          if (_device.id.isNotEmpty) ...['-s', _device.id],
          'shell',
          'rm',
          _currentDeviceVideoPath!,
        ], runInShell: true);

        if (removeResult.exitCode != 0) {
          _logger.detail(
            'Failed to remove video file from device: ${removeResult.stderr}',
          );
        }
      } catch (err) {
        _logger.detail('Failed to remove video file from device: $err');
      }

      _logger.info(
        'Video recording saved for test "$testName": $localVideoPath',
      );
    } catch (err) {
      _logger.warn('Failed to save video recording for test "$testName": $err');
    } finally {
      // Reset state
      _currentRecordingProcess = null;
      _currentVideoFilename = null;
      _currentDeviceVideoPath = null;
      _currentTestName = null;
    }
  }

  /// Sanitizes test name for use in filename.
  String _sanitizeTestName(String testName) {
    // Remove file path prefix and keep only the actual test name
    final parts = testName.split(' ');
    if (parts.length > 1) {
      // Skip the first part which is usually the file path
      return parts.skip(1).join(' ').replaceAll(RegExp(r'[^\w\-_\s]'), '_');
    }
    return testName.replaceAll(RegExp(r'[^\w\-_\s]'), '_');
  }

  /// Handles test entry events from PatrolLogReader.
  void handleTestEntry(TestEntry testEntry) {
    switch (testEntry.status) {
      case TestEntryStatus.start:
        startRecording(testEntry.name);
      case TestEntryStatus.success:
      case TestEntryStatus.failure:
        stopRecording();
      case TestEntryStatus.skip:
        // No recording needed for skipped tests
        break;
    }
  }

  /// Cleanup method to stop any ongoing recording.
  Future<void> dispose() async {
    await stopRecording();
  }
}
