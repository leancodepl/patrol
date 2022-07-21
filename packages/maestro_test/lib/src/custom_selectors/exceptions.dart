import 'package:maestro_test/maestro_test.dart';

/// Indicates that something went wrong with [MaestroFinder].
class MaestroFinderException implements Exception {
  /// Creates a new [MaestroFinderException] with [message].
  const MaestroFinderException(this.finder, this.message);

  /// Describes what went wrong.
  final String message;

  /// Finder which caused the exception.
  final MaestroFinder finder;
}

/// Indicates that [MaestroFinder] did not find anything in the allowed time and
/// timed out.
class MaestroFinderFoundNothingException extends MaestroFinderException {
  /// Creates a new [MaestroFinderFoundNothingException] with [message].
  const MaestroFinderFoundNothingException({
    required MaestroFinder finder,
    required String message,
  }) : super(finder, message);

  @override
  String toString() => 'Could not find $finder';
}
