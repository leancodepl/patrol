import 'package:maestro_test/maestro_test.dart';

/// Indicates that something went wrong with [MaestroFinder].
class MaestroFinderException implements Exception {
  /// Creates a new [MaestroFinderException].
  const MaestroFinderException(this.finder);

  /// Finder which caused the exception.
  final MaestroFinder finder;
}

/// Indicates that [MaestroFinder] did not find anything in the allowed time and
/// timed out.
class MaestroFinderFoundNothingException extends MaestroFinderException {
  /// Creates a new [MaestroFinderFoundNothingException] with [finder] which
  /// could not find any widget.
  const MaestroFinderFoundNothingException({
    required MaestroFinder finder,
  }) : super(finder);

  @override
  String toString() => 'Could not find $finder';
}
