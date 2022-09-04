import 'dart:async';

import 'package:maestro_test/maestro_test.dart';

/// Thrown when some Maestro method fails to complete within the allowed time.
class MaestroTimeoutException extends TimeoutException {
  /// Creates a new [MaestroTimeoutException].
  MaestroTimeoutException({
    required this.finder,
    required String message,
    required Duration duration,
  }) : super(message, duration);

  /// Finder which caused the exception.
  final Finder finder;
}

/// Thrown when [MaestroFinder] did not find anything in the allowed time and
/// timed out.
class WaitUntilExistsTimedOutException extends MaestroTimeoutException {
  /// Creates a new [WaitUntilExistsTimedOutException] with [finder] which did
  /// not find any widget and timed out.
  WaitUntilExistsTimedOutException({
    required super.finder,
    required super.duration,
  }) : super(
          message: 'Finder $finder did not find any widgets',
        );
}

/// Indicates that [MaestroFinder] did not find anything in the allowed time and
/// timed out.
class WaitUntilVisibleTimedOutException extends MaestroTimeoutException {
  /// Creates a new [WaitUntilVisibleTimedOutException] with [finder] which did
  /// not find any visible widget and timed out.
  WaitUntilVisibleTimedOutException({
    required super.finder,
    required super.duration,
  }) : super(
          message: 'Finder $finder did not find any visible widgets',
        );
}
