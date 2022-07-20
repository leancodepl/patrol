import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors/common.dart';
import 'package:maestro_test/src/custom_selectors/maestro_finder.dart';
import 'package:meta/meta.dart';

/// Default amount of space to scroll by in a vertical [Scrollable]
const verticalStep = Offset(0, 16);

/// Default amount of space to scroll by in a horizontal [Scrollable].
const horizontalStep = Offset(16, 0);

/// [MaestroTester] wraps a [WidgetTester]. It provides
/// - support for _Maestro custom selector_, a.k.a `$`
/// - convenience method for pumping widgets, scrolling, etc.
///
/// If you want to do something that [WidgetTester] supports, but
/// [MaestroTester] does not, you can access the underlying [WidgetTester] via
/// [tester] field of [MaestroTester].
///
/// Usually, you won't create a [MaestroTester] instance directly. Instead,
/// you'll use the [MaestroTester] which is provided by [MaestroTesterCallback]
/// in [maestroTest], like this:
///
/// ```dart
/// import 'package:maestro_test/maestro_test.dart';
///
/// void main() {
///   maestroTest('Counter increments smoke test', (maestroTester) async {
///     await maestroTester.pumpWidgetAndSettle(const MyApp());
///     await maestroTester(#startAppButton).tap();
///   });
/// }
/// ```
///
/// To make test code more concise, `maestroTester` variable is usually called
/// `$`, like this:
///
/// ```dart
/// import 'package:maestro_test/maestro_test.dart';
/// void main() {
///   maestroTest('Counter increments smoke test', ($) async {
///     await $.pumpWidgetAndSettle(const MyApp());
///     await $(#startAppButton).tap();
///   });
/// }
/// ```
///
///
/// You can call [MaestroTester] just like a normal method, because it is a
/// [callable class][callable-class].
///
/// [callable-class]:
/// https://dart.dev/guides/language/language-tour#callable-classes
class MaestroTester {
  /// Creates a new [MaestroTester] with the given WidgetTester [tester].
  const MaestroTester(this.tester, {this.appName, required this.andSettle});

  /// Widget tester that this [MaestroTester] wraps.
  final WidgetTester tester;

  /// App name of the application under test.
  ///
  /// Useful for logging.
  final String? appName;

  /// If true, [pumpAndSettle] is called after every action wait for the
  /// animations to finish.
  final bool andSettle;

  /// Makes it simple to log.
  void log(Object? object, {String? name}) {
    final log = StringBuffer();

    final tag = appName ?? name;
    if (tag != null) {
      log.write('$tag: ');
    }

    log.write(object);

    // ignore: avoid_print
    print(log.toString());
  }

  /// Returns a [MaestroFinder] that matches [matching].
  ///
  /// See also:
  ///  - [MaestroFinder.resolve]
  MaestroFinder call(dynamic matching) {
    return MaestroFinder.resolve(
      matching: matching,
      tester: this,
      parentFinder: null,
    );
  }

  /// See [WidgetTester.pumpWidget].
  Future<void> pumpWidget(
    Widget widget, [
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    await tester.pumpWidget(widget, duration, phase);
  }

  /// See [WidgetTester.pump].
  Future<void> pump([
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    await tester.pump(duration, phase);
  }

  /// See [WidgetTester.pumpAndSettle].
  Future<void> pumpAndSettle([
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration timeout = const Duration(minutes: 10),
  ]) async {
    await tester.pumpAndSettle();
  }

  /// A convenience method combining [WidgetTester.pumpWidget] and
  /// [WidgetTester.pumpAndSettle].
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after tap. If
  /// you want to disable this behavior, pass `false` to [andSettle].
  Future<void> pumpWidgetAndSettle(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    bool? andSettle,
  }) async {
    await tester.pumpWidget(widget, duration, phase);
    await performPump(andSettle);
  }

  /// Convenience method combining `WidgetTester.drag` and
  /// [WidgetTester.pumpAndSettle].
  ///
  /// Specify [index] to select on which [finder] to tap. It defaults to the
  /// first finder.
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after drag.
  /// If you want to disable this behavior, pass `false` to [andSettle].
  ///
  /// See also:
  ///  - [WidgetController.drag]
  Future<void> drag(
    Finder finder,
    Offset offset, {
    int? pointer,
    int buttons = kPrimaryButton,
    double touchSlopX = kDragSlopDefault,
    double touchSlopY = kDragSlopDefault,
    bool warnIfMissed = true,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int index = 0,
    bool? andSettle,
  }) async {
    await tester.drag(
      finder.at(index),
      offset,
      pointer: pointer,
      buttons: buttons,
      touchSlopX: touchSlopX,
      touchSlopY: touchSlopY,
      kind: kind,
    );
    await performPump(andSettle);
  }

  /// Convenience method combining `WidgetTester.dragFrom` and
  /// [WidgetTester.pumpAndSettle].
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after tap. If
  /// you want to disable this behavior, pass `false` to [andSettle].
  ///
  /// See also:
  ///  - [WidgetController.dragFrom].
  Future<void> dragFrom(
    Offset startLocation,
    Offset offset, {
    int? pointer,
    int buttons = kPrimaryButton,
    double touchSlopX = kDragSlopDefault,
    double touchSlopY = kDragSlopDefault,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    bool? andSettle,
    int index = 0,
  }) async {
    await tester.dragFrom(
      startLocation,
      offset,
      pointer: pointer,
      buttons: buttons,
      touchSlopX: touchSlopX,
      touchSlopY: touchSlopY,
      kind: kind,
    );

    await performPump(andSettle);
  }

  /// Convenience method combining `WidgetTester.dragUntilVisible` and
  /// [WidgetTester.pumpAndSettle].
  ///
  /// Specify [index] to select on which [finder] to tap. It defaults to the
  /// first finder.
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after tap. If
  /// you want to disable this behavior, pass `false` to [andSettle].
  ///
  /// See also:
  ///  - [WidgetController.dragUntilVisible].
  Future<void> dragUntilVisible(
    Finder finder,
    Finder view,
    Offset moveStep, {
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
    bool? andSettle,
    int index = 0,
  }) async {
    await tester.dragUntilVisible(
      finder.at(index),
      view,
      moveStep,
      maxIteration: maxIteration,
      duration: duration,
    );

    await performPump(andSettle);
  }

  /// Shorthand for default-aware pumping and settling.
  @internal
  // ignore: avoid_positional_boolean_parameters
  Future<void> performPump(bool? andSettle) async {
    final settle = andSettle ?? this.andSettle;
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }
}
