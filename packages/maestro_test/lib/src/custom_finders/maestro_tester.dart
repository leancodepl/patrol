import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/common.dart';
import 'package:maestro_test/src/custom_finders/maestro_finder.dart';
import 'package:maestro_test/src/custom_finders/maestro_test_config.dart';
import 'package:meta/meta.dart';

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
  const MaestroTester({
    required this.tester,
    required this.config,
  });

  /// Global configuration of this tester.
  final MaestroTestConfig config;

  /// Flutter's widget tester that this [MaestroTester] wraps.
  final WidgetTester tester;

  /// Makes it simple to log. No need to use `print` or depend on
  /// `package:logging`.
  void log(Object? object, {String? name}) {
    final log = StringBuffer();

    final tag = name ?? config.appName;
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
    await tester.pumpAndSettle(duration, phase, timeout);
  }

  /// Pumps [widget] and then calls [WidgetTester.pumpAndSettle].
  ///
  /// This is a convenience method combining [WidgetTester.pumpWidget] and
  /// [WidgetTester.pumpAndSettle].
  Future<void> pumpWidgetAndSettle(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration? timeout,
  }) async {
    await tester.pumpWidget(widget, duration, phase);
    await performPump(andSettle: true, settleTimeout: timeout);
  }

  /// Repeatedly drags [view] by [moveStep] until [finder] finds at least one
  /// existing widget.
  ///
  /// Between each drag, advances the clock by [duration].
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] or
  /// [WidgetTester.pump] after the drag is complete. If you want to override
  /// this behavior to not call [WidgetTester.pumpAndSettle], set [andSettle] to
  /// false.
  ///
  /// This is a reimplementation of [WidgetController.dragUntilVisible] that
  /// differs from the original in the following ways:
  ///
  ///  * has a better name
  ///
  ///  * waits until [view] is visible
  ///
  ///  * uses [WidgetController.firstElement] instead of
  ///    [WidgetController.element], which avoids [StateError] being thrown in
  ///    situations when [finder] finds more than 1 visible widget
  ///
  /// See also:
  ///  * [MaestroTester.config.andSettle], which controls the default behavior
  ///    if [andSettle] is null
  Future<MaestroFinder> dragUntilExists({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
    bool? andSettle,
  }) async {
    final viewMaestroFinder = MaestroFinder(finder: view, tester: this);

    await viewMaestroFinder.waitUntilVisible();

    var iterationsLeft = maxIteration;
    await TestAsyncUtils.guard<void>(() async {
      while (iterationsLeft > 0 && finder.evaluate().isEmpty) {
        await tester.drag(view, moveStep);
        await tester.pump(duration);
        iterationsLeft -= 1;
      }
      await Scrollable.ensureVisible(tester.firstElement(finder));
    });

    /* await tester.dragUntilVisible(
      finder,
      (await viewMaestroFinder.waitUntilVisible()).first,
      moveStep,
      maxIteration: maxIteration,
      duration: duration,
    ); */

    await performPump(
      andSettle: andSettle,
      settleTimeout: config.settleTimeout,
    );

    return MaestroFinder(finder: finder.first, tester: this);
  }

  /// Repeatedly drags [view] by [moveStep] until [finder] finds at least one
  /// visible widget.
  ///
  /// Between each drag, advances the clock by [duration].
  ///
  /// This is a reimplementation of [WidgetController.dragUntilVisible] that
  /// differs from the original in the following ways:
  ///
  ///  * actually scrolls until [finder] finds at least one *visible* widget,
  ///    not an *existing* widget.
  ///
  ///  * uses [WidgetController.firstElement] instead of
  ///    [WidgetController.element], which avoids [StateError] being thrown in
  ///    situations when [finder] finds more than 1 visible widget
  Future<MaestroFinder> dragUntilVisible({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
    bool? andSettle,
  }) async {
    await TestAsyncUtils.guard<void>(() async {
      var iterationsLeft = maxIteration;
      while (iterationsLeft > 0 && finder.hitTestable().evaluate().isEmpty) {
        await tester.drag(view, moveStep);
        await tester.pump(duration);
        iterationsLeft -= 1;
      }
      await Scrollable.ensureVisible(tester.firstElement(finder));

      await performPump(
        andSettle: andSettle,
        settleTimeout: config.settleTimeout,
      );
    });

    return MaestroFinder(finder: finder.first, tester: this);
  }

  /// Scrolls [scrollable] in its scrolling direction until this finders finds
  /// at least one existing widget.
  ///
  /// If [scrollable] is null, it defaults to the first found [Scrollable].
  ///
  /// See also:
  ///  - [MaestroTester.scrollUntilVisible], which this method wraps and gives
  ///    it a better name
  Future<void> scrollUntilExists({
    required Finder finder,
    Finder? scrollable,
    double delta = 32,
    int maxScrolls = 50,
    Duration duration = const Duration(milliseconds: 50),
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
      maxScrolls: maxScrolls,
      duration: duration,
    );
  }

  /// Scrolls [scrollable] in its scrolling direction until this finders finds
  /// at least one existing widget.
  ///
  /// If [scrollable] is null, it defaults to the first found [Scrollable].
  ///
  /// This is a reimplementation of [WidgetController.scrollUntilVisible] that
  /// actually scrolls until [finder] finds at least one *visible* widget, not
  /// *existing* widget.
  Future<MaestroFinder> scrollUntilVisible({
    required Finder finder,
    Finder? scrollable,
    double delta = 32,
    int maxScrolls = 50,
    Duration duration = const Duration(milliseconds: 50),
  }) async {
    assert(maxScrolls > 0, 'maxScrolls must be positive number');
    scrollable ??= find.byType(Scrollable);

    final scrollableMaestroFinder = await MaestroFinder(
      finder: scrollable,
      tester: this,
    ).waitUntilVisible();

    return TestAsyncUtils.guard<MaestroFinder>(() async {
      Offset moveStep;
      switch (tester.widget<Scrollable>(scrollable!).axisDirection) {
        case AxisDirection.up:
          moveStep = Offset(0, delta);
          break;
        case AxisDirection.down:
          moveStep = Offset(0, -delta);
          break;
        case AxisDirection.left:
          moveStep = Offset(delta, 0);
          break;
        case AxisDirection.right:
          moveStep = Offset(-delta, 0);
          break;
      }

      final resolvedFinder = await dragUntilVisible(
        finder: finder,
        view: scrollableMaestroFinder.first,
        moveStep: moveStep,
        maxIteration: maxScrolls,
        duration: duration,
      );

      return resolvedFinder;
    });
  }

  @internal
  // ignore: public_member_api_docs
  Future<void> performPump({
    required bool? andSettle,
    required Duration? settleTimeout,
  }) async {
    final settle = andSettle ?? config.andSettle;
    if (settle) {
      final timeout = settleTimeout ?? config.settleTimeout;
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        timeout,
      );
    } else {
      await tester.pump();
    }
  }
}
