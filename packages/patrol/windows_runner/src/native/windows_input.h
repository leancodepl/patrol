#pragma once

namespace patrol {

class WindowsInput {
 public:
  static void EnsureDpiAware();
  static void TapAtNormalized(double x, double y);
  static void TapAtPixels(int pixel_x, int pixel_y);
  static void PressKey(int key_code,
                       bool shift = false,
                       bool ctrl = false,
                       bool alt = false);
};

}  // namespace patrol
