// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/binding.dart';
import 'package:patrol/src/custom_finders/patrol_tester.dart';
import 'package:patrol/src/native/contracts/contracts.pb.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:patrol/src/native/native.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/test.dart';

import 'constants.dart' as constants;

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
  bool nativeAutomation = false,
  BindingType bindingType = BindingType.patrol,
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fadePointers,
}) {
  NativeAutomator? nativeAutomator;

  PatrolBinding? patrolBinding;

  if (nativeAutomation) {
    switch (bindingType) {
      case BindingType.patrol:
        nativeAutomator = NativeAutomator(config: nativeAutomatorConfig);

        patrolBinding = PatrolBinding.ensureInitialized();
        patrolBinding.framePolicy = framePolicy;
        break;
      case BindingType.integrationTest:
        IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
            framePolicy;

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
      if (patrolBinding != null && !constants.hotRestartEnabled) {
        // If Patrol's native automation feature is enabled, then this test will
        // be executed only if the native side requested it to be executed.
        // Otherwise, it returns early.
        //
        // The assumption here is that this test doesn't have any extra parent
        // groups. Every Dart test suite has an implict, unnamed, top-level
        // group. An additional group is present in the bundled_test.dart, and
        // its name is equal to the path to the Dart test file in the
        // integration_test directory.
        //
        // In other words, the developer cannot use `group()` in the tests.
        //
        // Example: if this function is called from the Dart test file named
        // "example_test.dart", and that file is located in the
        // "integration_test/examples" directory, we assume that the name of the
        // immediate parent group is "examples.example_test".

        final parentGroupName = Invoker.current!.liveTest.groups.last.name;
        final requestedToExecute = await patrolBinding.patrolAppService
            .waitForExecutionRequest(parentGroupName);

        if (!requestedToExecute) {
          return;
        }

        await nativeAutomator?.configure();
      }

      final patrolTester = PatrolTester(
        tester: widgetTester,
        nativeAutomator: nativeAutomator,
        config: config,
      );
      await callback(patrolTester);

      // ignore: prefer_const_declarations
      final waitSeconds = const int.fromEnvironment('PATROL_WAIT');
      final waitDuration = Duration(seconds: waitSeconds);

      if (waitDuration > Duration.zero) {
        final stopwatch = Stopwatch()..start();
        await Future.doWhile(() async {
          await widgetTester.pump();
          if (stopwatch.elapsed > waitDuration) {
            stopwatch.stop();
            return false;
          }

          return true;
        });
      }
    },
  );
}

/// Creates a DartTestGroup by visiting the subgroups of [topLevelGroup].
@internal
DartTestGroup createDartTestGroup(
  Group topLevelGroup, {
  String prefix = '',
}) {
  final groupName = topLevelGroup.name.replaceFirst(prefix, '').trim();
  final group = DartTestGroup(name: groupName);

  for (final entry in topLevelGroup.entries) {
    if (entry is Group) {
      group.groups.add(DartTestGroup(name: entry.name));
    }

    if (entry is Test && entry.name != 'patrol_test_explorer') {
      throw StateError('Expected group, got test: ${entry.name}');
    }
  }

  return group;
}
