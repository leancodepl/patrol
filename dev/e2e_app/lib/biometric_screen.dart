import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final _auth = LocalAuthentication();

  _Status _status = _Status.notAuthenticated;

  Future<void> _authenticate() async {
    setState(() => _status = _Status.authenticating);

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      setState(
        () => _status =
            didAuthenticate ? _Status.authenticated : _Status.notAuthenticated,
      );
    } catch (e) {
      setState(() => _status = _Status.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              key: K.biometricStatusText,
              _status.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              key: K.biometricAuthenticateButton,
              onPressed:
                  _status == _Status.authenticating ? null : _authenticate,
              child: const Text('Authenticate with biometric'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Status {
  notAuthenticated('Not authenticated'),
  authenticating('Authenticating…'),
  authenticated('Authenticated'),
  error('Authentication error');

  const _Status(this.label);
  final String label;
}
