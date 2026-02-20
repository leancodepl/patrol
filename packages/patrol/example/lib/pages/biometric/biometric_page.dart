import 'package:example/handlers/biometric_handler.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/style/colors.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Route<void> get biometricRoute =>
    MaterialPageRoute(builder: (_) => const BiometricPage());

class BiometricPage extends StatefulWidget {
  const BiometricPage({super.key});

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  String? _resultText;

  Future<void> _authenticate() async {
    final result = await context.read<BiometricHandler>().authenticate();
    if (!mounted) {
      return;
    }
    setState(() {
      _resultText =
          result ? 'Authentication Successful' : 'Authentication Failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      top: AppBar(
        backgroundColor: PTColors.textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PTColors.lcWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PTElevatedButton(
            caption: 'Authenticate',
            onPressed: _authenticate,
          ),
          if (_resultText != null) ...[
            const SizedBox(height: 24),
            Text(_resultText!),
          ],
        ],
      ).horizontallyPadded24,
    );
  }
}
