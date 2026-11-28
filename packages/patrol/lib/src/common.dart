import 'dart:developer';

import 'package:boolean_selector/boolean_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show EditableText;
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/binding.dart';
import 'package:patrol/src/develop_generation.dart';
import 'package:patrol/src/develop_view_assertion.dart';
import 'package:patrol/src/global_state.dart' as global_state;
import 'package:patrol/src/phases.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/platform_automator.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;
import 'package:patrol_log/patrol_log.dart';

/// We need [Group] to recreate test hierarchy.
// ignore: implementation_imports
import 'package:test_api/src/backend/group.dart';

/// We need [Test] to recreate test hierarchy.
// ignore: implementation_imports
import 'package:test_api/src/backend/test.dart';

import 'constants.dart' as constants;
import 'custom_finders/patrol_integration_tester.dart';

/// Signature for callback to [patrolTest].
typedef PatrolTesterCallback = Future<void> Function(PatrolIntegrationTester $);

/// A modification of [setUp] that works with Patrol's native automation.
void patrolSetUp(dynamic Function() body) {
  if (constants.testDiscoveryEnabled) {
    // In discovery mode bodies never run, so the setUp would only reach for
    // PatrolBinding.instance and crash. Skip registering it entirely.
    return;
  }
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
  if (constants.testDiscoveryEnabled) {
    return;
  }
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
///
/// ### Text cursor
///
/// By default the text cursor doesn't blink during the test
/// ([EditableText.debugDeterministicCursor]). On iOS, and with
/// `CupertinoTextField` on any platform, the blink animation keeps scheduling
/// frames, so every action that settles while a text field is focused waits
/// several seconds and [finders.SettlePolicy.settle] can time out. Set
/// [deterministicCursor] to false to keep the blinking cursor.
@isTest
void patrolTest(
  String description,
  PatrolTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  finders.PatrolTesterConfig config = const finders.PatrolTesterConfig(
    printLogs: true,
  ),
  PlatformAutomatorConfig? platformAutomatorConfig,
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
  bool deterministicCursor = true,
}) {
  final phasedTest = patrolPhasesOf(callback);

  if (constants.testDiscoveryEnabled) {
    // Build-time discovery (host `flutter test`): only register the test so it
    // shows up in the group tree. Do NOT initialize PatrolBinding (Live binding,
    // incompatible with the host automated binding) and do NOT run the body
    // (it would block on waitForExecutionRequest()).
    testWidgets(
      description,
      skip: skip,
      timeout: timeout,
      semanticsEnabled: semanticsEnabled,
      variant: variant,
      tags: tags,
      (_) async {},
    );
    return;
  }

  final patrolLog = PatrolLogWriter(config: {'printLogs': config.printLogs});
  final platformAutomator = PlatformAutomator(
    config: platformAutomatorConfig ?? PlatformAutomatorConfig.defaultConfig(),
  );
  final patrolBinding = PatrolBinding.ensureInitialized(platformAutomator)
    ..framePolicy = framePolicy;

  if (skip ?? false) {
    patrolLog.log(TestEntry(name: description, status: TestEntryStatus.skip));
  }
  testWidgets(
    description,
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
    (widgetTester) async {
      widgetTester.binding.platformDispatcher.onSemanticsEnabledChanged = () {
        // This callback is empty on purpose. It's a workaround for tests
        // failing on iOS and (from Flutter 3.29.0) on Android.
        //
        // See https://github.com/leancodepl/patrol/issues/1474
      };

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

      await platformAutomator.action.maybe(
        android: platformAutomator.android.configure,
        ios: platformAutomator.ios.configure,
        macos: platformAutomator.macos.configure,
        web: platformAutomator.web.configure,
      );

      // The binding claimed this generation when the program started.
      final generation = patrolBinding.developGeneration;

      final patrolTester = PatrolIntegrationTester(
        tester: widgetTester,
        config: config,
        platformAutomator: platformAutomator,
        entrypointArgs: patrolBinding.entrypointArgs,
      );
      // The phase the native side asked for. It stays null in develop mode,
      // where nothing asks, and on runners that can't relaunch the app.
      int? requestedPhaseIndex;
      if (phasedTest != null && !constants.hotRestartEnabled) {
        final request =
            await patrolBinding.patrolAppService.testExecutionRequested;
        requestedPhaseIndex = request.phaseIndex;
      }

      // Later phases continue the test the first process started, so only the
      // first one logs the start. It's logged before anything below can reject
      // the test, so that a rejection is reported like any other failure.
      if ((requestedPhaseIndex ?? 0) == 0) {
        patrolLog.log(
          TestEntry(
            name: global_state.currentTestFullName,
            status: TestEntryStatus.start,
          ),
        );
      }

      try {
        var callbackToRun = callback;
        var phaseIndex = 0;
        if (phasedTest != null) {
          if (constants.hotRestartEnabled) {
            throw UnsupportedError(
              'Phased Patrol tests are not supported in develop mode',
            );
          }
          if (const bool.fromEnvironment('COVERAGE_ENABLED') &&
              phasedTest.phases.length > 1) {
            throw UnsupportedError(
              'Phased Patrol tests with more than one phase are not supported '
              'with --coverage',
            );
          }
          phaseIndex = phasedTest.phaseIndexFor(requestedPhaseIndex);
          callbackToRun = phasedTest.phaseAt(phaseIndex).callback;
        }

        await runWithDeterministicCursor(
          enabled: deterministicCursor,
          body: () => callbackToRun(patrolTester),
        );
        final continuation = phasedTest?.continuationAfter(phaseIndex);
        if (continuation != null) {
          patrolBinding.patrolAppService.setContinuation(continuation);
        }
      } catch (err, st) {
        // Capture the failing screen before teardown pumps the next frame.
        if (constants.screenshotOnFailureEnabled) {
          await patrolTester.takeNativeScreenshot('failure');
        }
        if (constants.hotRestartEnabled) {
          final details = switch (err) {
            TestFailure(:final message?) => message,
            _ => '$err\n$st',
          };
          // Details first: patrol_mcp stops collecting them at the failure entry.
          details
              .split('\n')
              .forEach((line) => patrolLog.log(ErrorEntry(message: line)));
          patrolLog.log(
            TestEntry(
              name: global_state.currentTestFullName,
              status: TestEntryStatus.failure,
            ),
          );
        }
        rethrow;
      }

      // In develop mode the exception gatherer is off, so exceptions the
      // framework catches (e.g. from `onPressed`) are never reported. The full
      // stack is dumped to the console by `PatrolBinding.reportExceptionNoticed`
      // (forwarded by `patrol develop`); log a short failure entry here for the
      // structured status, without ending the Hot Restart session.
      void reportDevelopException() {
        final caughtException = patrolBinding.takeException();
        if (caughtException == null ||
            isDisposedViewAssertion(caughtException)) {
          return;
        }
        patrolLog.log(
          TestEntry(
            name: global_state.currentTestFullName,
            status: TestEntryStatus.failure,
            error: caughtException.toString(),
          ),
        );
      }

      if (constants.hotRestartEnabled) {
        // Pump once so exceptions from in-flight gesture callbacks are recorded
        // by the framework before we read them.
        await widgetTester.pump();
        reportDevelopException();
      }

      if (debugDefaultTargetPlatformOverride !=
          patrolBinding.workaroundDebugDefaultTargetPlatformOverride) {
        debugDefaultTargetPlatformOverride =
            patrolBinding.workaroundDebugDefaultTargetPlatformOverride;
      }

      if (constants.hotRestartEnabled &&
          global_state.isCurrentTestLastInGroup) {
        // Patrol log that test is finished
        // If test fails this code will not be executed
        patrolLog
          ..log(
            LogEntry(
              message:
                  'All tests were executed. Press "r" to start again or "q" to quit',
            ),
          )
          ..log(
            ConfigEntry(config: const {ConfigEntry.developCompletedKey: true}),
          );
        // Wait indefinitely in develop mode after the last test, reporting
        // exceptions from manual interactions as they happen. On web, bail out
        // once a newer hot-restart generation claims the app or the engine
        // starts tearing the view down, or this loop keeps pumping frames into
        // a disposed EngineFlutterView and floods the console with assertions.
        // `fullyLive` drives frames itself, and a pump left in flight by a hot
        // restart never completes, which freezes this run and everything it holds.
        final selfDriving =
            patrolBinding.framePolicy ==
            LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

        while (isCurrentDevelopGeneration(generation) &&
            patrolBinding.platformDispatcher.implicitView != null) {
          if (!selfDriving) {
            await widgetTester.pump();
          }
          reportDevelopException();
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      }
    },
  );
}

/// Runs [body] with [EditableText.debugDeterministicCursor] set to [enabled],
/// then restores the previous value.
@internal
Future<void> runWithDeterministicCursor({
  required bool enabled,
  required Future<void> Function() body,
}) async {
  final previous = EditableText.debugDeterministicCursor;
  EditableText.debugDeterministicCursor = enabled;
  try {
    await body();
  } finally {
    EditableText.debugDeterministicCursor = previous;
  }
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
  String? tags,
  String? excludeTags,
}) {
  final groupDTO = DartGroupEntry(
    name: name,
    type: GroupEntryType.group,
    entries: [],
    skip: parentGroup.metadata.skip,
    tags: parentGroup.metadata.tags.toList(),
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

    switch (entry) {
      case Test _:
        if (entry.name == 'patrol_test_explorer') {
          // Ignore the bogus test that is used to discover the test structure.
          continue;
        }

        if (level < 1) {
          throw StateError('Test is not allowed to be defined at level $level');
        }

        if (tags != null) {
          final includeTagsSelector = BooleanSelector.parse(tags);

          // If the user provided tags, skip tests that don't match all of them.
          if (!includeTagsSelector.evaluate(entry.metadata.tags.contains)) {
            continue;
          }
        }

        if (excludeTags != null) {
          final excludeTagsSelector = BooleanSelector.parse(excludeTags);

          // Skip tests that do match any tags the user wants to exclude.
          if (excludeTagsSelector.evaluate(entry.metadata.tags.contains)) {
            continue;
          }
        }

        groupDTO.entries.add(
          DartGroupEntry(
            name: name,
            type: GroupEntryType.test,
            entries: [],
            skip: entry.metadata.skip,
            tags: entry.metadata.tags.toList(),
          ),
        );

      case Group _:
        groupDTO.entries.add(
          createDartTestGroup(
            entry,
            name: name,
            level: level + 1,
            maxTestCaseLength: maxTestCaseLength,
            tags: tags,
            excludeTags: excludeTags,
          ),
        );
    }
  }

  return groupDTO;
}

