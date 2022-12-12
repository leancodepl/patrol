import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol_next/src/binding.dart';
import 'package:patrol_next/src/custom_finders/patrol_tester.dart';
import 'package:patrol_next/src/host/host_automator.dart';
import 'package:patrol_next/src/native/native.dart';

/// Signature for callback to [patrolTest].
typedef PatrolTesterCallback = Future<void> Function(PatrolTester $);

/// Like [testWidgets], but with support for Patrol custom finders.
///
/// To customize the Patrol-specific configuration, set [config].
///
/// ### Using the default [WidgetTester]
///
/// If you need to do something using Flutter's [WidgetTester], you can access
/// it like this:
///
/// ```dart
/// patrolTest(
///    'increase counter text',
///    ($) async {
///      await $.tester.tap(find.byIcon(Icons.add));
///    },
/// );
/// ```
///
/// [bindingType] specifies the binding to use. [bindingType] is ignored if
/// [nativeAutomation] is false.
@isTest
void patrolTest(
  String description,
  PatrolTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  PatrolTesterConfig config = const PatrolTesterConfig(),
  NativeAutomatorConfig nativeAutomatorConfig = const NativeAutomatorConfig(),
  HostAutomatorConfig hostAutomatorConfig = const HostAutomatorConfig(),
  bool nativeAutomation = false,
  BindingType bindingType = BindingType.patrol,
}) {
  HostAutomator? hostAutomator;
  NativeAutomator? nativeAutomator;

  if (nativeAutomation) {
    switch (bindingType) {
      case BindingType.patrol:
        final binding = PatrolBinding.ensureInitialized();

        hostAutomator = HostAutomator(
          config: hostAutomatorConfig,
          binding: binding,
        );

        nativeAutomator = NativeAutomator(config: nativeAutomatorConfig);
        break;
      case BindingType.integrationTest:
        IntegrationTestWidgetsFlutterBinding.ensureInitialized();
        break;
      case BindingType.none:
        break;
    }
  }

  testWidgets(
    description,
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
    (widgetTester) async {
      await nativeAutomator?.configure();

      final patrolTester = PatrolTester(
        tester: widgetTester,
        nativeAutomator: nativeAutomator,
        hostAutomator: hostAutomator,
        config: config,
      );
      await callback(patrolTester);

      // ignore: prefer_const_declarations
      final waitSeconds = const int.fromEnvironment('PATROL_WAIT');
      final waitDuration = Duration(seconds: waitSeconds);
      if (waitDuration > Duration.zero) {
        await Future<void>.delayed(waitDuration);
      }
    },
  );
}
