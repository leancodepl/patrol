#include "native/windows_input.h"

#include <cmath>
#include <mutex>
#include <vector>

#include <Windows.h>

#include "util.h"

namespace patrol {
namespace {

constexpr UINT kInputKeyboard = 1;
constexpr DWORD kKeyeventfKeyup = 0x0002;
constexpr WORD kVkShift = 0x10;
constexpr WORD kVkControl = 0x11;
constexpr WORD kVkMenu = 0x12;

std::mutex& InputMutex() {
  static std::mutex mutex;
  return mutex;
}

}  // namespace

void WindowsInput::EnsureDpiAware() {
  using SetProcessDpiAwarenessContextFn = BOOL(WINAPI*)(DPI_AWARENESS_CONTEXT);
  const HMODULE user32 = GetModuleHandleW(L"user32.dll");
  if (user32 == nullptr) {
    return;
  }
  const auto fn = reinterpret_cast<SetProcessDpiAwarenessContextFn>(
      GetProcAddress(user32, "SetProcessDpiAwarenessContext"));
  if (fn != nullptr) {
    fn(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
  }
}

void WindowsInput::TapAtNormalized(double x, double y) {
  if (x < 0.0 || x > 1.0 || y < 0.0 || y > 1.0) {
    throw BadRequestError("Normalized coordinates must be in [0,1]");
  }

  const int screen_w = GetSystemMetrics(SM_CXSCREEN);
  const int screen_h = GetSystemMetrics(SM_CYSCREEN);
  if (screen_w <= 0 || screen_h <= 0) {
    throw std::runtime_error("No primary screen available");
  }

  const int pixel_x = static_cast<int>(std::lround(x * (screen_w - 1)));
  const int pixel_y = static_cast<int>(std::lround(y * (screen_h - 1)));
  TapAtPixels(pixel_x, pixel_y);
}

void WindowsInput::TapAtPixels(int pixel_x, int pixel_y) {
  std::lock_guard lock(InputMutex());
  if (!SetCursorPos(pixel_x, pixel_y)) {
    throw std::runtime_error("SetCursorPos failed");
  }
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
}

void WindowsInput::PressKey(int key_code, bool shift, bool ctrl, bool alt) {
  if (key_code < 1 || key_code > 254) {
    throw BadRequestError("Virtual-key code must be in 1..254");
  }

  std::lock_guard lock(InputMutex());

  std::vector<INPUT> inputs;
  inputs.reserve(8);

  auto down = [&](WORD vk) {
    INPUT input{};
    input.type = kInputKeyboard;
    input.ki.wVk = vk;
    inputs.push_back(input);
  };
  auto up = [&](WORD vk) {
    INPUT input{};
    input.type = kInputKeyboard;
    input.ki.wVk = vk;
    input.ki.dwFlags = kKeyeventfKeyup;
    inputs.push_back(input);
  };

  if (ctrl) {
    down(kVkControl);
  }
  if (shift) {
    down(kVkShift);
  }
  if (alt) {
    down(kVkMenu);
  }

  down(static_cast<WORD>(key_code));
  up(static_cast<WORD>(key_code));

  if (alt) {
    up(kVkMenu);
  }
  if (shift) {
    up(kVkShift);
  }
  if (ctrl) {
    up(kVkControl);
  }

  const UINT sent =
      SendInput(static_cast<UINT>(inputs.size()), inputs.data(), sizeof(INPUT));
  if (sent != inputs.size()) {
    throw std::runtime_error("SendInput(pressKey) failed");
  }
}

}  // namespace patrol
