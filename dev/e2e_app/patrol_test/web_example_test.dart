import 'dart:collection';
import 'dart:convert';
import 'dart:ui_web' as ui_web;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

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

  patrol('file upload', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    expect($(#uploaded_file_name), findsNothing);

    final fileContent = utf8.encode('Hello from Patrol file upload test!');
    final file = UploadFileData(
      name: 'example_file.txt',
      content: fileContent,
      mimeType: 'text/plain',
    );

    final uploadFuture = $.native2.uploadFile(files: [file]);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $('Upload File').scrollTo().tap();

    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await uploadFuture;
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect($(#uploaded_file_name), findsOneWidget);
    expect($('Uploaded: example_file.txt'), findsOneWidget);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  patrol('get dialog message and accept', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    final messageFuture = $.native2.getDialogMessage();
    await $('Show Alert').scrollTo().tap();

    final message = await messageFuture;
    expect(message, 'This is an alert!');

    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });

  patrol('dismiss confirm dialog', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await $.native2.dismissDialog();
    await $('Show Confirm').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });

  patrol('accept confirm dialog', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await $.native2.acceptDialog();
    await $('Show Confirm').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });

  patrol('iframe interactions - scroll, enter text, and tap', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await $('Go to Iframe Test').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Iframe Test'), findsOneWidget);

    final iframeSelector = WebSelector(cssOrXpath: 'iframe');
    final inputSelector = WebSelector(cssOrXpath: '#test-input');
    final buttonSelector = WebSelector(cssOrXpath: '#submit-button');

    await $.native2.scrollToWeb(
      selector: inputSelector,
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.native2.enterTextWeb(
      selector: inputSelector,
      text: 'Hello from Patrol!',
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.native2.tapWeb(
      selector: buttonSelector,
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  patrol('resize window', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    await $.native2.resizeWindow(width: 800, height: 600);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.resizeWindow(width: 1920, height: 1080);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.resizeWindow(width: 1280, height: 720);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String? _dialogResult;
  late final GoRouter _router;
  final _routerRefreshNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => _HomePage(
            dialogResult: _dialogResult,
            onShowAlert: _handleShowAlert,
            onShowConfirm: _handleShowConfirm,
          ),
        ),
        GoRoute(path: '/page1', builder: (context, state) => const _Page1()),
        GoRoute(
          path: '/iframe',
          builder: (context, state) => const _IframePage(),
        ),
      ],
      refreshListenable: _routerRefreshNotifier,
    );
  }

  void _notifyRouterRefresh() {
    _routerRefreshNotifier.value++;
  }

  void _handleShowAlert() {
    web.window.alert('This is an alert!');
    setState(() {
      _dialogResult = 'Alert was accepted';
    });
    _notifyRouterRefresh();
  }

  void _handleShowConfirm() {
    final confirmed = web.window.confirm('Do you confirm?');
    setState(() {
      _dialogResult = confirmed
          ? 'Confirm was accepted'
          : 'Confirm was dismissed';
    });
    _notifyRouterRefresh();
  }

  @override
  void dispose() {
    _routerRefreshNotifier.dispose();
    super.dispose();
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
  const _HomePage({
    required this.dialogResult,
    required this.onShowAlert,
    required this.onShowConfirm,
  });

  final String? dialogResult;
  final VoidCallback onShowAlert;
  final VoidCallback onShowConfirm;

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
              const Divider(),
              const _FileUploadWidget(),
              const Divider(),
              Text('Dialogs', style: Theme.of(context).textTheme.titleMedium),
              ElevatedButton.icon(
                onPressed: onShowAlert,
                icon: const Icon(Icons.info),
                label: const Text('Show Alert'),
              ),
              ElevatedButton.icon(
                onPressed: onShowConfirm,
                icon: const Icon(Icons.help),
                label: const Text('Show Confirm'),
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
              ElevatedButton.icon(
                onPressed: () => context.go('/iframe'),
                icon: const Icon(Icons.web),
                label: const Text('Go to Iframe Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileUploadWidget extends StatefulWidget {
  const _FileUploadWidget();

  @override
  State<_FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<_FileUploadWidget> {
  String? _uploadedFileName;

  Future<void> _handleFileUpload() async {
    // Use file_picker to show the browser's file chooser
    // Playwright will intercept this and provide the file
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _uploadedFileName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('File Upload', style: Theme.of(context).textTheme.titleMedium),
        ElevatedButton.icon(
          onPressed: _handleFileUpload,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
        ),
        if (_uploadedFileName != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Uploaded: $_uploadedFileName',
                key: const Key('uploaded_file_name'),
              ),
            ),
          ),
      ],
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

class _IframePage extends StatefulWidget {
  const _IframePage();

  @override
  State<_IframePage> createState() => _IframePageState();
}

class _IframePageState extends State<_IframePage> {
  static const _iframeViewType = 'iframe-test-view';
  static var _isRegistered = false;

  @override
  void initState() {
    super.initState();
    if (!_isRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(_iframeViewType, (
        int viewId,
      ) {
        final iframe = web.HTMLIFrameElement()
          ..src = 'assets/assets/iframe_content.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
      _isRegistered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iframe Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iframe with scrollable content',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const HtmlElementView(viewType: _iframeViewType),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
