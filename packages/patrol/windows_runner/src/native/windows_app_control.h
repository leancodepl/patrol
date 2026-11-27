#pragma once

#include <chrono>
#include <optional>
#include <string>

#include "com_utils.h"

namespace patrol {

class WindowsAppControl {
 public:
  static int LaunchApp(const std::string& app_path,
                       const std::optional<std::string>& arguments = std::nullopt,
                       bool activate = true,
                       std::chrono::milliseconds activate_timeout =
                           std::chrono::seconds(15));

  static void ActivateApp(
      const std::optional<std::string>& process_name = std::nullopt,
      const std::optional<std::string>& window_name = std::nullopt,
      const std::optional<int>& process_id = std::nullopt,
      std::chrono::milliseconds timeout = std::chrono::seconds(15));

  // Returns a top-level window matching AND-ed scope fields, or nullptr.
  static ComPtr<IUIAutomationElement> TryFindWindow(
      IUIAutomation* automation,
      const std::optional<std::wstring>& process_name,
      const std::optional<std::wstring>& window_name,
      const std::optional<int>& process_id);
};

}  // namespace patrol
