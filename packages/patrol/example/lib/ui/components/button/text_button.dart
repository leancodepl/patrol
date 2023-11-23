import 'package:flutter/material.dart';
import 'package:patrol_challenge/ui/style/colors.dart';
import 'package:patrol_challenge/ui/style/test_style.dart';

class PTTextButton extends StatelessWidget {
  const PTTextButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStatePropertyAll(
          PTColors.lcYellow.withOpacity(0.2),
        ),
      ),
      onPressed: onPressed,
      child: Center(
        child: Text(
          text,
          style: PTTextStyles.bodyBold.copyWith(
            color: PTColors.lcYellow,
          ),
        ),
      ),
    );
  }
}
