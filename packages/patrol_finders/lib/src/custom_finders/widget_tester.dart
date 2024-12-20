/// This file overrides the internal implementation of [WidgetTester]
// ignore_for_file: implementation_imports
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:flutter/src/gestures/hit_test.dart';
import 'package:flutter/src/rendering/layer.dart';
import 'package:flutter/src/rendering/object.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter/src/semantics/semantics.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter_test/flutter_test.dart';

// This is a temporary class made for patch mixins to work
abstract class _PWT implements WidgetTester {
  const _PWT();
}

/// Wraps Flutter [WidgetTester] class to
/// allow applying custom patches (e.g. see [_ShowKeyboardPatch])
class PatrolWidgetTester extends _PWT with _ShowKeyboardPatch {
  /// Wraps [tester] with custom patch logic
  const PatrolWidgetTester(WidgetTester tester) : _tester = tester;

  final WidgetTester _tester;

  @override
  Iterable<Element> get allElements => _tester.allElements;

  @override
  Iterable<RenderObject> get allRenderObjects => _tester.allRenderObjects;

  @override
  Iterable<State<StatefulWidget>> get allStates => _tester.allStates;

  @override
  Iterable<Widget> get allWidgets => _tester.allWidgets;

  @override
  bool any(FinderBase<Element> finder) => _tester.any(finder);

  @override
  TestWidgetsFlutterBinding get binding => _tester.binding;

