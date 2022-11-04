import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'dialog bug research 1',
    ($) async {
      await $.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    await Future<void>.delayed(const Duration(seconds: 1));

                    await showDialog<void>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Dialog title'),
                          actions: [
                            TextButton(
                              onPressed: Navigator.of(context).pop,
                              child: const Text('Hide dialog'),
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Open dialog'),
                );
              },
            ),
          ),
        ),
      );

      await $('Open dialog').tap();
      await $('Hide dialog').tap();
      expect($('Dialog title'), findsNothing);
    },
  );

  patrolTest(
    'dialog bug research 2',
    ($) async {
      var count = 0;

      await $.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text('count: $count'),
                    TextButton(
                      onPressed: () async {
                        await Future<void>.delayed(const Duration(seconds: 1));

                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Dialog title'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    await Future<void>.delayed(
                                      const Duration(seconds: 1),
                                    );
                                    setState(() => count++);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Hide dialog'),
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Open dialog'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await $('Open dialog').tap();
      await $('Hide dialog').tap();
      expect(await $('count: 1').waitUntilVisible(), findsOneWidget);
      await $.pumpAndSettle();
    },
  );
}
