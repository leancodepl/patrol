import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

import 'serialized_finder.dart';

const _channelName = 'patrol_cross_origin';

bool _initialised = false;

/// Initialises this Flutter Web app as a Patrol "remote app" — drivable
/// from a controller window via `window.opener` postMessage RPC.
///
/// Call this once after `runApp(...)`.
///
/// Behaviour:
///   * Registers a `message` listener on this window. Messages with
///     `channel == 'patrol_cross_origin'` are interpreted as commands;
///     each command is executed against the live widget tree via
///     [LiveWidgetController] and a result is posted back to the sender.
///   * After the first frame (so the widget tree exists), posts a
///     `patrol_ready` message to `window.opener` (if any), telling the
///     controller that this origin is ready to receive commands.
void initPatrolRemoteApp() {
  if (_initialised) return;
  _initialised = true;

  _registerMessageListener();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _announceReady();
  });
}

void _registerMessageListener() {
  final listener = ((web.Event event) {
    _handleMessage(event as web.MessageEvent);
  }).toJS;
  web.window.addEventListener('message', listener);
}

Future<void> _handleMessage(web.MessageEvent event) async {
  final raw = event.data?.dartify();
  if (raw is! Map) return;
  final cmd = raw.cast<Object?, Object?>();
  if (cmd['channel'] != _channelName) return;
  final type = cmd['type'] as String?;
  // Ignore our own ready broadcast bouncing back.
  if (type == null || type == 'patrol_ready' || type == 'result') return;

  final id = cmd['id'] as String?;
  final source = event.source;

  // `tap` is special: a tap may trigger window.location.href in an
  // onPressed handler, which kills this Dart isolate before any subsequent
  // await resumes. Post the ack BEFORE firing the gesture so the opener
  // gets a reply even if we're about to die. The gesture itself runs
  // fire-and-forget on the JS event loop after this handler returns.
  if (type == 'tap') {
    try {
      final finderJson = (cmd['finder']! as Map).cast<String, Object?>();
      final finder = SerializedFinder.fromJson(finderJson).toFinder();
      _postResult(source, id: id, ok: true);
      LiveWidgetController(WidgetsBinding.instance).tap(finder).ignore();
    } catch (err, st) {
      _postResult(source, id: id, ok: false, error: '$err\n$st');
    }
    return;
  }

  try {
    final result = await _execute(type, cmd);
    _postResult(source, id: id, ok: true, value: result);
  } catch (err, st) {
    _postResult(source, id: id, ok: false, error: '$err\n$st');
  }
}

Future<Object?> _execute(String type, Map<Object?, Object?> cmd) async {
  final controller = LiveWidgetController(WidgetsBinding.instance);
  final finderJson = cmd['finder'];
  final finder = finderJson is Map
      ? SerializedFinder.fromJson(finderJson.cast<String, Object?>()).toFinder()
      : null;
  final args = (cmd['args'] as Map?)?.cast<String, Object?>();

  switch (type) {
    case 'ping':
      return 'pong';
    case 'findCount':
      return finder!.evaluate().length;
    case 'enterText':
      // LiveWidgetController has no enterText (it's on WidgetTester only).
      // For PoC: locate the TextField/EditableText and write directly to its
      // TextEditingController, then pump a frame. Production version should
      // synthesise real keyboard input via TestTextInput so onChanged fires
      // through the normal channel.
      final element = finder!.evaluate().first;
      final widget = element.widget;
      final text = args!['text']! as String;
      switch (widget) {
        case TextField(:final controller?):
          controller.text = text;
        case EditableText():
          widget.controller.text = text;
        default:
          throw StateError(
            'enterText: unsupported widget type ${widget.runtimeType}',
          );
      }
      await controller.pumpAndSettle();
      return null;
    default:
      throw ArgumentError('Unknown command type: $type');
  }
}

void _postResult(
  web.MessageEventSource? source, {
  required String? id,
  required bool ok,
  Object? value,
  String? error,
}) {
  final asWindow = source as web.Window?;
  if (asWindow == null) return;
  final payload = <String, Object?>{
    'channel': _channelName,
    'id': id,
    'type': 'result',
    'ok': ok,
    if (value != null) 'value': value,
    if (error != null) 'error': error,
  };
  asWindow.postMessage(payload.jsify(), '*'.toJS);
}

void _announceReady() {
  final opener = web.window.opener;
  if (opener == null) return;
  final openerWindow = opener as web.Window;
  openerWindow.postMessage(
    <String, Object?>{
      'channel': _channelName,
      'type': 'patrol_ready',
      'origin': web.window.location.origin,
    }.jsify(),
    '*'.toJS,
  );
}