/// Not allowed in a test name, which becomes a file name on the device.
const _pathSeparator = '/';

/// Returns full names of tests in [group] that contain [_pathSeparator].
@internal
List<String> namesWithPathSeparator(DartGroupEntry group) =>
    _namesWithPathSeparator(group, '');

/// Joins names with a space, like the native side does.
List<String> _namesWithPathSeparator(DartGroupEntry group, String parentName) {
  final invalidNames = <String>[];

  for (final entry in group.entries) {
    final fullName = parentName.isEmpty
        ? entry.name
        : '$parentName ${entry.name}';

    switch (entry.type) {
      case GroupEntryType.test:
        if (fullName.contains(_pathSeparator)) {
          invalidNames.add(fullName);
        }
      case GroupEntryType.group:
        invalidNames.addAll(_namesWithPathSeparator(entry, fullName));
    }
  }

  return invalidNames;
}

/// Builds the error message for [invalidNames].
@internal
String pathSeparatorNameError(List<String> invalidNames) =>
    "Test names must not contain '$_pathSeparator', but these do:\n"
    '${invalidNames.map((e) => '  \u2022 $e').join('\n')}'
    "\n\nRemove '$_pathSeparator' from the patrolTest() description or from the "
    'group() name it sits in.';

/// Full names of the tests in [group] that the build-time manifest
/// ([manifestTests]) doesn't list, so no native test runs them.
@internal
List<String> testsMissingFromManifest(
  DartGroupEntry group,
  List<String> manifestTests,
) {
  final listed = manifestTests.toSet();
  return _testNames(group, '').where((n) => !listed.contains(n)).toList();
}

