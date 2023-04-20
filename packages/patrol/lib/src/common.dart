// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages, implementation_imports

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/binding.dart';
import 'package:patrol/src/custom_finders/patrol_tester.dart';
import 'package:patrol/src/native/contracts/contracts.pb.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:patrol/src/native/native.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/test.dart';

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

  if (patrolBinding != null) {
    // The execution of this test will only proceed if the native side
    // requests it.

    // FIXME: Too strict assumption
    // The assumption here is that immediate parent group of this test is a
    // name of the Dart file. This is not always true, for example, if the
    // patrolTest() in a Dart test file is in a group. For the initial POC
    // it's good enough, though.
    final parentGroupName = Zone.current['parentGroupName'] as String;
    // print('patrolTest(): $parentGroupName registered');

    patrolBinding.patrolAppService.waitForRunRequest(parentGroupName).then((_) {
      testWidgets(
        description,
        skip: skip,
        timeout: timeout,
        semanticsEnabled: semanticsEnabled,
        variant: variant,
        tags: tags,
        (widgetTester) async {
          // await nativeAutomator?.configure(); // TODO: Bring this back

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
    });
  }
}

/// Creates a DartTestGroup by recursively visiting subgroups of [topLevelGroup]
/// and tests these groups contain.
///
/// This function also removes parent group prefixes.
@internal
DartTestGroup createDartTestGroup(
  Group topLevelGroup, {
  String prefix = '',
  String fullPrefix = '',
}) {
  final groupName = topLevelGroup.name.replaceFirst(prefix, '').trim();
  final group = DartTestGroup(name: groupName);

  for (final entry in topLevelGroup.entries) {
    if (entry is Group) {
      final subgroup = createDartTestGroup(
        entry,
        prefix: groupName,
        fullPrefix: entry.name.trim(),
      );
      group.groups.add(subgroup);
    }

    if (entry is Test) {
      if (entry.name == 'patrol_test_explorer') {
        continue;
      }

      final testName = entry.name.replaceFirst(fullPrefix, '').trim();
      final dartTest = DartTestCase(name: testName);
      group.tests.add(dartTest);
    }
  }

  return group;
}
