import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';

class PTElevatedButton extends StatelessWidget {
  const PTElevatedButton({
    super.key,
    this.caption,
    this.trailing,
    required this.onPressed,
  });

  final String? caption;
  final Widget? trailing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final caption = this.caption;
    final trailing = this.trailing;

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ButtonStyle(
          textStyle: _textStyle,
          backgroundColor: _backgroundColor,
          padding: _padding,
          shape: _shape,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: trailing != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (caption != null) Text(caption),
            if (trailing != null) trailing,
          ],
        ).horizontallyPadded24,
      ),
    );
  }

  MaterialStateProperty<EdgeInsetsGeometry?>? get _padding =>
      const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 12));

  MaterialStateProperty<OutlinedBorder?>? get _shape =>
      const MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );

  MaterialStateProperty<Color?>? get _backgroundColor =>
      MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return PTColors.lcYellowPressed;
          } else if (states.contains(MaterialState.disabled)) {
            return PTColors.backgroundDisabled;
          }

          return PTColors.lcYellow;
        },
      );

  MaterialStateProperty<TextStyle?>? get _textStyle =>
      MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return PTTextStyles.bodyMedium
                .copyWith(foreground: Paint()..color = PTColors.textDark);
          } else if (states.contains(MaterialState.disabled)) {
            return PTTextStyles.bodyMedium
                .copyWith(foreground: Paint()..color = PTColors.textDisabled);
          }

          return PTTextStyles.bodyBold
              .copyWith(foreground: Paint()..color = PTColors.textDark);
        },
      );
}
