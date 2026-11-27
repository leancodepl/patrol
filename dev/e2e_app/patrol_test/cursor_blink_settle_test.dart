import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class _TextFieldScreen extends StatefulWidget {
  const _TextFieldScreen();

  @override
  State<_TextFieldScreen> createState() => _TextFieldScreenState();
}

class _TextFieldScreenState extends State<_TextFieldScreen> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TextField(key: Key('materialField')),
              const CupertinoTextField(key: Key('cupertinoField')),
              ElevatedButton(
                key: const Key('counterButton'),
                onPressed: () => setState(() => _taps++),
                child: Text('taps: $_taps'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The animated cursor (iOS, CupertinoTextField) used to make these time out.
const _config = PatrolTesterConfig(
  printLogs: true,
  settlePolicy: SettlePolicy.settle,
  settleTimeout: Duration(seconds: 2),
);

Future<void> _tapWhileFocused(PatrolIntegrationTester $, Key field) async {
  await $.pumpWidgetAndSettle(const _TextFieldScreen());

  await $(field).tap();
  await $(#counterButton).tap();

  expect($('taps: 1'), findsOneWidget);
}

void main() {
  patrolTest(
    'settles while a Material TextField is focused',
    config: _config,
    ($) => _tapWhileFocused($, const Key('materialField')),
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );

  patrolTest(
    'settles while a CupertinoTextField is focused',
    config: _config,
    ($) => _tapWhileFocused($, const Key('cupertinoField')),
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
