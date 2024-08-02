import 'dart:developer';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/binding.dart';
import 'package:patrol/src/global_state.dart' as global_state;
import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/native.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;
// ignore: implementation_imports
import 'package:test_api/src/backend/group.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/test.dart';

import 'constants.dart' as constants;
import 'custom_finders/patrol_integration_tester.dart';

/// Signature for callback to [patrolTest].
typedef PatrolTesterCallback = Future<void> Function(PatrolIntegrationTester $);

/// A modification of [setUp] that works with Patrol's native automation.
void patrolSetUp(dynamic Function() body) {
  setUp(() async {
    if (constants.hotRestartEnabled) {
      await body();
      return;
    }

    final currentTest = global_state.currentTestFullName;

    final requestedToExecute = await PatrolBinding.instance.patrolAppService
        .waitForExecutionRequest(currentTest);

    if (requestedToExecute) {
      await body();
    }
  });
}

/// A modification of [tearDown] that works with Patrol's native automation.
void patrolTearDown(dynamic Function() body) {
  tearDown(() async {
    if (constants.hotRestartEnabled) {
      await body();
      return;
    }

    final currentTest = global_state.currentTestFullName;

    final requestedToExecute = await PatrolBinding.instance.patrolAppService
        .waitForExecutionRequest(currentTest);

    if (requestedToExecute) {
      await body();
    }
  });
}

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
@isTest
void patrolTest(
  String description,
  PatrolTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  finders.PatrolTesterConfig config = const finders.PatrolTesterConfig(),
  NativeAutomatorConfig nativeAutomatorConfig = const NativeAutomatorConfig(),
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fadePointers,
}) {
  final automator = NativeAutomator(config: nativeAutomatorConfig);
  final automator2 = NativeAutomator2(config: nativeAutomatorConfig);
  final patrolBinding = PatrolBinding.ensureInitialized(nativeAutomatorConfig)
    ..framePolicy = framePolicy;

  testWidgets(
    description,
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
    (widgetTester) async {
      if (!constants.hotRestartEnabled) {
        // If Patrol's native automation feature is enabled, then this test will
        // be executed only if the native side requested it to be executed.
        // Otherwise, it returns early.

        final requestedToExecute = await patrolBinding.patrolAppService
            .waitForExecutionRequest(global_state.currentTestFullName);

        if (!requestedToExecute) {
          return;
        }
      }
      if (!kIsWeb && io.Platform.isIOS) {
        widgetTester.binding.platformDispatcher.onSemanticsEnabledChanged = () {
          // This callback is empty on purpose. It's a workaround for tests
          // failing on iOS.
          //
          // See https://github.com/leancodepl/patrol/issues/1474
        };
      }
      await automator.configure();
      // We don't have to call this line because automator.configure() does the same.
      // await automator2.configure();

      final patrolTester = PatrolIntegrationTester(
        tester: widgetTester,
        nativeAutomator: automator,
        nativeAutomator2: automator2,
        config: config,
      );
      await callback(patrolTester);

      // ignore: prefer_const_declarations
      final waitSeconds = const int.fromEnvironment('PATROL_WAIT');
      final waitDuration = Duration(seconds: waitSeconds);

      if (debugDefaultTargetPlatformOverride !=
          patrolBinding.workaroundDebugDefaultTargetPlatformOverride) {
        debugDefaultTargetPlatformOverride =
            patrolBinding.workaroundDebugDefaultTargetPlatformOverride;
      }

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

/// Creates a DartGroupEntry by visiting the subgroups of [parentGroup].
///
/// The initial [parentGroup] is the implicit, unnamed top-level [Group] present
/// in every test case.
@internal
DartGroupEntry createDartTestGroup(
  Group parentGroup, {
  String name = '',
  int level = 0,
  int maxTestCaseLength = global_state.maxTestLength,
}) {
  final groupDTO = DartGroupEntry(
    name: name,
    type: GroupEntryType.group,
    entries: [],
  );

  for (final entry in parentGroup.entries) {
    // Trim names of current groups

    var name = entry.name;
    if (parentGroup.name.isNotEmpty) {
      // Assume that parentGroupName fits maxTestCaseLength
      // Assume that after cropping, test names are different.

      if (name.length > maxTestCaseLength) {
        name = name.substring(0, maxTestCaseLength);
      }

      name = deduplicateGroupEntryName(parentGroup.name, name);
    }

    if (entry is Group) {
      groupDTO.entries.add(
        createDartTestGroup(
          entry,
          name: name,
          level: level + 1,
          maxTestCaseLength: maxTestCaseLength,
        ),
      );

      print("Entry $name is a group");
    } else if (entry is Test) {
      if (entry.name == 'patrol_test_explorer') {
        // Ignore the bogus test that is used to discover the test structure.
        continue;
      }

      if (level < 1) {
        throw StateError('Test is not allowed to be defined at level $level');
      }

      groupDTO.entries.add(
        DartGroupEntry(name: name, type: GroupEntryType.test, entries: []),
      );

      print("Entry $name is a test");
    } else {
      // This should really never happen, because Group and Test are the only
      // subclasses of GroupEntry.
      throw StateError('invalid state');
    }
  }

  return groupDTO;
}

/// Allows for retrieving the name of a GroupEntry by stripping the names of all ancestor groups.
///
/// Example:
/// parentName = 'example_test myGroup'
/// currentName = 'example_test myGroup myTest'
/// should return 'myTest'
@internal
String deduplicateGroupEntryName(String parentName, String currentName) {
  return currentName.substring(
    parentName.length + 1,
    currentName.length,
  );
}

/// Recursively prints the structure of the test suite and reports test count
/// of the top-most group
@internal
int reportGroupStructure(DartGroupEntry group, {int indentation = 0}) {
  var testCount = group.type == GroupEntryType.test ? 1 : 0;

  final indent = ' ' * indentation;
  final tag = group.type == GroupEntryType.group ? 'group' : 'test';
  debugPrint("$indent-- $tag: '${group.name}'");

  for (final entry in group.entries) {
    if (entry.type == GroupEntryType.test) {
      ++testCount;
      debugPrint("$indent     -- test: '${entry.name}'");
    } else {
      for (final subgroup in entry.entries) {
        testCount +=
            reportGroupStructure(subgroup, indentation: indentation + 5);
      }
    }
  }

  if (indentation == 0) {
    print('Posting event!');
    postEvent(
      'testCount',
      {'testCount': testCount},
    );
  }

  return testCount;
}
