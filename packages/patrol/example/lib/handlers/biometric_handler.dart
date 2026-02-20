import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHandler {
  BiometricHandler(this._localAuth);

  final LocalAuthentication _localAuth;

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        biometricOnly: true,
      );
    } on Exception catch (e) {
      debugPrint('BiometricHandler: authentication failed: $e');
      return false;
    }
  }
}
