import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'serialized_finder.dart';

const _channelName = 'patrol_cross_origin';

/// Controller-side handle to a "remote app" window opened via `window.open`.
///
/// Use [RemoteApp.open] to create one. All interactions are postMessage RPC
/// against the remote app's [initPatrolRemoteApp] wrapper. The remote app may
/// navigate top-level to a different origin between calls; the same
/// [RemoteApp] handle remains valid because `window.opener` is preserved
/// across navigations in the browsing context.
///
/// Most users won't call this directly — they use `patrolRemoteTest(...)`
/// which constructs a [RemoteApp] and exposes it via the test's `$` tester.
class RemoteApp {
  RemoteApp._(this._appWindow) {
    _registerListener();
  }

  final web.Window _appWindow;
  int _nextId = 1;
  final Map<String, Completer<Object?>> _pending = {};
  final List<Completer<String>> _readyWaiters = [];

  /// Opens [url] in a new tab and waits for the remote app's first
  /// `patrol_ready` broadcast before returning.
  static Future<RemoteApp> open(
    String url, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final win = web.window.open(url, 'patrol_remote_app');
    if (win == null) {
      throw StateError(
        'window.open returned null — popup blocker active or no browsing context',
      );
    }
    final app = RemoteApp._(win);
    await app.waitForReady(timeout: timeout);
    return app;
  }

  void _registerListener() {
    final listener = ((web.Event event) {
      _handleMessage(event as web.MessageEvent);
    }).toJS;
    web.window.addEventListener('message', listener);
  }

  void _handleMessage(web.MessageEvent event) {
    final raw = event.data?.dartify();
    if (raw is! Map) return;
    final msg = raw.cast<Object?, Object?>();
    if (msg['channel'] != _channelName) return;

    final type = msg['type'] as String?;
    if (type == 'patrol_ready') {
      final origin = msg['origin'] as String;
      if (_readyWaiters.isNotEmpty) {
        _readyWaiters.removeAt(0).complete(origin);
      }
      return;
    }
    if (type == 'result') {
      final id = msg['id'] as String?;
      if (id == null) return;
      final completer = _pending.remove(id);
      if (completer == null) return;
      if (msg['ok'] == true) {
        completer.complete(msg['value']);
      } else {
        completer.completeError(
          Exception('Remote app command failed: ${msg['error']}'),
        );
      }
      return;
    }
  }

  Future<T> _send<T>(
    String type, {
    SerializedFinder? finder,
    Map<String, Object?>? args,
    Duration timeout = const Duration(seconds: 15),
  }) {
    final id = '${_nextId++}';
    final completer = Completer<Object?>();
    _pending[id] = completer;
    _appWindow.postMessage(
      <String, Object?>{
        'channel': _channelName,
        'id': id,
        'type': type,
        if (finder != null) 'finder': finder.toJson(),
        if (args != null) 'args': args,
      }.jsify(),
      '*'.toJS,
    );
    return completer.future
        .timeout(timeout, onTimeout: () {
          _pending.remove(id);
          throw TimeoutException(
            'Remote app command "$type" timed out',
            timeout,
          );
        })
        .then((v) => v as T);
  }

  /// Waits for the next `patrol_ready` broadcast from the remote app.
  ///
  /// If [expectedOrigin] is provided, throws if the reported origin doesn't
  /// match. Useful after triggering a top-level navigation to verify the
  /// remote app landed where expected.
  Future<String> waitForReady({
    String? expectedOrigin,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final completer = Completer<String>();
    _readyWaiters.add(completer);
    final origin = await completer.future.timeout(
      timeout,
      onTimeout: () {
        _readyWaiters.remove(completer);
        throw TimeoutException(
          'Timed out waiting for remote app patrol_ready'
          '${expectedOrigin != null ? ' from $expectedOrigin' : ''}',
          timeout,
        );
      },
    );
    if (expectedOrigin != null && origin != expectedOrigin) {
      throw StateError(
        'Expected remote app to land on $expectedOrigin, got $origin',
      );
    }
    return origin;
  }

  Future<String> ping() => _send<String>('ping');

  /// Accepts the same matching kinds as `PatrolTester.call()` (the `$`
  /// operator): [SerializedFinder], `PatrolFinder`, `Finder`, [ValueKey],
  /// [Symbol], or [String]. Anything else throws.
  Future<int> findCount(Object matching) =>
      _send<int>('findCount', finder: serializeMatching(matching));

  /// See [findCount] for accepted matching kinds.
  Future<void> tap(Object matching) =>
      _send<Object?>('tap', finder: serializeMatching(matching)).then((_) {});

  /// See [findCount] for accepted matching kinds.
  Future<void> enterText(Object matching, String text) =>
      _send<Object?>(
        'enterText',
        finder: serializeMatching(matching),
        args: {'text': text},
      ).then((_) {});

  void close() {
    _appWindow.close();
  }
}
