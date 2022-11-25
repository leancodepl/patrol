import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/custom_finders/patrol_test_config.dart';
import 'package:patrol/src/custom_finders/patrol_tester.dart';
import 'package:patrol/src/host/host_automator.dart';
import 'package:patrol/src/native/native.dart';

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
  PatrolTestConfig config = const PatrolTestConfig(),
  bool nativeAutomation = false,
  BindingType bindingType = BindingType.patrol,
}) {
  TestWidgetsFlutterBinding? binding;
  if (nativeAutomation) {
    switch (bindingType) {
      case BindingType.patrol:
        binding = PatrolBinding.ensureInitialized();
        break;
      case BindingType.integrationTest:
        binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
        break;
      case BindingType.none:
        break;
    }
  }

  HostAutomator? hostAutomator;
  NativeAutomator? nativeAutomator;
  if (nativeAutomation) {
    if (binding is PatrolBinding) {
      hostAutomator = HostAutomator(binding: binding);

      nativeAutomator = NativeAutomator(
        packageName: config.packageName,
        bundleId: config.bundleId,
      );
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
        patrolTester.log(
          'sleeping for $waitSeconds seconds',
          name: 'patrolTest',
        );
        await Future<void>.delayed(waitDuration);
        patrolTester.log('done sleeping', name: 'patrolTest');
      }
    },
  );
}
