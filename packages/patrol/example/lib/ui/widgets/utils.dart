import 'package:flutter/cupertino.dart';

extension ColumnPadded on Widget {
  Widget get horizontallyPadded24 => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: this,
      );
}
