import 'package:flutter/material.dart';

class LongScreenWithLongButton extends StatelessWidget {
  const LongScreenWithLongButton({
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
        child: Column(
          children: [
            const SizedBox(
              height: 2000,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 2 * width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width,
                      child: testedWidget,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
