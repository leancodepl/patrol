import 'package:meta/meta.dart';

final runKey = Object().hashCode;

@internal
void patrolDebug(String message) {
  print('PATROL_DEBUG($runKey): $message');
}
