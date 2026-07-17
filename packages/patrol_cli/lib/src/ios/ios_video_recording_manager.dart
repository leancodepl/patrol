import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_config.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_manager.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:process/process.dart';

/// Manages video recording for individual test cases on iOS devices and simulators.
class IOSVideoRecordingManager extends VideoRecordingManager {
  IOSVideoRecordingManager({
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

  io.Process? _currentRecordingProcess;
  String? _currentVideoFilename;
  String? _currentTestName;

  @override
  Future<void> startRecording(String testName) async {
    if (!_config.enabled) {
      return;
    }

    // Stop any existing recording first
    await stopRecording();

    _currentTestName = testName;
    _currentVideoFilename = _config.generateVideoFilename(
      deviceId: _device.id,
      testName: sanitizeTestName(testName),
    );

    _logger
      ..detail('Starting iOS video recording for test: $testName')
      ..detail('Video file: $_currentVideoFilename')
      ..detail('Device ID: ${_device.id}')
      ..detail('Device is real: ${_device.real}')
      ..detail('Device name: ${_device.name}');

    try {
      if (_device.real) {
        // For real iOS devices, we need to use different approaches
        // This is more complex and may require additional tools
        _logger.warn(
          'Video recording for real iOS devices is not yet supported. '
          'Device: ${_device.name} (${_device.id})',
        );
        _startRealDeviceRecording();
      } else {
        // For iOS simulators, use xcrun simctl
        _logger.detail('Starting simulator recording with xcrun simctl...');
        await _startSimulatorRecording();
      }

      // Give the recording a moment to start and wait for the "Recording started" message
      await Future<void>.delayed(const Duration(milliseconds: 2000));
      _logger.detail('iOS video recording started successfully');
    } catch (err) {
      _logger.warn(
        'Failed to start iOS video recording for test $testName: $err',
      );
      _currentRecordingProcess = null;
      _currentVideoFilename = null;
      _currentTestName = null;
    }
  }

  /// Starts recording for iOS simulator using xcrun simctl.
  Future<void> _startSimulatorRecording() async {
    // Create output directory if it doesn't exist
    final outputDir = _rootDirectory.childDirectory(_config.outputDirectory);
    if (!outputDir.existsSync()) {
      _logger.detail('Creating video output directory: ${outputDir.path}');
      outputDir.createSync(recursive: true);
    }

    final localVideoPath = outputDir.childFile(_currentVideoFilename!).path;
    _logger.detail('Video will be saved to: $localVideoPath');

    // Ensure the video file has .mp4 extension for proper format
    final videoPath = localVideoPath.endsWith('.mp4')
        ? localVideoPath
        : '${localVideoPath.replaceAll(RegExp(r'\.[^.]*$'), '')}.mp4';

    final command = [
      'xcrun',
      'simctl',
      'io',
      _device.id,
      'recordVideo',
      '--codec=h264',
      '--force', // Force overwrite if file exists
      videoPath,
    ];

    _logger.detail('Executing command: ${command.join(' ')}');

    try {
      _currentRecordingProcess = await _processManager.start(
        command,
        runInShell: true,
      );
      _currentRecordingProcess!.disposedBy(_scope);

      // Listen to stderr for any errors
      _currentRecordingProcess!.stderr.listen((data) {
        final line = String.fromCharCodes(data).trim();
        if (line.isNotEmpty) {
          _logger.detail('xcrun simctl stderr: $line');
        }
      });

      _logger.detail('xcrun simctl process started successfully');
    } catch (err) {
      _logger.warn('Failed to start xcrun simctl process: $err');
      rethrow;
    }
  }

  /// Starts recording for real iOS device.
  /// Note: This is more complex and may require additional setup.
  void _startRealDeviceRecording() {
    // For real iOS devices, we could use:
    // 1. QuickTime Player automation (requires GUI)
    // 2. Third-party tools like tidevice or pymobiledevice3
    // 3. Xcode's built-in recording capabilities

    // For now, we'll log that real device recording is not yet implemented
    _logger.warn(
      'Video recording for real iOS devices is not yet implemented. '
      'Only iOS Simulator recording is currently supported.',
    );

    // We could implement this using tidevice if available:
    // tidevice screenshot --format png > screenshot.png
    // But for video, it's more complex and would require additional dependencies

    throw UnsupportedError(
      'Video recording for real iOS devices is not yet implemented',
    );
  }

  @override
  Future<void> stopRecording() async {
    if (_currentRecordingProcess == null || _currentVideoFilename == null) {
      _logger.detail('No active iOS recording to stop');
      return;
    }

    final testName = _currentTestName ?? 'unknown_test';
    _logger.detail('Stopping iOS video recording for test: $testName');

    try {
      if (_device.real) {
        // Handle real device recording stop
        await _stopRealDeviceRecording();
      } else {
        // For simulator, send SIGINT (Control+C equivalent) to stop recording gracefully
        _logger.detail(
          'Sending SIGINT to xcrun simctl process for proper termination...',
        );

        // Send SIGINT instead of SIGTERM for proper video finalization
        _currentRecordingProcess!.kill(io.ProcessSignal.sigint);

        // Wait for the process to finish and file to be written
        _logger.detail('Waiting for xcrun simctl process to exit...');
        final exitCode = await _currentRecordingProcess!.exitCode;
        _logger.detail('xcrun simctl process exited with code: $exitCode');

        // Try to ensure simulator state is stable after recording
        try {
          await _processManager.run([
            'xcrun',
            'simctl',
            'io',
            _device.id,
            'enumerate',
          ], runInShell: true);
          _logger.detail('Verified simulator IO state after recording');
        } catch (err) {
          _logger.detail('Could not verify simulator state: $err');
        }
      }

      final outputDir = _rootDirectory.childDirectory(_config.outputDirectory);
      final originalVideoPath = outputDir
          .childFile(_currentVideoFilename!)
          .path;

      // Use the same path logic as in recording to ensure consistency
      final actualVideoPath = originalVideoPath.endsWith('.mp4')
          ? originalVideoPath
          : '${originalVideoPath.replaceAll(RegExp(r'\.[^.]*$'), '')}.mp4';

      // Check if the video file was created successfully
      final videoFile = io.File(actualVideoPath);
      if (videoFile.existsSync()) {
        final fileSize = videoFile.lengthSync();
        _logger.detail('Video file exists with size: $fileSize bytes');

        if (fileSize > 0) {
          addSavedVideo(actualVideoPath);
          _logger.detail(
            'iOS video recording saved for test "$testName": $actualVideoPath',
          );
        } else {
          _logger.warn(
            'iOS video recording file is empty for test "$testName": $actualVideoPath',
          );
        }
      } else {
        _logger.warn(
          'iOS video recording file was not created for test "$testName": $actualVideoPath',
        );
      }
    } catch (err) {
      _logger.warn(
        'Failed to save iOS video recording for test "$testName": $err',
      );
    } finally {
      // Reset state
      _currentRecordingProcess = null;
      _currentVideoFilename = null;
      _currentTestName = null;
    }
  }

  /// Stops recording for real iOS device.
  Future<void> _stopRealDeviceRecording() async {
    // Implementation would depend on the recording method used
    // For now, this is a placeholder
    _currentRecordingProcess?.kill();
  }

}
