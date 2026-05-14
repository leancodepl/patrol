import 'package:cross_origin_lib/cross_origin_lib.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

void main() {
  runApp(const AuthApp());
  initPatrolRemoteApp();
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Auth', home: AuthPage());
  }
}

String? _queryParam(String name) =>
    Uri.tryParse(web.window.location.href)?.queryParameters[name];

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _signIn() {
    final returnUrl = _queryParam('return') ?? 'http://localhost:8082';
    final session = Uri.encodeComponent(_email.text);
    final separator = returnUrl.contains('?') ? '&' : '?';
    web.window.location.href = '$returnUrl${separator}session=$session';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('email'),
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('password'),
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('sign_in'),
                onPressed: _signIn,
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
