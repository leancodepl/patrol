/// Thrown when a native action fails.
class PatrolActionException implements Exception {
  /// Creates a new [PatrolActionException].
  PatrolActionException(this.message);

  /// Message that the native part returned.
  String message;

  @override
  String toString() => 'Patrol action failed: $message';
}
