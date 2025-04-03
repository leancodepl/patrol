import 'package:flutter/material.dart';

class ScreenWithPartiallyVisibleWidget extends StatelessWidget {
  const ScreenWithPartiallyVisibleWidget({
    super.key,
    required this.width,
    required this.testedWidget,
  });

  final double width;
  final Widget testedWidget;

  @override
  Widget build(BuildContext context) {
    // The idea here is to have a scrollable view with a widget,
    // which only a part is visible on the screen by default.
    // Whole view is 2*width wide, and testedWidget is in the center.
    // Useful in testing interactions with `alignment` argument
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
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
      ),
    );
  }
}
