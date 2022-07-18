import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors/custom_selectors.dart';

void main() {
  group('finds widget by', () {
    maestroTest('type', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          home: Text('Hello'),
        ),
      );
      expect($(Text), findsOneWidget);

      expect($(Text).first, findsOneWidget);
      expect($(Text).last, findsOneWidget);
      expect($(Text).at(0), findsOneWidget);
    });

    maestroTest('key', ($) async {
      await $.pumpWidgetAndSettle(
        MaterialApp(
          home: Column(
            children: const [
              Text('Hello', key: Key('hello')),
              Text('Some text', key: Key('Some \n long, complex\t\ttext!')),
              Text('Another text', key: ValueKey({'key': 'value'})),
            ],
          ),
        ),
      );
      expect($(#hello), findsOneWidget);
      expect($(const Symbol('hello')), findsOneWidget);
      expect($(const Key('hello')), findsOneWidget);

      expect($(const Symbol('Some \n long, complex\t\ttext!')), findsOneWidget);
      expect($(const Key('Some \n long, complex\t\ttext!')), findsOneWidget);

      expect($(const ValueKey({'key': 'value'})), findsOneWidget);
      expect($(const ValueKey({'key': 'value1'})), findsNothing);
    });

    maestroTest('text', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(home: Text('Hello')),
      );
      expect($('Hello'), findsOneWidget);
    });

    maestroTest('text it contains', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(home: Text('Hello')),
      );
      expect($(RegExp('Hello')), findsOneWidget);
      expect($(RegExp('Hell.*')), findsOneWidget);
      expect($(RegExp('.*ello')), findsOneWidget);
      expect($(RegExp('.*ell.*')), findsOneWidget);
    });

    maestroTest('icon', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          home: Icon(Icons.code),
        ),
      );

      expect($(Icons.code), findsOneWidget);
    });

    maestroTest(
      'text using a nested MaestroFinder',
      ($) async {
        await $.pumpWidgetAndSettle(
          const MaterialApp(home: Text('Hello')),
        );
        expect($($('Hello')), findsOneWidget);
      },
    );

    maestroTest(
      'text using many nested MaestroFinders',
      ($) async {
        await $.pumpWidgetAndSettle(
          const MaterialApp(home: Text('Hello')),
        );

        expect($($($($('Hello')))), findsOneWidget);
      },
    );

    maestroTest('using Finder', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(home: Text('Hello')),
      );

      expect($(find.text('Hello')), findsOneWidget);
    });
  });

  group('smoke tests', () {
    Widget app() => MaterialApp(
          key: const Key('app'),
          home: Column(
            children: [
              Container(
                key: const Key('container'),
                child: const Text('Hello 1', key: Key('helloText')),
              ),
              const SizedBox(
                key: Key('sizedbox'),
                child: Text('Hello 2', key: Key('helloText')),
              ),
              const SizedBox(child: Icon(Icons.code)),
            ],
          ),
        );

    maestroTest('finds by parent', ($) async {
      await $.pumpWidgetAndSettle(app());

      expect($(MaterialApp).$(Text), findsNWidgets(2));
      expect($(MaterialApp).$(#helloText), findsNWidgets(2));

      expect($(MaterialApp).$(Text).at(0), findsOneWidget);
      expect($(MaterialApp).$(Text).at(1), findsOneWidget);

      expect($(Container).$(Text), findsOneWidget);
      expect($(SizedBox).$(Text), findsOneWidget);
      expect($(Container).$('Hello 2'), findsNothing);
      expect($(SizedBox).$('Hello 1'), findsNothing);

      expect($(MaterialApp).$(Container).$(Text), findsOneWidget);
      expect($(MaterialApp).$(Container).$('Hello 1'), findsOneWidget);
      expect($(MaterialApp).$(SizedBox).$('Hello 2'), findsOneWidget);
    });

    maestroTest('finds by parent and with descendant', ($) async {
      await $.pumpWidgetAndSettle(app());

      expect($(SizedBox).withDescendant(Text), findsOneWidget);
      expect($(Column).withDescendant('Hello 2'), findsOneWidget);

      final columnFinder = $(Column).withDescendant(
        $(Container).withDescendant('Hello 1'),
      );
      expect(columnFinder, findsOneWidget);
      expect(columnFinder.finder.evaluate().first.widget.runtimeType, Column);

      expect(
        $(Column).withDescendant(Container).withDescendant(#helloText),
        findsNWidgets(2),
      );
    });

    maestroTest('bug', ($) async {
      await $.pumpWidgetAndSettle(
        MaterialApp(
          home: Column(
            children: const [
              AppDataTableRow(
                text: 'nothing important',
                child: Text('boi', key: Key('HSV')),
              ),
              AppDataTableRow(
                text: 'layer',
                child: Text('boi', key: Key('HSV')),
              ),
            ],
          ),
        ),
      );

      expect(
        $(AppDataTableRow).withDescendant($('layer')).$(#HSV),
        findsOneWidget,
      );

      expect(
        $(AppDataTableRow).withDescendant($('laye')).$(#HSV),
        findsNothing,
      );

      expect(
        $(AppDataTableRow).withDescendant($('laye').$(#HSV)),
        findsNothing,
      );

      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('layer'),
            matching: find.byType(AppDataTableRow),
          ),
          matching: find.byKey(const Key('HSV')),
        ),
        findsOneWidget,
      );
    });
  });
}

class AppDataTableRow extends StatelessWidget {
  const AppDataTableRow({
    Key? key,
    required this.text,
    required this.child,
  }) : super(key: key);

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text),
        child,
      ],
    );
  }
}
