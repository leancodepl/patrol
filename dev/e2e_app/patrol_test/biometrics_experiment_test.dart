// Compares three ways to drive biometrics on iOS. Run on an erased iPhone
// simulator with Face ID, through `patrol test`:
//
//   xcrun simctl erase <udid>
//   patrol test -t patrol_test/biometrics_experiment_test.dart --device <udid>
//
// Each test records every step instead of stopping at the first failure, and
// prints lines starting with BIOEXP, so one run shows what works.
//
// The experiment API is experimental.
// ignore_for_file: experimental_member_use, unnecessary_ignore

import 'package:flutter/services.dart';

import 'common.dart';

const _enrollment = 'com.apple.BiometricKit.enrollmentChanged';
const _channel = MethodChannel('pl.leancode.patrol/main');

void main() {
  // A: the XCUITest runner posts the Darwin notifications itself.
  patrol('A: runner posts notifications', ($) async {
    final r = _Recorder('A runner');
    await _simulatorScenario(
      $,
      r,
      setEnrolled: (enrolled) => $.platform.ios.postDarwinNotification(
        _enrollment,
        state: enrolled ? 1 : 0,
      ),
      present: (match) async {
        for (final sensor in ['pearl', 'fingerTouch']) {
          await $.platform.ios.postDarwinNotification(
            'com.apple.BiometricKit_Sim.$sensor.${match ? '' : 'no'}match',
          );
        }
      },
    );
    r.finish();
  }, tags: ['ios', 'biometrics']);

  // B: the patrol CLI posts them with `simctl spawn <udid> notifyutil`.
  patrol('B: host posts notifications', ($) async {
    final r = _Recorder('B host');
    await _simulatorScenario(
      $,
      r,
      setEnrolled: (enrolled) => enrolled
          ? $.platform.mobile.enrollBiometrics()
          : $.platform.mobile.unenrollBiometrics(),
      present: (match) => match
          ? $.platform.mobile.passBiometric()
          : $.platform.mobile.failBiometric(),
    );

    // Cancel needs the host too, because Face ID shows Cancel only after a
    // failed attempt.
    await $.platform.mobile.enrollBiometrics();
    await $('Authenticate').tap();
    await Future<void>.delayed(const Duration(seconds: 2));
    try {
      await $.platform.mobile.cancelBiometric();
      r.step(
        'cancel',
        await _waitForStatus($, 'Error: userCanceled'),
        'Error: userCanceled',
      );
    } on Exception catch (err) {
      r.fail('cancel', 'threw $err');
    }
    await $.platform.mobile.unenrollBiometrics();
    r.finish();
  }, tags: ['ios', 'biometrics']);

  // C: the app's LAContext answers from the test, the way device farms do it.
  patrol('C: LAContext interception', ($) async {
    final r = _Recorder('C interception');
    await createApp($);
    await $('Open biometrics screen').scrollTo().tap();

    await _channel.invokeMethod<bool>('biometricInterception', 'enable');
    try {
      r.step('enrolled', await _checkEnrollment($), 'Enrolled: face');

      await $('Authenticate').tap();
      r.step('prompt pending', '${await _waitForPending()}', 'true');

      await _channel.invokeMethod<bool>('biometricInterception', 'fail');
      await $.pump(const Duration(seconds: 1));
      r.step('fail keeps prompt', _status($), 'Authenticating');

      await _channel.invokeMethod<bool>('biometricInterception', 'pass');
      r.step('pass', await _waitForStatus($, 'Authenticated'), 'Authenticated');

      await $('Authenticate').tap();
      await _waitForPending();
      await _channel.invokeMethod<bool>('biometricInterception', 'cancel');
      r.step(
        'cancel',
        await _waitForStatus($, 'Error: userCanceled'),
        'Error: userCanceled',
      );
    } finally {
      await _channel.invokeMethod<bool>('biometricInterception', 'disable');
    }
    r.finish();
  }, tags: ['ios', 'biometrics']);
}

Future<void> _simulatorScenario(
  PatrolIntegrationTester $,
  _Recorder r, {
  required Future<void> Function(bool enrolled) setEnrolled,
  required Future<void> Function(bool match) present,
}) async {
  await createApp($);
  await $('Open biometrics screen').scrollTo().tap();

  try {
    await setEnrolled(false);
    r.step('unenrolled', await _checkEnrollment($), 'No biometrics');

    await setEnrolled(true);
    r.step('enrolled', await _checkEnrollment($), 'Enrolled: face');

    await $('Authenticate').tap();
    final asked = await $.platform.mobile.isPermissionDialogVisible(
      timeout: const Duration(seconds: 5),
    );
    r.note('Face ID permission alert shown: $asked');
    if (asked) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    await Future<void>.delayed(const Duration(seconds: 2));
    await present(false);
    await $.pump(const Duration(seconds: 1));
    r.step('fail keeps prompt', _status($), 'Authenticating');

    // The prompt may still be animating in, so retry the match.
    var status = _status($);
    for (
      var attempt = 1;
      attempt <= 5 && status != 'Authenticated';
      attempt++
    ) {
      await present(true);
      status = await _waitForStatus(
        $,
        'Authenticated',
        timeout: const Duration(seconds: 2),
      );
      r.note('match attempt $attempt: $status');
    }
    r.step('pass', status, 'Authenticated');
  } on Exception catch (err) {
    r.fail('scenario', 'threw $err');
  } finally {
    await setEnrolled(false);
  }
}

String _status(PatrolIntegrationTester $) {
  return $(#biometricsStatus).text ?? '<no status>';
}

Future<String> _checkEnrollment(PatrolIntegrationTester $) async {
  await $('Check enrollment').tap();
  await $.pump(const Duration(milliseconds: 500));
  return _status($);
}

Future<String> _waitForStatus(
  PatrolIntegrationTester $,
  String expected, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await $.pump(const Duration(milliseconds: 200));
    if (_status($) == expected) {
      break;
    }
  }
  return _status($);
}

Future<bool> _waitForPending() async {
  final end = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(end)) {
    if (await _channel.invokeMethod<bool>(
          'biometricInterception',
          'isPending',
        ) ??
        false) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  return false;
}

class _Recorder {
  _Recorder(this.option);

  final String option;
  final _failures = <String>[];

  void step(String name, String actual, String expected) {
    if (actual == expected) {
      print('BIOEXP [$option] $name: ok ($actual)');
    } else {
      fail(name, 'expected "$expected", got "$actual"');
    }
  }

  void fail(String name, String why) {
    _failures.add(name);
    print('BIOEXP [$option] $name: FAILED, $why');
  }

  void note(String message) => print('BIOEXP [$option] $message');

  void finish() {
    print(
      'BIOEXP [$option] summary: ${_failures.isEmpty ? 'all ok' : 'failed: ${_failures.join(', ')}'}',
    );
    expect(_failures, isEmpty, reason: '$option failed steps');
  }
}
