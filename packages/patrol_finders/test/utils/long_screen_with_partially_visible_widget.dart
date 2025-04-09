import 'package:flutter/material.dart';

class LongScreenWithPartiallyVisibleWidget extends StatelessWidget {
  const LongScreenWithPartiallyVisibleWidget({
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
    // The difference between this widget and `ScreenWithPartiallyVisibleWidget`
    // is that this one is for testing scrolling vertically
    return MaterialApp(
      home: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 2000,
            ),
            SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }
}
