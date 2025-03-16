import 'package:flutter/material.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Username')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              key: const Key('username_text_field'),
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('username_next_button'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => PasswordPage(
                      username: _usernameController.text,
                    ),
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key, required this.username});
  final String username;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Password'),
        leading: IconButton(
          key: const Key('password_back_button'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              key: const Key('password_text_field'),
              controller: _passwordController,
              autofocus: true,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('password_next_button'),
              onPressed: () {
                if (_passwordController.text.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => WelcomePage(
                        username: widget.username,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Text(
          username,
          key: const Key('welcome_text'),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
