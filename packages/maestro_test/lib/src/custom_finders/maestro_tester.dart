import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/common.dart';
import 'package:maestro_test/src/custom_finders/maestro_finder.dart';
import 'package:meta/meta.dart';

/// Specifies direction in the cartesian plane.
enum Direction {
  /// Left.
  left,

  /// Up.
  up,

  /// Right.
  right,

  /// Down.
  down,
}

/// Adds functionality to [Direction].
extension DirectionX on Direction {
  /// Resolves the direction to a [Offset].
  Offset resolveOffset(double step) {
    assert(step > 0, 'step must be positive number');

    switch (this) {
      case Direction.left:
        return Offset(step, 0);
      case Direction.up:
        return Offset(0, -step);
      case Direction.right:
        return Offset(step, 0);
      case Direction.down:
        return Offset(0, step);
    }
  }
}

/// [MaestroTester] wraps a [WidgetTester]. It provides support for _Maestro
/// custom finder_, a.k.a `$`.
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
/// <https://dart.dev/guides/language/language-tour#callable-classes>
class MaestroTester {
  /// Creates a new [MaestroTester] which wraps [tester].
  const MaestroTester(
    this.tester, {
    this.appName,
    required this.andSettle,
    this.findTimeout = const Duration(seconds: 5),
  });

  /// Flutter's widget tester that this [MaestroTester] wraps.
  final WidgetTester tester;

  /// Name of the application under test.
  ///
  /// If non-null, [MaestroTester.log] will prefix logs with it.
  final String? appName;

  /// If true, [pumpAndSettle] is called after every action such as tapping,
  /// entering text, dragging, etc.
  ///
  /// If false, only [pump] is called in these situations.
  final bool andSettle;

  /// Time after which [MaestroFinder.waitUntilVisible] fails if it doesn't finds a
  /// widget.
  ///
  /// [MaestroFinder.waitUntilVisible] is used internally by [MaestroFinder.tap] and
  /// [MaestroFinder.enterText].
  final Duration findTimeout;

  /// Makes it simple to log.
  void log(Object? object, {String? name}) {
    final log = StringBuffer();

    final tag = name ?? appName;
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

  /// Pumps [widget] and then calls [WidgetTester.pumpAndSettle].
  ///
  /// This is a convenience method combining [WidgetTester.pumpWidget] and
  /// [WidgetTester.pumpAndSettle].
  Future<void> pumpWidgetAndSettle(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  }) async {
    await tester.pumpWidget(widget, duration, phase);
    const andSettle = true;
    await performPump(andSettle);
  }

  /// Scrolls [view] in [direction] until it finds [finder].
  ///
  /// [step] is the amount of space to scroll by. It must be positive number.
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] or
  /// [WidgetTester.pump] after the drag is complete. If you want to override
  /// this behavior to not call [WidgetTester.pumpAndSettle], set [andSettle] to
  /// false.
  ///
  /// See also:
  ///  - [WidgetController.dragUntilVisible], which this method wraps
  ///  - [MaestroTester.andSettle], which controls the default behavior if
  ///    [andSettle] is null
  Future<MaestroFinder> dragUntilVisible({
    required Finder finder,
    required Finder view,
    required Direction direction,
    double step = 16,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
    bool? andSettle,
  }) async {
    assert(step > 0, 'step must be positive number');
    final moveStep = direction.resolveOffset(step);

    final maestroFinder = MaestroFinder(finder: view, tester: this);

    await tester.dragUntilVisible(
      finder.first,
      (await maestroFinder.waitUntilVisible()).first,
      moveStep,
      maxIteration: maxIteration,
      duration: duration,
    );

    await performPump(andSettle);

    return MaestroFinder(finder: finder.first, tester: this);
  }

  @internal
  // ignore: avoid_positional_boolean_parameters, public_member_api_docs
  Future<void> performPump(bool? andSettle) async {
    final settle = andSettle ?? this.andSettle;
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }
}
