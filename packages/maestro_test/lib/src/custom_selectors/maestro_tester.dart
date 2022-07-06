import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors/common.dart';
import 'package:maestro_test/src/custom_selectors/maestro_finder.dart';

/// [MaestroTester] wraps a [WidgetTester]. It provides
/// - support for _Maestro custom selector_, a.k.a `$`
/// - convenience method for pumping, scrolling, etc.
///
/// If you want to do something that [WidgetTester] supports, but
/// [MaestroTester] does not, you can access the underlying [WidgetTester] via
/// [tester].
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
/// You can call [MaestroTester] just like a normal method, because it is a
/// [callable class][callable-class].
///
/// [callable-class]:
/// https://dart.dev/guides/language/language-tour#callable-classes
class MaestroTester {
  /// Creates a new [MaestroTester] with the given WidgetTester [tester].
  const MaestroTester(this.tester);

  /// Widget tester that this [MaestroTester] wraps.
  final WidgetTester tester;

  /// Returns a [MaestroFinder] that matches [matching].
  ///
  /// Refer to
  MaestroFinder call(dynamic matching) {
    return resolve(
      matching: matching,
      tester: tester,
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
    bool andSettle = true,
  }) async {
    await tester.pumpWidget(widget, duration, phase);

    if (andSettle) {
      await tester.pumpAndSettle();
    }
  }

  //// A convenience method combining [WidgetTester.dragUntilVisible] and
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
  Future dragUntilVisible(
    Finder finder,
    Finder view,
    Offset moveStep, {
    int index = 0,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
    bool andSettle = true,
  }) async {
    await tester.dragUntilVisible(
      finder.at(index),
      view,
      moveStep,
      maxIteration: maxIteration,
      duration: duration,
    );

    if (andSettle) {
      await tester.pumpAndSettle();
    }
  }
}
