import 'package:flutter/material.dart';
import 'package:patrol_challenge/ui/components/button/elevated_button.dart';
import 'package:patrol_challenge/ui/components/scaffold.dart';
import 'package:patrol_challenge/ui/images.dart';
import 'package:patrol_challenge/ui/style/colors.dart';
import 'package:patrol_challenge/ui/style/test_style.dart';

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
              color: PTColors.lcBlack.withOpacity(0.9),
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
