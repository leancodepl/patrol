import 'package:flutter/material.dart' show MaterialApp, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/custom_finders.dart';

// See how finders are tested in `package:flutter_test`:
// https://github.com/flutter/flutter/blob/master/packages/flutter_test/test/finders_test.dart

void main() {
  group('Maestro finders work the same as Flutter finders (1)', () {
    maestroTest('(simple case 1)', ($) async {
      final flutterFinder = find.byType(Text);
      final maestroFinder = $(Text);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(simple case 2)', ($) async {
      final flutterFinder = find.byKey(const Key('someKey'));
      final maestroFinder = $(#someKey);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(simple case 3)', ($) async {
      final flutterFinder = find.byIcon(Icons.home);
      final maestroFinder = $(Icons.home);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 1)', ($) async {
      final flutterFinder = find.descendant(
        of: find.byType(Container),
        matching: find.byType(Text),
      );

      final maestroFinder = $(Container).$(Text);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 2)', ($) async {
      final flutterFinder = find.descendant(
        of: find.descendant(
          of: find.byType(MaterialApp),
          matching: find.byType(Container),
        ),
        matching: find.byType(Text),
      );

      final maestroFinder = $(MaterialApp).$(Container).$(Text);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 3)', ($) async {
      final flutterFinder = find.descendant(
        of: find.ancestor(
          of: find.text('layer'),
          matching: find.byType(MaterialApp),
        ),
        matching: find.byKey(const Key('SomeKey')),
      );

      final maestroFinder = $(MaterialApp).containing('layer').$(#SomeKey);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 4)', ($) async {
      final flutterFinder = find.ancestor(
        of: find.ancestor(
          of: find.byKey(const Key('SomeKey')),
          matching: find.text('layer'),
        ),
        matching: find.byType(MaterialApp),
      );

      final maestroFinder =
          $(MaterialApp).containing($('layer').containing(#SomeKey));

      expect(flutterFinder.toString(), maestroFinder.toString());
    });
  });

  group('Maestro finders work the same as Flutter finders (2)', () {
    Future<void> pump(MaestroTester $) async {
      await $.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Text('data'),
        ),
      );
    }

    maestroTest('first', ($) async {
      await pump($);
      expect($(Text).first.toString(), find.byType(Text).first.toString());
      expect(
        $('data').first.toString(),
        find.text('data', findRichText: true).first.toString(),
      );
    });

    maestroTest('last', ($) async {
      await pump($);
      expect($(Text).last.toString(), find.byType(Text).last.toString());
      expect(
        $('data').last.toString(),
        find.text('data', findRichText: true).last.toString(),
      );
    });

    maestroTest('at index', ($) async {
      await pump($);
      expect($(Text).at(0).toString(), find.byType(Text).at(0).toString());
      expect(
        $('data').at(0).toString(),
        find.text('data', findRichText: true).at(0).toString(),
      );
    });
  });

  group('Maestro finder', () {
    maestroTest('waits until widget exists', ($) async {});

    maestroTest('waits until widget is visible', ($) async {});

    maestroTest('drags to existing and visible widget', ($) async {});

    maestroTest('drags to existing but not visible widget', ($) async {
      await $.pumpWidget(
        MaterialApp(
          home: LayoutBuilder(
            builder: (_, constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('top text'),
                    SizedBox(height: constraints.maxHeight),
                    const Text('bottom text'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect($('top text').exists, true);
      expect($('top text').visible, true);

      expect($('bottom text').exists, true);
      expect($('bottom text').visible, false);

      await $('bottom text').dragTo();

      expect($('top text').visible, false);
      expect($('bottom text').visible, true);
    });

    /* maestroTest('drags to non existing and not visible widget', ($) async {
      await $.pumpWidget(
        MaterialApp(
          home: LayoutBuilder(
            builder: (_, constraints) {
              return ListView(
                children: [
                  const Text('top text'),
                  SizedBox(height: constraints.maxHeight),
                  const Text('bottom text'),
                ],
              );
            },
          ),
        ),
      );

      expect($('top text').exists, true);
      expect($('top text').visible, true);

      expect($('bottom text').exists, false);
      expect($('bottom text').visible, false);

      print('here 1');
      await $('bottom text').dragTo(step: 100, view: $(ListView));

      expect($('top text').visible, false);
      expect($('bottom text').visible, true);
    }); */
  });
}
