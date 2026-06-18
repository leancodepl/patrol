import 'package:flutter/material.dart';

class ApplinkScreen extends StatelessWidget {
  const ApplinkScreen({super.key, required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Applink Screen')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uri: $uri'),
          Text('Path: ${uri.path}'),
          Text('Query: ${uri.query}'),
        ],
      ),
    );
  }
}
