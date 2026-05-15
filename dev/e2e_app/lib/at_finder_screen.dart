import 'dart:async';

import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';

class AtFinderScreen extends StatefulWidget {
  const AtFinderScreen({super.key});

  @override
  State<AtFinderScreen> createState() => _AtFinderScreenState();
}

class _AtFinderScreenState extends State<AtFinderScreen> {
  var _isFirstItemVisible = false;
  var _isSecondItemVisible = false;
  var _firstItemTapped = 0;
  var _secondItemTapped = 0;

  @override
  void initState() {
    super.initState();

    unawaited(
      Future<void>.delayed(const Duration(seconds: 1)).then((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isFirstItemVisible = true;
        });
      }),
    );

    unawaited(
      Future<void>.delayed(const Duration(seconds: 3)).then((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isSecondItemVisible = true;
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('at() finder')),
      body: ListView(
        children: [
          if (_isFirstItemVisible)
            AtFinderItem(
              onTap: () {
                setState(() {
                  _firstItemTapped++;
                });
              },
            ),
          if (_isSecondItemVisible)
            AtFinderItem(
              onTap: () {
                setState(() {
                  _secondItemTapped++;
                });
              },
            ),
          if (_secondItemTapped > 0)
            Text(
              'Second item tapped $_secondItemTapped',
              key: K.atFinderSecondItemTapped,
            ),
          if (_firstItemTapped > 0)
            Text(
              'First item tapped $_firstItemTapped',
              key: K.atFinderFirstItemTapped,
            ),
        ],
      ),
    );
  }
}

class AtFinderItem extends StatelessWidget {
  const AtFinderItem({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(key: K.atFinderItem, title: Text('Item'), onTap: onTap);
  }
}
