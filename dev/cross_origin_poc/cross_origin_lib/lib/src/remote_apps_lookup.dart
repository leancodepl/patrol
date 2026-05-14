import 'dart:convert';

/// Runtime lookup for remote app origins.
///
/// The orchestrator (`cross_origin_lib:orchestrate`) compiles the controller
/// with a `--dart-define=PATROL_REMOTE_APPS=<json>` flag containing a JSON
/// object `{ "name": "origin_url", ... }`. This class decodes that JSON once
/// and exposes name-to-origin lookup.
///
/// Example:
/// ```dart
/// final origin = RemoteApps.origin('panel'); // http://localhost:8082
/// ```
abstract final class RemoteApps {
  static const _envJson = String.fromEnvironment(
    'PATROL_REMOTE_APPS',
    defaultValue: '{}',
  );

  static final Map<String, String> _table = () {
    final decoded = jsonDecode(_envJson);
    if (decoded is! Map) {
      throw StateError(
        'PATROL_REMOTE_APPS must decode to a JSON object, got ${decoded.runtimeType}',
      );
    }
    return decoded.map((k, v) => MapEntry(k as String, v as String));
  }();

  /// Returns the origin URL configured for the remote app named [name].
  ///
  /// Throws if no app with that name was declared in `patrol.remote.apps`
  /// in the controller's `pubspec.yaml`.
  static String origin(String name) {
    final url = _table[name];
    if (url == null) {
      throw StateError(
        'No remote app named "$name" configured. '
        'Configured apps: ${_table.keys.toList()}. '
        'Declare it under `patrol.remote.apps` in the controller pubspec.yaml.',
      );
    }
    return url;
  }

  /// All configured remote app names.
  static Iterable<String> get names => _table.keys;
}
