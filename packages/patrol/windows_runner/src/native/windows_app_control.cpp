#include "native/windows_app_control.h"

#include <iostream>
#include <optional>
#include <vector>

#include <TlHelp32.h>
#include <shellapi.h>

#include "util.h"

namespace patrol {
namespace {

class ScopedVariant {
 public:
  explicit ScopedVariant(int value) {
    VariantInit(&v_);
    v_.vt = VT_I4;
    v_.lVal = value;
  }
  explicit ScopedVariant(const wchar_t* value) {
    VariantInit(&v_);
    v_.vt = VT_BSTR;
    v_.bstrVal = SysAllocString(value);
  }
  ~ScopedVariant() { VariantClear(&v_); }
  ScopedVariant(const ScopedVariant&) = delete;
  ScopedVariant& operator=(const ScopedVariant&) = delete;
  VARIANT* get() { return &v_; }

 private:
  VARIANT v_{};
};

bool ProcessExists(DWORD pid) {
  const HANDLE process =
      OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if (process == nullptr) {
    return false;
  }
  DWORD exit_code = 0;
  const bool alive =
      GetExitCodeProcess(process, &exit_code) && exit_code == STILL_ACTIVE;
  CloseHandle(process);
  return alive;
}

std::vector<DWORD> PidsByName(const std::wstring& process_name) {
  std::vector<DWORD> pids;
  const HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (snapshot == INVALID_HANDLE_VALUE) {
    return pids;
  }

  PROCESSENTRY32W entry{};
  entry.dwSize = sizeof(entry);
  if (Process32FirstW(snapshot, &entry)) {
    do {
      std::wstring exe = NormalizeProcessName(entry.szExeFile);
      if (EqualsIgnoreCase(exe, process_name) &&
          ProcessExists(entry.th32ProcessID)) {
        pids.push_back(entry.th32ProcessID);
      }
    } while (Process32NextW(snapshot, &entry));
  }
  CloseHandle(snapshot);
  return pids;
}

bool WindowNameMatches(const std::wstring& actual,
                       const std::wstring& expected) {
  return EqualsIgnoreCase(actual, expected) ||
         ContainsIgnoreCase(actual, expected);
}

std::wstring ElementName(IUIAutomationElement* element) {
  BSTR name = nullptr;
  if (FAILED(element->get_CurrentName(&name)) || name == nullptr) {
    return {};
  }
  std::wstring value(name, SysStringLen(name));
  SysFreeString(name);
  return value;
}

int ElementProcessId(IUIAutomationElement* element) {
  int pid = 0;
  if (FAILED(element->get_CurrentProcessId(&pid))) {
    return 0;
  }
  return pid;
}

std::vector<ComPtr<IUIAutomationElement>> FindAllForProcess(
    IUIAutomation* automation,
    int process_id,
    const std::optional<std::wstring>& window_name) {
  std::vector<ComPtr<IUIAutomationElement>> results;
  ComPtr<IUIAutomationElement> desktop;
  ThrowIfFailed(automation->GetRootElement(desktop.put()), "GetRootElement");

  ScopedVariant type_value(static_cast<int>(UIA_WindowControlTypeId));
  ComPtr<IUIAutomationCondition> type_cond;
  ThrowIfFailed(
      automation->CreatePropertyCondition(
          UIA_ControlTypePropertyId, *type_value.get(), type_cond.put()),
      "CreatePropertyCondition(ControlType)");

  ComPtr<IUIAutomationElementArray> windows;
  ThrowIfFailed(
      desktop->FindAll(TreeScope_Children, type_cond.get(), windows.put()),
      "FindAll(windows)");

  int length = 0;
  ThrowIfFailed(windows->get_Length(&length), "get_Length");
  for (int i = 0; i < length; ++i) {
    ComPtr<IUIAutomationElement> el;
    if (FAILED(windows->GetElement(i, el.put())) || !el) {
      continue;
    }
    if (ElementProcessId(el.get()) != process_id) {
      continue;
    }
    if (window_name.has_value() &&
        !WindowNameMatches(ElementName(el.get()), *window_name)) {
      continue;
    }
    results.push_back(std::move(el));
  }
  return results;
}

std::vector<ComPtr<IUIAutomationElement>> FindAllByTitle(
    IUIAutomation* automation,
    const std::wstring& window_name) {
  std::vector<ComPtr<IUIAutomationElement>> results;
  ComPtr<IUIAutomationElement> desktop;
  ThrowIfFailed(automation->GetRootElement(desktop.put()), "GetRootElement");

  ScopedVariant type_value(static_cast<int>(UIA_WindowControlTypeId));
  ComPtr<IUIAutomationCondition> type_cond;
  ThrowIfFailed(
      automation->CreatePropertyCondition(
          UIA_ControlTypePropertyId, *type_value.get(), type_cond.put()),
      "CreatePropertyCondition(ControlType)");

  ComPtr<IUIAutomationElementArray> windows;
  ThrowIfFailed(
      desktop->FindAll(TreeScope_Children, type_cond.get(), windows.put()),
      "FindAll(windows)");
  int length = 0;
  ThrowIfFailed(windows->get_Length(&length), "get_Length");
  for (int i = 0; i < length; ++i) {
    ComPtr<IUIAutomationElement> el;
    if (FAILED(windows->GetElement(i, el.put())) || !el) {
      continue;
    }
    if (WindowNameMatches(ElementName(el.get()), window_name)) {
      results.push_back(std::move(el));
    }
  }
  return results;
}

std::wstring ProcessImageName(DWORD pid) {
  const HANDLE process =
      OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if (process == nullptr) {
    return {};
  }
  wchar_t buffer[MAX_PATH];
  DWORD size = MAX_PATH;
  std::wstring name;
  if (QueryFullProcessImageNameW(process, 0, buffer, &size)) {
    name.assign(buffer, size);
    const auto slash = name.find_last_of(L"\\/");
    if (slash != std::wstring::npos) {
      name = name.substr(slash + 1);
    }
    name = NormalizeProcessName(name);
  }
  CloseHandle(process);
  return name;
}

}  // namespace

int WindowsAppControl::LaunchApp(
    const std::string& app_path,
    const std::optional<std::string>& arguments,
    bool activate,
    std::chrono::milliseconds activate_timeout) {
  if (app_path.empty()) {
    throw BadRequestError("launchApp requires \"appPath\"");
  }

  // ShellExecuteEx can load shell extensions that expect STA; httplib workers
  // are not COM-initialized, so initialize before the launch call.
  ComApartment apartment;

  const std::wstring wide_path = Utf8ToWide(app_path);
  const std::wstring wide_args =
      arguments.has_value() ? Utf8ToWide(*arguments) : L"";

  std::wcout << L"WindowsAppControl: launchApp(path=\"" << wide_path
             << L"\", activate=" << (activate ? L"true" : L"false") << L")\n";

  SHELLEXECUTEINFOW info{};
  info.cbSize = sizeof(info);
  // NOASYNC: finish before COM teardown on the worker thread.
  // FLAG_NO_UI: surface failures to the HTTP handler, not a modal dialog.
  info.fMask =
      SEE_MASK_NOCLOSEPROCESS | SEE_MASK_NOASYNC | SEE_MASK_FLAG_NO_UI;
  info.lpFile = wide_path.c_str();
  info.lpParameters = wide_args.empty() ? nullptr : wide_args.c_str();
  info.nShow = SW_SHOWNORMAL;

  if (!ShellExecuteExW(&info)) {
    throw std::runtime_error("Failed to start \"" + app_path + "\"");
  }

  DWORD pid = 0;
  if (info.hProcess != nullptr) {
    pid = GetProcessId(info.hProcess);
  }

  if (activate) {
    try {
      ActivateApp(std::nullopt, std::nullopt,
                  pid > 0 ? std::optional<int>{static_cast<int>(pid)}
                          : std::nullopt,
                  activate_timeout);
    } catch (const std::exception& ex) {
      std::cerr << "WindowsAppControl: launchApp activate best-effort failed: "
                << ex.what() << "\n";
    }
  }

  if (info.hProcess != nullptr) {
    CloseHandle(info.hProcess);
  }
  return static_cast<int>(pid);
}

void WindowsAppControl::ActivateApp(
    const std::optional<std::string>& process_name,
    const std::optional<std::string>& window_name,
    const std::optional<int>& process_id,
    std::chrono::milliseconds timeout) {
  const bool has_process = process_name.has_value() && !process_name->empty();
  const bool has_window = window_name.has_value() && !window_name->empty();
  const bool has_pid = process_id.has_value() && *process_id > 0;
  if (!has_process && !has_window && !has_pid) {
    throw BadRequestError(
        "Provide at least one of \"processName\", \"windowName\", or "
        "\"processId\"");
  }

  std::cout << "WindowsAppControl: activateApp\n";

  ComApartment apartment;
  auto automation = CreateAutomation();

  const auto wide_process =
      has_process ? std::optional<std::wstring>{Utf8ToWide(*process_name)}
                  : std::nullopt;
  const auto wide_window =
      has_window ? std::optional<std::wstring>{Utf8ToWide(*window_name)}
                 : std::nullopt;

  ComPtr<IUIAutomationElement> window;
  const bool found = RetryUntil(
      timeout, std::chrono::milliseconds(250), [&] {
        window = TryFindWindow(
            automation.get(), wide_process, wide_window, process_id);
        return static_cast<bool>(window);
      });

  if (!found || !window) {
    throw NotFoundError("No window found to activate within timeout");
  }

  UIA_HWND raw_hwnd = nullptr;
  ThrowIfFailed(window->get_CurrentNativeWindowHandle(&raw_hwnd),
                "get_CurrentNativeWindowHandle");
  if (raw_hwnd == nullptr) {
    throw std::runtime_error("Window has no native handle to activate");
  }
  const HWND hwnd = static_cast<HWND>(raw_hwnd);

  if (IsIconic(hwnd)) {
    ShowWindow(hwnd, SW_RESTORE);
  }

  window->SetFocus();
  if (!SetForegroundWindow(hwnd)) {
    // AttachThreadInput is a common fallback when SetForegroundWindow is
    // blocked by Windows foreground lock.
    const DWORD target_tid = GetWindowThreadProcessId(hwnd, nullptr);
    const DWORD current_tid = GetCurrentThreadId();
    if (target_tid != 0 && target_tid != current_tid) {
      AttachThreadInput(current_tid, target_tid, TRUE);
      BringWindowToTop(hwnd);
      SetForegroundWindow(hwnd);
      AttachThreadInput(current_tid, target_tid, FALSE);
    }
  }

  if (GetForegroundWindow() != hwnd) {
    throw std::runtime_error(
        "Failed to bring window to the foreground: \"" +
        WideToUtf8(ElementName(window.get())) + "\"");
  }

  std::wcout << L"WindowsAppControl: activated window \""
             << ElementName(window.get()) << L"\"\n";
}

ComPtr<IUIAutomationElement> WindowsAppControl::TryFindWindow(
    IUIAutomation* automation,
    const std::optional<std::wstring>& process_name,
    const std::optional<std::wstring>& window_name,
    const std::optional<int>& process_id) {
  auto windows =
      FindWindows(automation, process_name, window_name, process_id);
  if (windows.empty()) {
    return {};
  }
  return std::move(windows.front());
}

std::vector<ComPtr<IUIAutomationElement>> WindowsAppControl::FindWindows(
    IUIAutomation* automation,
    const std::optional<std::wstring>& process_name,
    const std::optional<std::wstring>& window_name,
    const std::optional<int>& process_id) {
  std::vector<DWORD> pids;
  if (process_id.has_value() && *process_id > 0) {
    if (!ProcessExists(static_cast<DWORD>(*process_id))) {
      return {};
    }
    // AND with processName when both are supplied (no fallthrough).
    if (process_name.has_value() && !process_name->empty()) {
      const auto actual = ProcessImageName(static_cast<DWORD>(*process_id));
      if (!EqualsIgnoreCase(actual, NormalizeProcessName(*process_name))) {
        return {};
      }
    }
    pids.push_back(static_cast<DWORD>(*process_id));
  } else if (process_name.has_value() && !process_name->empty()) {
    pids = PidsByName(NormalizeProcessName(*process_name));
    if (pids.empty()) {
      return {};
    }
  } else if (window_name.has_value() && !window_name->empty()) {
    return FindAllByTitle(automation, *window_name);
  } else {
    return {};
  }

  std::vector<ComPtr<IUIAutomationElement>> results;
  for (const DWORD pid : pids) {
    auto for_pid =
        FindAllForProcess(automation, static_cast<int>(pid), window_name);
    for (auto& window : for_pid) {
      results.push_back(std::move(window));
    }
  }
  return results;
}

}  // namespace patrol