List<String> _testNames(DartGroupEntry group, String parentName) {
  return [
    for (final entry in group.entries)
      ...switch (entry.type) {
        GroupEntryType.test => [_joinName(parentName, entry.name)],
        GroupEntryType.group => _testNames(
          entry,
          _joinName(parentName, entry.name),
        ),
      },
  ];
}

String _joinName(String parentName, String name) =>
    parentName.isEmpty ? name : '$parentName $name';

/// Builds the error message for [missingTests].
@internal
String missingFromManifestError(List<String> missingTests) =>
    'Build-time test discovery did not find these tests, so they never run:\n'
    '${missingTests.map((e) => '  \u2022 $e').join('\n')}'
    '\n\nDiscovery runs on the host, so a test registered only on some '
    'platforms (for example behind Platform.isAndroid) is missing. Use '
    'patrolTargetPlatform for anything that decides whether a test is '
    'registered.';

/// Allows for retrieving the name of a GroupEntry by stripping the names of all ancestor groups.
///
/// Example:
/// parentName = 'example_test myGroup'
/// currentName = 'example_test myGroup myTest'
/// should return 'myTest'
@internal
String deduplicateGroupEntryName(String parentName, String currentName) {
  return currentName.substring(parentName.length + 1, currentName.length);
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
        testCount += reportGroupStructure(
          subgroup,
          indentation: indentation + 5,
        );
      }
    }
  }

  if (indentation == 0) {
    postEvent('testCount', {'testCount': testCount});
  }

  return testCount;
}
