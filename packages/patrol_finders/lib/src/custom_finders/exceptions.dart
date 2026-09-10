import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

/// Thrown when a Patrol action with a [description] fails.
///
/// Preserves the underlying [cause] while surfacing the user-provided step
/// description, e.g. `failed on: Clicking payment button to submit`.
class PatrolStepException implements Exception {
  /// Creates a new [PatrolStepException].
  PatrolStepException({required this.description, required this.cause});

  /// User-provided description of what the action was trying to do.
  final String description;

  /// Original exception thrown by the action.
  final Object cause;

  @override
  String toString() => 'failed on: $description\n$cause';
}

/// Thrown when some Patrol method fails to complete within the allowed time.
class PatrolTimeoutException extends TimeoutException {
  /// Creates a new [PatrolTimeoutException].
  PatrolTimeoutException({
    required this.finder,
    required String message,
    required Duration duration,
  }) : super(message, duration);

  /// Finder which caused the exception.
  final Finder finder;
}

/// Thrown when [PatrolFinder] did not find anything in the allowed time and
/// timed out.
class WaitUntilExistsTimeoutException extends PatrolTimeoutException {
  /// Creates a new [WaitUntilExistsTimeoutException] with [finder] which did
  /// not find any widget and timed out.
  WaitUntilExistsTimeoutException({
    required super.finder,
    required super.duration,
  }) : super(message: 'Finder "$finder" did not find any widgets');
}

/// Indicates that [PatrolFinder] did not find anything in the allowed time and
/// timed out.
class WaitUntilVisibleTimeoutException extends PatrolTimeoutException {
  /// Creates a new [WaitUntilVisibleTimeoutException] with [finder] which did
  /// not find any visible widget and timed out.
  WaitUntilVisibleTimeoutException({
    required super.finder,
    required super.duration,
  }) : super(
         message:
             'Finder "$finder" did not find any visible (i.e. hit-testable) widgets',
       );
}
