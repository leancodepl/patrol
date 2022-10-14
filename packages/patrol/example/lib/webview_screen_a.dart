import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreenA extends StatelessWidget {
  const WebViewScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView A'),
      ),
      body: WebView(
        debuggingEnabled: true,
        initialUrl: 'https://leancode.co',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) => print('WebView created'),
        onPageStarted: (url) => print('Page started loading: $url'),
        onProgress: (progress) {
          print('WebView is loading (progress : $progress%)');
        },
        onPageFinished: (url) => print('Page finished loading: $url'),
      ),
    );
  }
}
