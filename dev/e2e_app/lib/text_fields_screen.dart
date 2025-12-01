import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';

class TextFieldsScreen extends StatefulWidget {
  const TextFieldsScreen({super.key});

  @override
  State<TextFieldsScreen> createState() => _TextFieldsScreenState();
}

class _TextFieldsScreenState extends State<TextFieldsScreen> {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Text Fields')),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const TextField(key: K.textField1),
                ElevatedButton.icon(
                  key: K.buttonFocus,
                  onPressed: () =>
                      FocusScope.of(context).requestFocus(focusNode),
                  label: const Icon(Icons.search),
                  focusNode: focusNode,
                ),
                const TextField(key: K.textField2),
                ElevatedButton.icon(
                  key: K.buttonUnfocus,
                  onPressed: () => FocusScope.of(context).unfocus(),
                  label: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
