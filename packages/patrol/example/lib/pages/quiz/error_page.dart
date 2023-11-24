import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/icons.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:flutter/material.dart';

Route<void> get errorRoute =>
    MaterialPageRoute(builder: (_) => const _ErrorPage());

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PTIcons.circleX,
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Unfortunately you have selected wrong answer. '
              'Restart the app and try again.',
              textAlign: TextAlign.center,
              style: PTTextStyles.bodyBold,
            ),
          ),
        ],
      ),
    );
  }
}
