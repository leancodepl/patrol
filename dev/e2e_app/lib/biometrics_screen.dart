import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key});

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen> {
  final _auth = LocalAuthentication();
  var _status = 'Not authenticated';

  Future<void> _authenticate() async {
    setState(() => _status = 'Authenticating');

    String status;
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Patrol checks biometrics',
        biometricOnly: true,
      );
      status = authenticated ? 'Authenticated' : 'Not authenticated';
    } on LocalAuthException catch (err) {
      status = 'Error: ${err.code.name}';
    }

    if (mounted) {
      setState(() => _status = status);
    }
  }

  Future<void> _checkEnrollment() async {
    final biometrics = await _auth.getAvailableBiometrics();
    setState(
      () => _status = biometrics.isEmpty
          ? 'No biometrics'
          : 'Enrolled: ${biometrics.map((b) => b.name).join(', ')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometrics')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_status, key: const Key('biometricsStatus')),
            TextButton(
              onPressed: _checkEnrollment,
              child: const Text('Check enrollment'),
            ),
            TextButton(
              onPressed: _authenticate,
              child: const Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}
