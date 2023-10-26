import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A [Flex] that doesn't get angry when contents overflow.
///
/// Author: Albert Wolszon
/// Source: https://gist.github.com/Albert221/b7320c9109e7b22dcc31cfda05bcac26
class OverflowingFlex extends Flex {
  const OverflowingFlex({
    super.key,
    required super.direction,
    required super.children,
    this.allowOverflow = true,
    super.mainAxisSize,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
  });

  final bool allowOverflow;

  @override
  _RenderOverflowingFlex createRenderObject(BuildContext context) {
    return _RenderOverflowingFlex(
      direction: direction,
      allowOverflow: allowOverflow,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
    );
  }
}

class _RenderOverflowingFlex extends RenderFlex {
  _RenderOverflowingFlex({
    super.direction,
    bool allowOverflow = true,
    super.mainAxisSize,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
  }) : _allowOverflow = allowOverflow;

  bool _allowOverflow;

  bool get allowOverflow => _allowOverflow;

  set allowOverflow(bool value) {
    if (value != _allowOverflow) {
      _allowOverflow = value;
      markNeedsPaint();
    }
  }

  @override
  void paintOverflowIndicator(
    PaintingContext context,
    Offset offset,
    Rect containerRect,
    Rect childRect, {
    List<DiagnosticsNode>? overflowHints,
  }) {
    if (_allowOverflow) {
      // Don't log or show overflow indicator. Everything's good ova here.
    } else {
      super.paintOverflowIndicator(
        context,
        offset,
        containerRect,
        childRect,
        overflowHints: overflowHints,
      );
    }
  }
}
