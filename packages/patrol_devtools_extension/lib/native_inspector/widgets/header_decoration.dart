import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';

class HeaderDecoration extends StatelessWidget {
  const HeaderDecoration({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: defaultHeaderHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: defaultBorderSide(Theme.of(context)),
        ),
      ),
      child: child,
    );
  }
}
