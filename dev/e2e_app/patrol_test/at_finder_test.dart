import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'at() waits until widget at index exists',
    ($) async {
      await $.pumpWidgetAndSettle(const _AtFinderApp());

      await $(_AtFinderItem).at(1).tap();

      await $('Second item tapped 1').waitUntilVisible();

      await $(_AtFinderItem).first.tap();
      await $('First item tapped 1').waitUntilVisible();
      await $(_AtFinderItem).last.tap();
      await $('Second item tapped 2').waitUntilVisible();
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}

class _AtFinderApp extends StatefulWidget {
  const _AtFinderApp();

  @override
  State<_AtFinderApp> createState() => _AtFinderAppState();
}

class _AtFinderAppState extends State<_AtFinderApp> {
  var _isFirstItemVisible = false;
  var _isSecondItemVisible = false;
  var _SecondItemTapped = 0;
  var _FirstItemTapped = 0;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _isFirstItemVisible = true;
      });
    });

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSecondItemVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            if (_isFirstItemVisible) _AtFinderItem(index: 0, onTap: () {
              setState(() {
                _FirstItemTapped++;
              });
            }),
            if (_isSecondItemVisible)
              _AtFinderItem(
                index: 1,
                onTap: () {
                  setState(() {
                    _SecondItemTapped++;
                  });
                },
              ),
            if (_SecondItemTapped > 0)
              Text('Second item tapped $_SecondItemTapped', key: Key('secondItemTapped')),
            if (_FirstItemTapped > 0)
              Text('First item tapped $_FirstItemTapped', key: Key('firstItemTapped')),
          ],
        ),
      ),
    );
  }
}

class _AtFinderItem extends StatelessWidget {
  const _AtFinderItem({required this.index, required this.onTap});

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: _AtFinderItemKey(index),
      title: Text('Item $index'),
      onTap: onTap,
    );
  }
}

class _AtFinderItemKey extends ValueKey<int> {
  const _AtFinderItemKey(super.value);
}
