/// Common Win32 virtual-key codes for `WindowsAutomator.pressKey`.
///
/// The sidecar wire format stays a numeric `keyCode`; these constants avoid
/// magic hex in tests. Letter keys are the unshifted VK values (`A`–`Z`);
/// pass `shift: true` for uppercase / shifted symbols.
///
/// See also: https://learn.microsoft.com/windows/win32/inputdev/virtual-key-codes
abstract final class WindowsKey {
  /// VK_RETURN
  static const enter = 0x0D;

  /// VK_ESCAPE
  static const escape = 0x1B;

  /// VK_TAB
  static const tab = 0x09;

  /// VK_SPACE
  static const space = 0x20;

  /// VK_BACK
  static const backspace = 0x08;

  /// VK_DELETE
  static const delete = 0x2E;

  /// VK_LEFT
  static const arrowLeft = 0x25;

  /// VK_UP
  static const arrowUp = 0x26;

  /// VK_RIGHT
  static const arrowRight = 0x27;

  /// VK_DOWN
  static const arrowDown = 0x28;

  /// VK_HOME
  static const home = 0x24;

  /// VK_END
  static const end = 0x23;

  /// VK_PRIOR
  static const pageUp = 0x21;

  /// VK_NEXT
  static const pageDown = 0x22;

  /// Letter A (`0x41`). Use `shift: true` for uppercase.
  static const a = 0x41;

  /// Letter B
  static const b = 0x42;

  /// Letter C
  static const c = 0x43;

  /// Letter D
  static const d = 0x44;

  /// Letter E
  static const e = 0x45;

  /// Letter F
  static const f = 0x46;

  /// Letter G
  static const g = 0x47;

  /// Letter H
  static const h = 0x48;

  /// Letter I
  static const i = 0x49;

  /// Letter J
  static const j = 0x4A;

  /// Letter K
  static const k = 0x4B;

  /// Letter L
  static const l = 0x4C;

  /// Letter M
  static const m = 0x4D;

  /// Letter N
  static const n = 0x4E;

  /// Letter O
  static const o = 0x4F;

  /// Letter P
  static const p = 0x50;

  /// Letter Q
  static const q = 0x51;

  /// Letter R
  static const r = 0x52;

  /// Letter S
  static const s = 0x53;

  /// Letter T
  static const t = 0x54;

  /// Letter U
  static const u = 0x55;

  /// Letter V
  static const v = 0x56;

  /// Letter W
  static const w = 0x57;

  /// Letter X
  static const x = 0x58;

  /// Letter Y
  static const y = 0x59;

  /// Letter Z
  static const z = 0x5A;

  /// Digit 0
  static const digit0 = 0x30;

  /// Digit 1
  static const digit1 = 0x31;

  /// Digit 2
  static const digit2 = 0x32;

  /// Digit 3
  static const digit3 = 0x33;

  /// Digit 4
  static const digit4 = 0x34;

  /// Digit 5
  static const digit5 = 0x35;

  /// Digit 6
  static const digit6 = 0x36;

  /// Digit 7
  static const digit7 = 0x37;

  /// Digit 8
  static const digit8 = 0x38;

  /// Digit 9
  static const digit9 = 0x39;

  /// F1
  static const f1 = 0x70;

  /// F2
  static const f2 = 0x71;

  /// F3
  static const f3 = 0x72;

  /// F4
  static const f4 = 0x73;

  /// F5
  static const f5 = 0x74;

  /// F6
  static const f6 = 0x75;

  /// F7
  static const f7 = 0x76;

  /// F8
  static const f8 = 0x77;

  /// F9
  static const f9 = 0x78;

  /// F10
  static const f10 = 0x79;

  /// F11
  static const f11 = 0x7A;

  /// F12
  static const f12 = 0x7B;
}
