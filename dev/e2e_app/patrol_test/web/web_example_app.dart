import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

class WebExampleApp extends StatefulWidget {
  const WebExampleApp({super.key});

  @override
  State<WebExampleApp> createState() => _WebExampleAppState();
}

class _WebExampleAppState extends State<WebExampleApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const _HomePage()),
        GoRoute(path: '/page1', builder: (context, state) => const _Page1()),
        GoRoute(
          path: '/iframe',
          builder: (context, state) => const _IframePage(),
        ),
      ],
    );
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
  const _HomePage();

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
              const _FileDownloadWidget(),
              const Divider(),
              const _DialogWidget(),
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

class _FileDownloadWidget extends StatelessWidget {
  const _FileDownloadWidget();

  Future<void> _handleDownload() async {
    final fileContent = Uint8List.fromList(
      'Hello from Patrol download test!'.codeUnits,
    );

    await FileSaver.instance.saveFile(
      name: 'example',
      bytes: fileContent,
      fileExtension: 'txt',
      mimeType: MimeType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('File Download', style: Theme.of(context).textTheme.titleMedium),
        ElevatedButton.icon(
          onPressed: _handleDownload,
          icon: const Icon(Icons.download),
          label: const Text('Download File'),
        ),
      ],
    );
  }
}

class _DialogWidget extends StatefulWidget {
  const _DialogWidget();

  @override
  State<_DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<_DialogWidget> {
  String? _dialogResult;

  void _handleShowAlert() {
    web.window.alert('This is an alert!');
    setState(() {
      _dialogResult = 'Alert was accepted';
    });
  }

  void _handleShowConfirm() {
    final confirmed = web.window.confirm('Do you confirm?');
    setState(() {
      _dialogResult = confirmed
          ? 'Confirm was accepted'
          : 'Confirm was dismissed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Dialogs', style: Theme.of(context).textTheme.titleMedium),
        ElevatedButton.icon(
          onPressed: _handleShowAlert,
          icon: const Icon(Icons.info),
          label: const Text('Show Alert'),
        ),
        ElevatedButton.icon(
          onPressed: _handleShowConfirm,
          icon: const Icon(Icons.help),
          label: const Text('Show Confirm'),
        ),
        if (_dialogResult != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_dialogResult!),
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
