import 'package:flutter/material.dart';

class TextFieldsScreen extends StatefulWidget {
  const TextFieldsScreen({super.key});

  @override
  State<TextFieldsScreen> createState() => _TextFieldsScreenState();
}

class _TextFieldsScreenState extends State<TextFieldsScreen> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Fields'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                key: const Key('textFieldUsername'),
                controller: textEditingController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) => searchProduct(),
              ),
              ElevatedButton.icon(
                key: const Key('homepage_search_button'),
                onPressed: searchProduct,
                label: const Icon(Icons.search),
              ),
              const SizedBox(height: 16),
              ...List.generate(40, (index) => 'Item $index').map(
                (item) => ListTile(
                  title: Text(item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchProduct() {
    FocusScope.of(context).unfocus();
  }
}
