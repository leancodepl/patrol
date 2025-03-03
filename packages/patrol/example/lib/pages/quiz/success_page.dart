import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/images.dart';
import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:flutter/material.dart';

Route<void> get successRoute =>
    MaterialPageRoute(builder: (_) => const _SuccessPage());

class _SuccessPage extends StatelessWidget {
  const _SuccessPage();

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(child: PTImages.confetti),
          Center(
            child: Container(
              width: double.infinity,
              height: 76,
              alignment: Alignment.center,
              color: PTColors.lcBlack.withValues(alpha: 0.9),
              child: Text(
                'Congratulations!',
                style: PTTextStyles.h2,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: PTElevatedButton(
              onPressed: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
              caption: 'Start again',
            ),
          ),
        ],
      ),
    );
  }
}
