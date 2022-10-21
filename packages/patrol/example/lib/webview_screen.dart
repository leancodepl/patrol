import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
  const WebViewScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebView(
        debuggingEnabled: true,
        initialUrl: url,
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
