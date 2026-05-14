import 'package:cross_origin_lib/cross_origin_lib.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

void main() {
  runApp(const PanelApp());
  initPatrolRemoteApp();
}

const _authOrigin = 'http://localhost:8081';
const _canvasOrigin = 'http://localhost:8083';
const _panelOrigin = 'http://localhost:8082';

class PanelApp extends StatelessWidget {
  const PanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Panel', home: PanelPage());
  }
}

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final params = Uri.tryParse(web.window.location.href)?.queryParameters ?? {};
    final session = params['session'];
    final canvas = params['canvas'];

    return Scaffold(
      appBar: AppBar(title: const Text('Panel')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (session == null) ...[
              const Text('Not logged in', key: Key('status_anon')),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('go_login'),
                onPressed: () {
                  final ret = Uri.encodeComponent(_panelOrigin);
                  web.window.location.href = '$_authOrigin/?return=$ret';
                },
                child: const Text('Login'),
              ),
            ] else ...[
              Text(
                canvas == null ? 'Hello $session' : 'Hello $session, canvas value: $canvas',
                key: const Key('status_logged_in'),
              ),
              const SizedBox(height: 16),
              if (canvas == null)
                ElevatedButton(
                  key: const Key('go_canvas'),
                  onPressed: () {
                    final back = Uri.encodeComponent('$_panelOrigin/?session=${Uri.encodeComponent(session)}');
                    web.window.location.href = '$_canvasOrigin/?return=$back';
                  },
                  child: const Text('Open Canvas'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
