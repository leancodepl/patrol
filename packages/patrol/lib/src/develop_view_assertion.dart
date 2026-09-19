import 'package:meta/meta.dart';

/// Whether [exception] is the engine assertion from
/// [flutter/flutter#182377](https://github.com/flutter/flutter/issues/182377),
/// raised for every frame requested after a hot restart disposed the view
/// without completing.
@internal
bool isDisposedViewAssertion(Object? exception) => exception
    .toString()
    .contains('Trying to render a disposed EngineFlutterView');
