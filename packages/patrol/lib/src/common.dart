import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/binding.dart';
import 'package:patrol/src/custom_finders/patrol_tester.dart';
import 'package:patrol/src/native/native.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/group_entry.dart';
import 'package:test_api/src/backend/invoker.dart';
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

  if (nativeAutomation) {
    switch (bindingType) {
      case BindingType.patrol:
        nativeAutomator = NativeAutomator(config: nativeAutomatorConfig);

        final binding = PatrolBinding.ensureInitialized();
        binding.framePolicy = framePolicy;
        binding.nativeAutomator = nativeAutomator;
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
      final invoker = Invoker.current;
      print('DEBUG 0 after invoker: $invoker');

      for (final group in Invoker.current!.liveTest.groups) {
        _printTestEntry(group);
      }

      await nativeAutomator?.configure();

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

/// Prints test entry.
///
/// If [entry] is a group, then it's recursively printed as well.
void _printTestEntry(GroupEntry entry, {int level = 0}) {
  final padding = '  ' * level;
  if (entry is Group) {
    print('$padding Group: ${entry.name}');
    for (final groupEntry in entry.entries) {
      _printTestEntry(groupEntry, level: level + 1);
    }
  } else if (entry is Test) {
    print('$padding Test: ${entry.name}');
  }
}
