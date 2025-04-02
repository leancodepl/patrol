import 'package:flutter/material.dart';

class ScreenWithLongButton extends StatelessWidget {
  const ScreenWithLongButton({
    super.key,
    required this.width,
    required this.testedWidget,
  });

  final double width;
  final Widget testedWidget;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 2 * width,
          child: Center(
            child: SizedBox(
              width: width,
              child: testedWidget,
            ),
          ),
        ),
      ),
    );
  }
}
