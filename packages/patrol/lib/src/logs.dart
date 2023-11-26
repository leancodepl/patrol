import 'package:meta/meta.dart';

final _runKey = Object().hashCode.toRadixString(16).padLeft(4, '0');

/// Logs a message with a tag that's constant in the single app process
/// instance.
///
/// Helps to differentiate same logs that happen in different app process runs.
@internal
void patrolDebug(String message) {
  // TODO: Enable only if debug dart define is passed
  // ignore: avoid_print
  print('PATROL_DEBUG($_runKey): $message');
}
