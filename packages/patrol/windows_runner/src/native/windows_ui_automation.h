#pragma once

#include <chrono>
#include <optional>
#include <string>

namespace patrol {

struct UiScope {
  std::optional<int> process_id;
  std::optional<std::wstring> process_name;
  std::optional<std::wstring> window_name;

  bool empty() const {
    return !(process_id.has_value() && *process_id > 0) &&
           !process_name.has_value() && !window_name.has_value();
  }
};

struct UiSelector {
  std::optional<std::wstring> name;
  std::optional<std::wstring> automation_id;
  std::optional<std::wstring> class_name;
  int index = 0;
  std::optional<UiScope> within;

  std::string to_string() const;
};

struct UiElementInfo {
  std::optional<std::string> name;
  std::optional<std::string> class_name;
  std::optional<std::string> automation_id;
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;
};

class WindowsUiAutomation {
 public:
  static void WaitUntilVisible(
      const UiSelector& selector,
      std::optional<std::chrono::milliseconds> find_timeout = std::nullopt);

  static bool IsElementVisible(
      const UiSelector& selector,
      std::optional<std::chrono::milliseconds> find_timeout = std::nullopt);

  static void Tap(
      const UiSelector& selector,
      std::optional<std::chrono::milliseconds> find_timeout = std::nullopt);

  static void EnterText(
      const UiSelector& selector,
      const std::string& text,
      std::optional<std::chrono::milliseconds> find_timeout = std::nullopt);

  static std::optional<UiElementInfo> FindElementInfo(
      const UiSelector& selector,
      std::optional<std::chrono::milliseconds> find_timeout = std::nullopt);

  static void PressKey(int key_code,
                       bool shift = false,
                       bool ctrl = false,
                       bool alt = false);
};

}  // namespace patrol
