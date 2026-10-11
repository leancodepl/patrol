import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/devtools_service_extensions/flutter_tree.dart';

Map<String, Object> _byType(List<Map<String, Object>> tree, String type) =>
    tree.firstWhere((e) => e['type'] == type);

void main() {
  testWidgets('a button is one element with its key and text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            key: const ValueKey('save'),
            onPressed: () {},
            child: const Text('Save'),
          ),
        ),
      ),
    );

    final tree = const FlutterTree().collect();
    final button = _byType(tree, 'ElevatedButton');

    expect(button['key'], 'save');
    expect(button['text'], 'Save');
    expect(
      tree.where((e) => e['text'] == 'Save'),
      hasLength(1),
      reason: 'the inner Text is part of the button, not its own element',
    );
  });

  testWidgets('reports form state: typed text, checkbox, switch', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextFormField(
                key: const ValueKey('title'),
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              Checkbox(value: true, onChanged: (_) {}),
              const Switch(value: false, onChanged: null),
            ],
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(EditableText), 'Groceries');
    await tester.pump();

    final tree = const FlutterTree().collect();
    final field = _byType(tree, 'TextFormField');

    expect(field['key'], 'title');
    expect(field['label'], 'Title');
    expect(
      field['value'],
      'Groceries',
      reason: 'the field has no controller of its own',
    );
    expect(_byType(tree, 'Checkbox')['value'], 'true');
    expect(_byType(tree, 'Switch')['value'], 'false');
    expect(_byType(tree, 'Switch')['enabled'], false);
  });

  testWidgets('leaves out widgets of a route below the current one', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(body: Text('First page')),
      ),
    );
    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Second page')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final texts = const FlutterTree().collect().map((e) => e['text']);

    expect(texts, contains('Second page'));
    expect(texts, isNot(contains('First page')));
  });

  testWidgets('masks an obscured field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TextField(obscureText: true))),
    );
    await tester.enterText(find.byType(EditableText), 'secret');
    await tester.pump();

    expect(
      _byType(const FlutterTree().collect(), 'TextField')['value'],
      '••••••',
    );
  });

  testWidgets('lists a title once and no framework slots', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: AppBar(title: const Text('Sign up'))),
      ),
    );

    final tree = const FlutterTree().collect();

    expect(tree.where((e) => e['text'] == 'Sign up'), hasLength(1));
    expect(tree.where((e) => e['key'] != null), isEmpty);
  });

  testWidgets('lists keyed controls inside another control', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(
                key: const ValueKey('password'),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    key: const ValueKey('reveal'),
                    onPressed: () {},
                    icon: const Icon(Icons.visibility),
                  ),
                ),
              ),
              ListTile(
                key: const ValueKey('row'),
                title: const Text('Wi-Fi'),
                onTap: () {},
                trailing: TextButton(
                  key: const ValueKey('forget'),
                  onPressed: () {},
                  child: const Text('Forget'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final tree = const FlutterTree().collect();
    final keys = tree.map((e) => e['key']).whereType<String>();

    expect(keys, containsAll(['password', 'reveal', 'row', 'forget']));
    expect(
      _byType(tree, 'ListTile')['text'],
      'Wi-Fi',
      reason: 'the keyed trailing button is listed with its own text',
    );
    expect(
      tree.where((e) => e['type'] == 'InkWell'),
      isEmpty,
      reason: 'the InkWells the buttons build are parts of them',
    );
  });

  testWidgets('leaves hidden text out of a control', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Save'),
                Visibility(visible: false, child: Text('Saving…')),
                Offstage(child: Text('Saved')),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      _byType(const FlutterTree().collect(), 'ElevatedButton')['text'],
      'Save',
    );
  });

  testWidgets('reports disabled radio, dropdown and popup menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              // A radio outside a RadioGroup, disabled the pre-3.35 way.
              // ignore: deprecated_member_use
              const Radio<int>(value: 1, groupValue: 1),
              DropdownButton<int>(items: const [], onChanged: null),
              PopupMenuButton<int>(
                enabled: false,
                itemBuilder: (_) => const [],
              ),
              RadioGroup<int>(
                groupValue: 1,
                onChanged: (_) {},
                child: const Radio<int>(key: ValueKey('grouped'), value: 2),
              ),
            ],
          ),
        ),
      ),
    );

    final tree = const FlutterTree().collect();

    expect(
      tree.firstWhere(
        (e) => e['type'] == 'Radio<int>' && e['key'] == null,
      )['enabled'],
      false,
    );
    expect(_byType(tree, 'DropdownButton<int>')['enabled'], false);
    expect(_byType(tree, 'PopupMenuButton<int>')['enabled'], false);
    expect(
      tree.firstWhere((e) => e['key'] == 'grouped').containsKey('enabled'),
      isFalse,
      reason: 'a radio in a RadioGroup is enabled without onChanged',
    );
  });
}
