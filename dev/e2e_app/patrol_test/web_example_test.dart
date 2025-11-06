import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'common.dart';

void main() {
  patrol('dark mode', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await $.native2.enableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Dark Mode Active'), findsOneWidget);

    await $.native2.disableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Light Mode Active'), findsOneWidget);

    await $.native2.enableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Dark Mode Active'), findsOneWidget);
  });

  patrol('clipboard and clicks', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await $(TextField).scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.pressKey(key: 'a');
    await $.native2.pressKey(key: 'b');
    await $.native2.pressKeyCombo(keys: ['Control', 'a']);
    await $.native2.pressKeyCombo(keys: ['Control', 'c']);
    await $.native2.pressKeyCombo(keys: ['Control', 'v']); // ab
    await $.native2.pressKeyCombo(keys: ['Control', 'v']); // abab
    await $.native2.pressKeyCombo(keys: ['Control', 'a']);
    await $.native2.pressKeyCombo(keys: ['Control', 'c']);

    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.grantPermissions(
      permissions: ['clipboard-read', 'clipboard-write'],
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect(await $.native2.getClipboard(), 'abab');
    await $.native2.setClipboard(text: 'test');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect(await $.native2.getClipboard(), 'test');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.clearPermissions();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect(
      await $.native2.getClipboard().timeout(
        const Duration(seconds: 3),
        onTimeout: () => 'error',
      ),
      'error',
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  patrol('navigation', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await Future<void>.delayed(const Duration(seconds: 3));

    await $('Go to Page 1').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 3));

    expect($('This is Page 1'), findsOneWidget);

    await $.native2.goBack();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 3));

    expect($('This is the home page'), findsOneWidget);

    await $.native2.goForward();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 3));

    expect($('This is Page 1'), findsOneWidget);
  });

  patrol('cookies', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await $.native2.addCookie(
      name: 'test_cookie',
      value: 'cookie_value',
      url: 'http://localhost:8080',
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    var cookies = await $.native2.getCookies();
    print('=============$cookies');
    var testCookie = cookies.firstWhere(
      (c) => c['name'] == 'test_cookie',
      orElse: LinkedHashMap<Object?, Object?>.new,
    );
    expect(testCookie['value'], 'cookie_value');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.native2.clearCookies();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    cookies = await $.native2.getCookies();
    testCookie = cookies.firstWhere(
      (c) => c['name'] == 'test_cookie',
      orElse: LinkedHashMap<Object?, Object?>.new,
    );
    expect(testCookie.isEmpty, isTrue);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });

  // patrol('file upload', ($) async {
  //   await $.pumpWidgetAndSettle(const ExampleApp());

  //   expect($(#uploaded_file_name), findsNothing);

  //   await $('Upload File').scrollTo().tap();
  //   await $.pumpAndSettle();
  //   await Future<void>.delayed(const Duration(seconds: 1));

  //   expect($(#uploaded_file_name), findsOneWidget);
  //   expect($('Uploaded: example_file.txt'), findsOneWidget);
  //   await $.pumpAndSettle();
  //   await Future<void>.delayed(const Duration(seconds: 2));
  // });
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String? _uploadedFileName;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => _HomePage(
            uploadedFileName: _uploadedFileName,
            onUpload: _handleFileUpload,
          ),
        ),
        GoRoute(path: '/page1', builder: (context, state) => const _Page1()),
      ],
    );
  }

  void _handleFileUpload() {
    setState(() {
      _uploadedFileName = 'example_file.txt';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: _router,
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.uploadedFileName, required this.onUpload});

  final String? uploadedFileName;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Text(
                    isDark ? 'Dark Mode Active' : 'Light Mode Active',
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                },
              ),
              Text(
                'This is the home page',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter text',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
              ),
              if (uploadedFileName != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Uploaded: $uploadedFileName',
                      key: const Key('uploaded_file_name'),
                    ),
                  ),
                ),
              const Divider(),
              Text(
                'Navigation',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/page1'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Go to Page 1'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 1')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This is Page 1',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
