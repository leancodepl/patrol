import 'package:animations/animations.dart';
import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:flutter/material.dart';

class PTScaffold extends StatelessWidget {
  const PTScaffold({
    super.key,
    this.top,
    required this.body,
    this.bodyKey,
  });

  final Widget? top;
  final Widget body;
  final Key? bodyKey;

  @override
  Widget build(BuildContext context) {
    final top = this.top;

    return PopScope(
      onPopInvokedWithResult: (_, __) => Future.value(false),
      child: Scaffold(
        backgroundColor: PTColors.textDark,
        body: DefaultTextStyle(
          style: PTTextStyles.bodyMedium.copyWith(color: PTColors.textWhite),
          child: SafeArea(
            top: top == null,
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: PTColors.lcBlack,
                  child: child,
                );
              },
              child: Column(
                key: bodyKey,
                children: [
                  if (top != null) top,
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