  @override
  Future<TestGesture> createGesture({
    int? pointer,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int buttons = kPrimaryButton,
  }) {
    return _tester.createGesture(
      pointer: pointer,
      kind: kind,
      buttons: buttons,
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) => _tester.createTicker(onTick);

  @override
  void dispatchEvent(PointerEvent event, HitTestResult result) {
    _tester.dispatchEvent(event, result);
  }

  @override
  Future<void> drag(
    FinderBase<Element> finder,
    Offset offset, {
    int? pointer,
    int buttons = kPrimaryButton,
    double touchSlopX = kDragSlopDefault,
    double touchSlopY = kDragSlopDefault,
    bool warnIfMissed = true,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return _tester.drag(
      finder,
      offset,
      pointer: pointer,
      buttons: buttons,
      touchSlopX: touchSlopX,
      touchSlopY: touchSlopY,
      warnIfMissed: warnIfMissed,
      kind: kind,
    );
  }

  @override
  Future<void> dragFrom(
    Offset startLocation,
    Offset offset, {
    int? pointer,
    int buttons = kPrimaryButton,
    double touchSlopX = kDragSlopDefault,
    double touchSlopY = kDragSlopDefault,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return _tester.dragFrom(
      startLocation,
      offset,
      pointer: pointer,
      buttons: buttons,
      touchSlopX: touchSlopX,
      touchSlopY: touchSlopY,
      kind: kind,
    );
  }

  @override
  Future<void> dragUntilVisible(
    FinderBase<Element> finder,
    FinderBase<Element> view,
    Offset moveStep, {
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
  }) {
    return _tester.dragUntilVisible(
      finder,
      view,
      moveStep,
      maxIteration: maxIteration,
      duration: duration,
    );
  }

  @override
  T element<T extends Element>(FinderBase<Element> finder) =>
      _tester.element(finder);

  @override
  Iterable<T> elementList<T extends Element>(FinderBase<Element> finder) =>
      _tester.elementList(finder);

  @override
  SemanticsHandle ensureSemantics() => _tester.ensureSemantics();

  @override
  Future<void> ensureVisible(FinderBase<Element> finder) =>
      _tester.ensureVisible(finder);

  @override
  Future<void> enterText(FinderBase<Element> finder, String text) =>
      _tester.enterText(finder, text);

  @override
  T firstElement<T extends Element>(FinderBase<Element> finder) =>
      _tester.firstElement(finder);

  @override
  T firstRenderObject<T extends RenderObject>(FinderBase<Element> finder) =>
      _tester.firstRenderObject(finder);

  @override
  T firstState<T extends State<StatefulWidget>>(FinderBase<Element> finder) =>
      _tester.firstState(finder);

  @override
  T firstWidget<T extends Widget>(FinderBase<Element> finder) =>
      _tester.firstWidget(finder);

  @override
  Future<void> fling(
    FinderBase<Element> finder,
    Offset offset,
    double speed, {
    int? pointer,
    int buttons = kPrimaryButton,
    Duration frameInterval = const Duration(milliseconds: 16),
    Offset initialOffset = Offset.zero,
    Duration initialOffsetDelay = const Duration(seconds: 1),
    bool warnIfMissed = true,
    PointerDeviceKind deviceKind = PointerDeviceKind.touch,
  }) {
    return _tester.fling(
      finder,
      offset,
      speed,
      pointer: pointer,
      buttons: buttons,
      frameInterval: frameInterval,
      initialOffset: initialOffset,
      initialOffsetDelay: initialOffsetDelay,
      warnIfMissed: warnIfMissed,
      deviceKind: deviceKind,
    );
  }

  @override
  Future<void> flingFrom(
    Offset startLocation,
    Offset offset,
    double speed, {
    int? pointer,
    int buttons = kPrimaryButton,
    Duration frameInterval = const Duration(milliseconds: 16),
    Offset initialOffset = Offset.zero,
    Duration initialOffsetDelay = const Duration(seconds: 1),
    PointerDeviceKind deviceKind = PointerDeviceKind.touch,
  }) {
    return _tester.flingFrom(
      startLocation,
      offset,
      speed,
      pointer: pointer,
      buttons: buttons,
      frameInterval: frameInterval,
      initialOffset: initialOffset,
      initialOffsetDelay: initialOffsetDelay,
      deviceKind: deviceKind,
    );
  }

  @override
  Offset getBottomLeft(
    FinderBase<Element> finder, {
    bool warnIfMissed = false,
    String callee = 'getBottomLeft',
  }) {
    return _tester.getBottomLeft(
      finder,
      warnIfMissed: warnIfMissed,
      callee: callee,
    );
  }

  @override
  Offset getBottomRight(
    FinderBase<Element> finder, {
    bool warnIfMissed = false,
    String callee = 'getBottomRight',
  }) {
    return _tester.getBottomRight(
      finder,
      warnIfMissed: warnIfMissed,
      callee: callee,
    );
  }

  @override
  Offset getCenter(
    FinderBase<Element> finder, {
    bool warnIfMissed = false,
    String callee = 'getCenter',
  }) {
    return _tester.getCenter(
      finder,
      warnIfMissed: warnIfMissed,
      callee: callee,
    );
  }

  @override
  Rect getRect(FinderBase<Element> finder) => _tester.getRect(finder);

  @override
  Future<TestRestorationData> getRestorationData() =>
      _tester.getRestorationData();

  @override
  SemanticsNode getSemantics(FinderBase<Element> finder) =>
      _tester.getSemantics(finder);

  @override
  Size getSize(FinderBase<Element> finder) => _tester.getSize(finder);

  @override
  Offset getTopLeft(
    FinderBase<Element> finder, {
    bool warnIfMissed = false,
    String callee = 'getTopLeft',
  }) {
    return _tester.getTopLeft(
      finder,
      warnIfMissed: warnIfMissed,
      callee: callee,
    );
  }

  @override
  Offset getTopRight(
    FinderBase<Element> finder, {
    bool warnIfMissed = false,
    String callee = 'getTopRight',
  }) {
    return _tester.getTopRight(
      finder,
      warnIfMissed: warnIfMissed,
      callee: callee,
    );
  }

  @override
  Future<List<Duration>> handlePointerEventRecord(
    Iterable<PointerEventRecord> records,
  ) {
    return _tester.handlePointerEventRecord(records);
  }

  @override
  bool get hasRunningAnimations => _tester.hasRunningAnimations;

  @override
  HitTestResult hitTestOnBinding(Offset location, {int? viewId}) {
    return _tester.hitTestOnBinding(location, viewId: viewId);
  }

  @override
  Future<void> idle() => _tester.idle();

  @override
  Iterable<Layer> layerListOf(FinderBase<Element> finder) =>
      _tester.layerListOf(finder);

  @override
  List<Layer> get layers => _tester.layers;

  @override
  Future<void> longPress(
    FinderBase<Element> finder, {
    int? pointer,
    int buttons = kPrimaryButton,
    bool warnIfMissed = true,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return _tester.longPress(
      finder,
      pointer: pointer,
      buttons: buttons,
      warnIfMissed: warnIfMissed,
      kind: kind,
    );
  }

  @override
  Future<void> longPressAt(
    Offset location, {
    int? pointer,
    int buttons = kPrimaryButton,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return _tester.longPressAt(
      location,
      pointer: pointer,
      buttons: buttons,
      kind: kind,
    );
  }

  @override
  int get nextPointer => _tester.nextPointer;

  @override
  Future<void> pageBack() => _tester.pageBack();

  @override
  TestPlatformDispatcher get platformDispatcher => _tester.platformDispatcher;

  @override
  Future<TestGesture> press(
    FinderBase<Element> finder, {
    int? pointer,
    int buttons = kPrimaryButton,
    bool warnIfMissed = true,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return _tester.press(
      finder,
      pointer: pointer,
      buttons: buttons,
      warnIfMissed: warnIfMissed,
      kind: kind,
    );
  }

  @override
  void printToConsole(String message) {
    _tester.printToConsole(message);
  }

  @override
  Future<void> pump([
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) {
    return _tester.pump(duration, phase);
  }

  @override
  Future<int> pumpAndSettle([
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration timeout = const Duration(minutes: 10),
  ]) {
    return _tester.pumpAndSettle(duration, phase, timeout);
  }

  @override
  Future<void> pumpBenchmark(Duration duration) =>
      _tester.pumpBenchmark(duration);

  @override
  Future<void> pumpFrames(
    Widget target,
    Duration maxDuration, [
    Duration interval = const Duration(milliseconds: 16, microseconds: 683),
  ]) {
    return _tester.pumpFrames(target, maxDuration, interval);
  }

  @override
  Future<void> pumpWidget(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    bool wrapWithView = true,
  }) {
    return _tester.pumpWidget(
      widget,
      duration: duration,
      phase: phase,
      wrapWithView: wrapWithView,
    );
  }

  @override
  T renderObject<T extends RenderObject>(FinderBase<Element> finder) =>
      _tester.renderObject(finder);

  @override
  Iterable<T> renderObjectList<T extends RenderObject>(
    FinderBase<Element> finder,
  ) =>
      _tester.renderObjectList(finder);

  @override
  Future<void> restartAndRestore() => _tester.restartAndRestore();

  @override
  Future<void> restoreFrom(TestRestorationData data) =>
      _tester.restoreFrom(data);

  @override
  Future<T?> runAsync<T>(
    Future<T> Function() callback, {
    Duration additionalTime = const Duration(milliseconds: 1000),
  }) {
    // The deprecated member use is necessary for compatibility with older
    // versions of the Flutter framework.
    // ignore: deprecated_member_use
    return _tester.runAsync(callback, additionalTime: additionalTime);
  }

  @override
  Future<void> scrollUntilVisible(
    FinderBase<Element> finder,
    double delta, {
    FinderBase<Element>? scrollable,
    int maxScrolls = 50,
    Duration duration = const Duration(milliseconds: 50),
  }) {
    return _tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
      maxScrolls: maxScrolls,
      duration: duration,
    );
  }

  @override
  SemanticsController get semantics => _tester.semantics;

  @override
  Future<void> sendEventToBinding(PointerEvent event) =>
      _tester.sendEventToBinding(event);

  @override
  Future<bool> sendKeyDownEvent(
    LogicalKeyboardKey key, {
    String? platform,
    String? character,
    PhysicalKeyboardKey? physicalKey,
  }) {
    return _tester.sendKeyDownEvent(
      key,
      platform: platform,
      character: character,
      physicalKey: physicalKey,
    );
  }

  @override
  Future<bool> sendKeyEvent(
    LogicalKeyboardKey key, {
    String? platform,
    String? character,
    PhysicalKeyboardKey? physicalKey,
  }) {
    return _tester.sendKeyEvent(
      key,
      platform: platform,
      character: character,
      physicalKey: physicalKey,
    );
  }

  @override
  Future<bool> sendKeyRepeatEvent(
    LogicalKeyboardKey key, {
    String? platform,
    String? character,
    PhysicalKeyboardKey? physicalKey,
  }) {
    return _tester.sendKeyRepeatEvent(
      key,
      platform: platform,
      character: character,
      physicalKey: physicalKey,
    );
  }

  @override
  Future<bool> sendKeyUpEvent(
    LogicalKeyboardKey key, {
    String? platform,
    PhysicalKeyboardKey? physicalKey,
  }) {
    return _tester.sendKeyUpEvent(
      key,
      platform: platform,
      physicalKey: physicalKey,
    );
  }

  @override
  Future<void> showKeyboard(FinderBase<Element> finder) =>
      _tester.showKeyboard(finder);

  @override
  Future<TestGesture> startGesture(
    Offset downLocation, {
    int? pointer,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int buttons = kPrimaryButton,
  }) {
    return _tester.startGesture(
      downLocation,
      pointer: pointer,
      kind: kind,
      buttons: buttons,
    );
  }

  @override
  T state<T extends State<StatefulWidget>>(FinderBase<Element> finder) =>
      _tester.state(finder);

  @override
  Iterable<T> stateList<T extends State<StatefulWidget>>(
    FinderBase<Element> finder,
  ) =>
      _tester.stateList(finder);

  @override
  List<CapturedAccessibilityAnnouncement> takeAnnouncements() =>
      _tester.takeAnnouncements();

  @override
  dynamic takeException() => _tester.takeException();

  @override
  Future<void> tap(
    FinderBase<Element> finder, {
    int? pointer,
    int buttons = kPrimaryButton,
    bool warnIfMissed = true,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return _tester.tap(
      finder,
      pointer: pointer,
      buttons: buttons,
      warnIfMissed: warnIfMissed,
      kind: kind,
    );
  }

  @override
  Future<void> tapAt(
    Offset location, {
    int? pointer,
    int buttons = kPrimaryButton,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return _tester.tapAt(
      location,
      pointer: pointer,
      buttons: buttons,
      kind: kind,
    );
  }

  @override
  Future<void> tapOnText(
    FinderBase<TextRangeContext> textRangeFinder, {
    int? pointer,
    int buttons = kPrimaryButton,
  }) {
    return _tester.tapOnText(
      textRangeFinder,
      pointer: pointer,
      buttons: buttons,
    );
  }

  @override
  String get testDescription => _tester.testDescription;

  @override
  TestTextInput get testTextInput => _tester.testTextInput;

  @override
  Future<void> timedDrag(
    FinderBase<Element> finder,
    Offset offset,
    Duration duration, {
    int? pointer,
    int buttons = kPrimaryButton,
    double frequency = 60.0,
    bool warnIfMissed = true,
  }) {
    return _tester.timedDrag(
      finder,
      offset,
      duration,
      pointer: pointer,
      buttons: buttons,
      frequency: frequency,
      warnIfMissed: warnIfMissed,
    );
  }

  @override
  Future<void> timedDragFrom(
    Offset startLocation,
    Offset offset,
    Duration duration, {
    int? pointer,
    int buttons = kPrimaryButton,
    double frequency = 60.0,
  }) {
    return _tester.timedDragFrom(
      startLocation,
      offset,
      duration,
      pointer: pointer,
      buttons: buttons,
      frequency: frequency,
    );
  }

  @override
  Future<void> trackpadFling(
    FinderBase<Element> finder,
    Offset offset,
    double speed, {
    int? pointer,
    int buttons = kPrimaryButton,
    Duration frameInterval = const Duration(milliseconds: 16),
    Offset initialOffset = Offset.zero,
    Duration initialOffsetDelay = const Duration(seconds: 1),
    bool warnIfMissed = true,
  }) {
    return _tester.trackpadFling(
      finder,
      offset,
      speed,
      pointer: pointer,
      buttons: buttons,
      frameInterval: frameInterval,
      initialOffset: initialOffset,
      initialOffsetDelay: initialOffsetDelay,
      warnIfMissed: warnIfMissed,
    );
  }

  @override
  Future<void> trackpadFlingFrom(
    Offset startLocation,
    Offset offset,
    double speed, {
    int? pointer,
    int buttons = kPrimaryButton,
    Duration frameInterval = const Duration(milliseconds: 16),
    Offset initialOffset = Offset.zero,
    Duration initialOffsetDelay = const Duration(seconds: 1),
  }) {
    return _tester.trackpadFlingFrom(
      startLocation,
      offset,
      speed,
      pointer: pointer,
      buttons: buttons,
      frameInterval: frameInterval,
      initialOffset: initialOffset,
      initialOffsetDelay: initialOffsetDelay,
    );
  }

  @override
  void verifyTickersWereDisposed([String when = 'when none should have been']) {
    _tester.verifyTickersWereDisposed(when);
  }

  @override
  TestFlutterView get view => _tester.view;

  @override
  TestFlutterView viewOf(FinderBase<Element> finder) => _tester.viewOf(finder);

  @override
  T widget<T extends Widget>(FinderBase<Element> finder) =>
      _tester.widget(finder);

  @override
  Iterable<T> widgetList<T extends Widget>(FinderBase<Element> finder) =>
      _tester.widgetList(finder);
}

mixin _ShowKeyboardPatch on _PWT {
  /// This is a patched version of [WidgetTester.showKeyboard] method
  ///
  /// TODO: Remove this patch when [this issue gets closed](https://github.com/flutter/flutter/issues/134604)
  ///
  /// Give the text input widget specified by [finder] the focus, as if the
  /// onscreen keyboard had appeared.
  ///
  /// Implies a call to [pump].
  ///
  /// The widget specified by [finder] must be an [EditableText] or have
  /// an [EditableText] descendant. For example `find.byType(TextField)`
  /// or `find.byType(TextFormField)`, or `find.byType(EditableText)`.
  ///
  /// Tests that just need to add text to widgets like [TextField]
  /// or [TextFormField] only need to call [enterText].
  @override
  Future<void> showKeyboard(FinderBase<Element> finder) async {
    var skipOffstage = true;
    if (finder is Finder) {
      skipOffstage = finder.skipOffstage;
    }
    return TestAsyncUtils.guard<void>(() async {
      final editable = state<EditableTextState>(
        find.descendant(
          of: finder,
          matching: find.byType(EditableText, skipOffstage: skipOffstage),
          matchRoot: true,
        ),
      );
      // Setting focusedEditable causes the binding to call requestKeyboard()
      // on the EditableTextState, which itself eventually calls TextInput.attach
      // to establish the connection.
      binding.focusedEditable = editable;

      void removeFocusedEditable() {
        final isPrimaryFocusEditableText = FocusManager
                .instance.primaryFocus?.context
                ?.findAncestorStateOfType<EditableTextState>() !=
            null;

        if (isPrimaryFocusEditableText) {
          binding.focusedEditable = null;
        }

        FocusManager.instance.removeListener(removeFocusedEditable);
      }

      FocusManager.instance.addListener(removeFocusedEditable);

      await pump();
    });
  }
}
