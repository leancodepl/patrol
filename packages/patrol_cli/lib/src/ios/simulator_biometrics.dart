import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';

/// Simulates Face ID and Touch ID on a booted iOS simulator.
///
/// Posts the same Darwin notifications as the simulator's Features > Face ID
/// and Features > Touch ID menus. The notification names are not public API.
class SimulatorBiometrics {
  SimulatorBiometrics({
    required String deviceId,
    required ProcessManager processManager,
    required Logger logger,
  }) : _deviceId = deviceId,
       _processManager = processManager,
       _logger = logger;

  final String _deviceId;
  final ProcessManager _processManager;
  final Logger _logger;

  static const enrollmentNotification =
      'com.apple.BiometricKit.enrollmentChanged';

  // A simulator has a single sensor, which ignores the other one's
  // notifications, so posting both works for Face ID and Touch ID simulators.
  static const _sensors = ['pearl', 'fingerTouch'];

  /// Enrolls a face (or finger), or removes it when [enrolled] is false.
  Future<void> setEnrolled(bool enrolled) async {
    _logger.detail('Setting biometric enrollment of $_deviceId to $enrolled');

    await _notifyutil([
      '-s',
      enrollmentNotification,
      if (enrolled) '1' else '0',
    ]);
    await _notifyutil(['-p', enrollmentNotification]);
  }

  /// Answers a pending biometric prompt with a matching face (or finger), or a
  /// non-matching one when [match] is false.
  Future<void> sendMatch(bool match) async {
    _logger.detail(
      'Sending biometric ${match ? '' : 'non-'}match to $_deviceId',
    );

    final suffix = match ? 'match' : 'nomatch';
    for (final sensor in _sensors) {
      await _notifyutil(['-p', 'com.apple.BiometricKit_Sim.$sensor.$suffix']);
    }
  }

  Future<void> _notifyutil(List<String> arguments) async {
    final command = [
      'xcrun',
      'simctl',
      'spawn',
      _deviceId,
      'notifyutil',
      ...arguments,
    ];
    final result = await _processManager.run(command);
    if (result.exitCode != 0) {
      throw SimulatorBiometricsException(
        '`${command.join(' ')}` failed: ${result.stdErr}',
      );
    }
  }
}

class SimulatorBiometricsException implements Exception {
  const SimulatorBiometricsException(this.message);

  final String message;

  @override
  String toString() => 'SimulatorBiometricsException: $message';
}
