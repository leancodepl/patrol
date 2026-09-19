import 'package:flutter/foundation.dart';

/// Whether [exception] is the engine assertion from
/// [flutter/flutter#182377](https://github.com/flutter/flutter/issues/182377),
/// raised for every frame requested after a hot restart disposed the view
/// without completing.
@internal
bool isDisposedViewAssertion(Object? exception) => exception
    .toString()
    .contains('Trying to render a disposed EngineFlutterView');

var _reported = false;

/// Explains a destroyed app view once per program run. Both the assertion
/// handler and the develop idle loop notice it, and only one of them will on
/// any given failure.
@internal
void reportDeadViewOnce() {
  if (_reported) {
    return;
  }
  _reported = true;
  debugPrint(
    'Patrol: a hot restart destroyed the app view without completing '
    '(flutter/flutter#182377). Reload the page, or press "r" in the terminal '
    'to restart. Further render assertions are suppressed.',
  );
}
