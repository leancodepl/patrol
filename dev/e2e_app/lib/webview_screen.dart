import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.title, this.url, this.asset})
    : assert((url == null) != (asset == null));

  final String title;
  final String? url;
  final String? asset;

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => print('WebView progress: $progress'),
          onPageStarted: (url) => print('WebView started loading: $url'),
          onPageFinished: (url) => print('WebView finished loading: $url'),
          onWebResourceError: (error) => print('WebView error: $error'),
        ),
      );
    if (widget.asset case final asset?) {
      controller.loadFlutterAsset(asset);
    } else {
      controller.loadRequest(Uri.parse(widget.url!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
