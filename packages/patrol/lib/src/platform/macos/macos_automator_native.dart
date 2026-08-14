import 'package:http/http.dart' as http;
import 'package:patrol/patrol.dart' show PatrolActionException;
import 'package:patrol/src/platform/contracts/contracts.dart'
    show
        ConfigureRequest,
        IOSElementType,
        IOSTapRequest,
        IOSWaitUntilVisibleRequest;
import 'package:patrol/src/platform/contracts/ios_automator_client.dart';
import 'package:patrol/src/platform/contracts/mobile_automator_client.dart';
import 'package:patrol/src/platform/macos/macos_automator.dart'
    as macos_automator;
import 'package:patrol/src/platform/macos/macos_automator_config.dart';
import 'package:patrol/src/platform/selector.dart' show IOSSelector;
import 'package:patrol_log/patrol_log.dart';

/// Provides functionality to interact with native macOS UI.
///
/// Communicates over HTTP with the native automation server running in the
/// macOS UI test process. Reuses the shared Darwin (iOS-shaped) HTTP contracts
/// for `tap` / `waitUntilVisible`.
class MacOSAutomator implements macos_automator.MacOSAutomator {
  /// Creates a new [MacOSAutomator].
  MacOSAutomator({required MacOSAutomatorConfig config})
    : assert(
        config.connectionTimeout > config.findTimeout,
        'find timeout is longer than connection timeout',
      ),
      _config = config;

  final _patrolLog = PatrolLogWriter();
  final MacOSAutomatorConfig _config;

  MobileAutomatorClient? _mobileClientInstance;
  IosAutomatorClient? _iosClientInstance;

  MobileAutomatorClient get _mobileClient {
    final existing = _mobileClientInstance;
    if (existing != null) {
      return existing;
    }
    _config.logger('MobileAutomatorClient created, port: ${_config.port}');
    return _mobileClientInstance = MobileAutomatorClient(
      http.Client(),
      Uri.http('${_config.host}:${_config.port}'),
      timeout: _config.connectionTimeout,
    );
  }

  IosAutomatorClient get _iosClient {
    final existing = _iosClientInstance;
    if (existing != null) {
      return existing;
    }
    _config.logger('IosAutomatorClient created, port: ${_config.port}');
    return _iosClientInstance = IosAutomatorClient(
      http.Client(),
      Uri.http('${_config.host}:${_config.port}'),
      timeout: _config.connectionTimeout,
    );
  }

  @override
  String get resolvedAppId => _config.bundleId;

  Future<T> _wrapRequest<T>(
    String name,
    Future<T> Function() request, {
    bool enablePatrolLog = true,
  }) async {
    _config.logger('$name() started');
    final text =
        '${AnsiCodes.lightBlue}$name${AnsiCodes.reset} ${AnsiCodes.gray}(native)${AnsiCodes.reset}';

    if (enablePatrolLog) {
      _patrolLog.log(StepEntry(action: text, status: StepEntryStatus.start));
    }
    try {
      final result = await request();
      _config.logger('$name() succeeded');
      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.success),
        );
      }
      return result;
    } on MobileAutomatorClientException catch (err) {
      _config.logger('$name() failed');
      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      throw PatrolActionException(
        'MobileAutomatorClientException: $name() failed with $err',
      );
    } on IosAutomatorClientException catch (err) {
      _config.logger('$name() failed');
      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      throw PatrolActionException(
        'IosAutomatorClientException: $name() failed with $err',
      );
    } catch (err) {
      _config.logger('$name() failed');
      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> configure() async {
    const retries = 60;

    PatrolActionException? exception;
    for (var i = 0; i < retries; i++) {
      try {
        await _wrapRequest(
          'configure',
          () => _mobileClient.configure(
            ConfigureRequest(
              findTimeoutMillis: _config.findTimeout.inMilliseconds,
            ),
          ),
          enablePatrolLog: false,
        );
        exception = null;
        break;
      } on PatrolActionException catch (err) {
        _config.logger('configure() failed: (${err.message})');
        exception = err;
      }

      _config.logger('trying to configure() again in 1 second');
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    if (exception != null) {
      throw PatrolActionException(
        'configure() failed after $retries retries (${exception.message}',
      );
    }
  }

  @override
  Future<void> markPatrolAppServiceReady() async {
    await _wrapRequest(
      'markPatrolAppServiceReady',
      _mobileClient.markPatrolAppServiceReady,
      enablePatrolLog: false,
    );
  }

  @override
  Future<void> tap(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  }) async {
    await _wrapRequest('tap', () async {
      await _iosClient.tap(
        IOSTapRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }

  @override
  Future<void> waitUntilVisible(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  }) async {
    await _wrapRequest('waitUntilVisible', () async {
      await _iosClient.waitUntilVisible(
        IOSWaitUntilVisibleRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }

  @override
  Future<bool> isAlertVisible({Duration? timeout}) async {
    final effectiveTimeout = timeout ?? const Duration(seconds: 1);
    const types = [
      IOSElementType.dialog,
      IOSElementType.sheet,
      IOSElementType.alert,
    ];

    for (final type in types) {
      try {
        await waitUntilVisible(
          IOSSelector(elementType: type),
          timeout: effectiveTimeout,
        );
        return true;
      } on PatrolActionException {
        // Try the next macOS alert container type.
      }
    }
    return false;
  }

  @override
  Future<void> tapAlertButton(
    String label, {
    String? appId,
    Duration? timeout,
  }) {
    return tap(
      IOSSelector(text: label, elementType: IOSElementType.button),
      appId: appId,
      timeout: timeout,
    );
  }
}
