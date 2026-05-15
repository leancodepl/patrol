import 'dart:async';
import 'dart:io' as io;

import 'package:logging/logging.dart';
import 'package:patrol_cli/patrol_cli.dart';

/// How the session should interpret a test backend exit signal.
enum ExitInterpretation {
  /// Tests completed successfully.
  success,

  /// Tests failed.
  failure,

  /// Signal should be suppressed (e.g. stale callback during hot restart).
  suppress,
}

/// Platform-specific session behavior for patrol develop.
///
/// Mobile and web platforms have different lifecycle semantics:
/// - Mobile develop sessions stay alive for hot restart; any backend exit
///   while tests are running implies failure.
/// - Web develop sessions exit normally after tests complete; the exit result
///   determines success or failure.
abstract interface class PlatformSessionBehavior {
  /// Interpret a backend exit signal while tests are running.
  ExitInterpretation interpretTestCompletion(
    TestCompletionResult result, {
    required bool isHotRestarting,
  });

  /// Whether hot restart produces stale completion callbacks that must be
  /// suppressed for a brief window after the restart command is sent.
  bool get suppressesStaleCallbacksOnRestart;

  /// Perform platform-specific cleanup when the session ends.
  Future<void> cleanup(DevelopService? service);
}

/// Mobile behavior: a backend exit while tests are running always means
/// failure, because mobile develop sessions stay alive for hot restart.
class MobilePlatformBehavior implements PlatformSessionBehavior {
  const MobilePlatformBehavior();

  @override
  ExitInterpretation interpretTestCompletion(
    TestCompletionResult result, {
    required bool isHotRestarting,
  }) =>
      ExitInterpretation.failure;

  @override
  bool get suppressesStaleCallbacksOnRestart => false;

  @override
  Future<void> cleanup(DevelopService? service) async {}
}

/// Web behavior: the backend exits normally after tests complete, so the
/// exit result determines success. During hot restart, stale callbacks from
/// the dying process are suppressed.
class WebPlatformBehavior implements PlatformSessionBehavior {
  const WebPlatformBehavior();

  static final _logger = Logger('WebPlatformBehavior');

  @override
  ExitInterpretation interpretTestCompletion(
    TestCompletionResult result, {
    required bool isHotRestarting,
  }) {
    if (isHotRestarting) {
      return ExitInterpretation.suppress;
    }
    return result.success
        ? ExitInterpretation.success
        : ExitInterpretation.failure;
  }

  @override
  bool get suppressesStaleCallbacksOnRestart => true;

  @override
  Future<void> cleanup(DevelopService? service) async {
    // Kill the Flutter web server process if it's still running.
    // In the MCP quit path, the 'Q' stdin handler in WebTestBackend calls
    // exit(0) which is intercepted — the develop() finally block never runs,
    // leaving the Flutter process (and its child Chrome) orphaned.
    final flutterProcess = service?.webFlutterProcess;
    if (flutterProcess == null) {
      return;
    }

    _logger.fine('Killing Flutter web server process...');
    flutterProcess.kill();
    try {
      await flutterProcess.exitCode.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      flutterProcess.kill(io.ProcessSignal.sigkill);
      await flutterProcess.exitCode;
    }
  }
}
