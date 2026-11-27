import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_config.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_manager.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:process/process.dart';

/// Records each test case on an iOS simulator with `simctl io recordVideo`.
///
/// Used by `patrol develop` only. `patrol test` takes the recordings XCTest
/// makes itself out of the `.xcresult` instead (see
/// `IOSTestBackend.extractAttachments`), which also covers physical devices;
/// develop can't, because the session is killed before XCTest finalizes them.
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

    if (_device.real) {
      _logger.warn(
        'Video recording is not supported by `patrol develop` on physical iOS '
        'devices; use `patrol test --record-video` instead.',
      );
      return;
    }

    _currentTestName = testName;
    _currentVideoFilename = _config.generateVideoFilename(
      deviceId: _device.id,
      testName: testName,
    );

    _logger
      ..detail('Starting iOS video recording for test: $testName')
      ..detail('Video file: $_currentVideoFilename')
      ..detail('Device ID: ${_device.id}')
      ..detail('Device name: ${_device.name}');

    try {
      _logger.detail('Starting simulator recording with xcrun simctl...');
      await _startSimulatorRecording();

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

    // A simulator allows only one recording at a time; clear a stale one first.
    await _clearStaleSimulatorRecording();

    try {
      // No shell: the stop SIGINT must reach `simctl` directly, not a wrapper.
      _currentRecordingProcess = await _processManager.start(command);
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

  /// SIGINT a leftover `recordVideo` from an interrupted run that still holds
  /// this simulator's recording slot. Scoped to the device id, so it never
  /// touches macOS screen recordings or other simulators.
  Future<void> _clearStaleSimulatorRecording() async {
    try {
      final result = await _processManager.run([
        'pkill',
        '-INT',
        '-f',
        'simctl io ${_device.id} recordVideo',
      ]);
      // pkill exits 0 only when it signalled a matching process.
      if (result.exitCode == 0) {
        _logger.detail('Stopped a stale simctl recording for ${_device.id}');
        // Give it a moment to release the recording slot.
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    } catch (err) {
      _logger.detail('Could not check for a stale simctl recording: $err');
    }
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
      // Send SIGINT (not SIGTERM) so `simctl` finalizes the .mp4 on exit.
      _logger.detail(
        'Sending SIGINT to xcrun simctl process for proper termination...',
      );
      _currentRecordingProcess!.kill(io.ProcessSignal.sigint);

      // Force kill if it doesn't exit shortly (a SIGINT during startup is
      // ignored), so a stuck recording can't hang the run.
      _logger.detail('Waiting for xcrun simctl process to exit...');
      final process = _currentRecordingProcess!;
      final exitCode = await process.exitCode.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.warn(
            'xcrun simctl recordVideo did not exit after SIGINT; force '
            'killing it. The video for this test may be incomplete.',
          );
          process.kill(io.ProcessSignal.sigkill);
          return -1;
        },
      );
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
}
