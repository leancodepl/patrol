import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Present as a modern mobile Chrome (the default WebView UA carries a
      // "; wv" marker that some SPAs treat as an unsupported browser).
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36',
      )
      ..setOnConsoleMessage(
        (message) => print('WebView console [${message.level}]: ${message.message}'),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => print('WebView progress: $progress'),
          onPageStarted: (url) => print('WebView started loading: $url'),
          onPageFinished: (url) => print('WebView finished loading: $url'),
          onWebResourceError: (error) => print('WebView error: $error'),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
