import 'package:meta/meta.dart';

/// Posture of a foldable device. **Experimental.**
@experimental
enum FoldPosture {
  /// Folded shut. The app shows on the cover display.
  closed(0),

  /// Half open.
  halfOpen(130),

  /// Fully open.
  open(180);

  const FoldPosture(this.hingeAngle);

  /// Hinge angle on an iOS simulator, in degrees.
  final double hingeAngle;
}
