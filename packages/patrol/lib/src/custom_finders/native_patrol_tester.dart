import 'package:patrol/patrol.dart';

class NativePatrolTester extends PatrolTester {
  /// Creates a new [NativePatrolTester] which wraps [tester].
  const NativePatrolTester({
    required super.tester,
    required super.config,
    required this.native,
  });

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  final NativeAutomator native;
}
