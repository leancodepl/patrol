import 'dart:io';

import 'package:flutter/material.dart';

class TextfieldsScreen extends StatefulWidget {
  const TextfieldsScreen({super.key});

  @override
  State<TextfieldsScreen> createState() => _TextfieldsScreenState();
}

class _TextfieldsScreenState extends State<TextfieldsScreen> {
  final _iosTextInputActions = TextInputAction.values
      .where(
        (action) =>
            action != TextInputAction.none &&
            action != TextInputAction.previous,
      )
      .toList();
  final _androidTextInputActions = TextInputAction.values
      .where(
        (action) =>
            action != TextInputAction.continueAction &&
            action != TextInputAction.join &&
            action != TextInputAction.route &&
            action != TextInputAction.emergencyCall
      )
      .toList();
  late final List<TextInputAction> _textInputActions;
  late final List<TextEditingController> _textFieldControllers;
  late final List<bool> _textFieldsSubmitted;

  @override
  void initState() {
    super.initState();
    _textInputActions = Platform.isAndroid
        ? _androidTextInputActions
        : _iosTextInputActions;
    _textFieldControllers = List<TextEditingController>.generate(
      _textInputActions.length,
      (_) => TextEditingController(),
    );
    _textFieldsSubmitted = List<bool>.filled(_textInputActions.length, false);
  }

  @override
  void dispose() {
    for (final controller in _textFieldControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Many Textfields')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _textInputActions.length,
          itemBuilder: (context, index) {
            final action = _textInputActions[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textFieldControllers[index],
                  textInputAction: action,
                  decoration: InputDecoration(
                    labelText: '${action.name} text field',
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _textFieldsSubmitted[index] = true;
                    });
                  },
                ),
                if (_textFieldsSubmitted[index])
                  Text(
                    'Submitted ${action.name}',
                  ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
