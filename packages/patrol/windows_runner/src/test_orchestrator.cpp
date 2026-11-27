#include "test_orchestrator.h"

#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <vector>

#include <Windows.h>

#include "automator_server.h"
#include "dart_test_tree.h"
#include "native/windows_input.h"
#include "patrol_app_service_client.h"
#include "util.h"

namespace patrol {
namespace {

class TrackedProcess {
 public:
  explicit TrackedProcess(HANDLE process) : process_(process) {}
  ~TrackedProcess() { Kill(); }

  TrackedProcess(const TrackedProcess&) = delete;
  TrackedProcess& operator=(const TrackedProcess&) = delete;
  TrackedProcess(TrackedProcess&& other) noexcept : process_(other.process_) {
    other.process_ = nullptr;
  }
  TrackedProcess& operator=(TrackedProcess&& other) noexcept {
    if (this != &other) {
      Kill();
      process_ = other.process_;
      other.process_ = nullptr;
    }
    return *this;
  }

  HANDLE get() const { return process_; }

  void Kill() {
    if (process_ == nullptr || process_ == INVALID_HANDLE_VALUE) {
      return;
    }
    DWORD code = 0;
    if (GetExitCodeProcess(process_, &code) && code == STILL_ACTIVE) {
      TerminateProcess(process_, 1);
      WaitForSingleObject(process_, 5000);
    }
    CloseHandle(process_);
    process_ = nullptr;
  }

 private:
  HANDLE process_ = nullptr;
};

bool WaitForExit(HANDLE process, std::chrono::milliseconds timeout) {
  const DWORD result =
      WaitForSingleObject(process, static_cast<DWORD>(timeout.count()));
  return result == WAIT_OBJECT_0;
}

void StopApp(TrackedProcess& app, std::chrono::milliseconds exit_timeout) {
  const HANDLE process = app.get();
  if (process == nullptr) {
    return;
  }
  DWORD code = 0;
  if (!GetExitCodeProcess(process, &code) || code != STILL_ACTIVE) {
    return;
  }

  // Best-effort: find main window and close it.
  struct EnumData {
    DWORD pid;
    HWND hwnd;
  } data{GetProcessId(process), nullptr};

  EnumWindows(
      [](HWND hwnd, LPARAM lparam) -> BOOL {
        auto* d = reinterpret_cast<EnumData*>(lparam);
        DWORD window_pid = 0;
        GetWindowThreadProcessId(hwnd, &window_pid);
        if (window_pid == d->pid && IsWindowVisible(hwnd) &&
            GetWindow(hwnd, GW_OWNER) == nullptr) {
          d->hwnd = hwnd;
          return FALSE;
        }
        return TRUE;
      },
      reinterpret_cast<LPARAM>(&data));

  if (data.hwnd != nullptr) {
    PostMessageW(data.hwnd, WM_CLOSE, 0, 0);
    if (WaitForExit(process, exit_timeout)) {
      return;
    }
  }

  app.Kill();
}

TrackedProcess LaunchApp(AutomatorServer& server,
                         const std::string& app_path,
                         std::chrono::milliseconds ready_timeout) {
  server.ResetReadyGate();
  std::cout << "TestOrchestrator: launching " << app_path << "\n";

  const std::wstring wide_path = Utf8ToWide(app_path);
  std::wstring work_dir = wide_path;
  const auto slash = work_dir.find_last_of(L"\\/");
  if (slash != std::wstring::npos) {
    work_dir.resize(slash);
  } else {
    work_dir.clear();
  }

  STARTUPINFOW si{};
  si.cb = sizeof(si);
  PROCESS_INFORMATION pi{};

  std::wstring cmd = L"\"" + wide_path + L"\"";
  std::vector<wchar_t> cmd_mutable(cmd.begin(), cmd.end());
  cmd_mutable.push_back(L'\0');

  // Optional fixture path for demos.
  const char* fixture = std::getenv("PATROL_WINDOWS_FIXTURE_EXE");
  if (fixture != nullptr && fixture[0] != '\0') {
    SetEnvironmentVariableW(L"PATROL_WINDOWS_FIXTURE_EXE",
                            Utf8ToWide(fixture).c_str());
  }

  if (!CreateProcessW(
          wide_path.c_str(),
          cmd_mutable.data(),
          nullptr,
          nullptr,
          FALSE,
          0,
          nullptr,
          work_dir.empty() ? nullptr : work_dir.c_str(),
          &si,
          &pi)) {
    throw std::runtime_error("Failed to start app process");
  }
  CloseHandle(pi.hThread);

  TrackedProcess tracked(pi.hProcess);
  if (!server.WaitUntilReady(ready_timeout)) {
    StopApp(tracked, std::chrono::seconds(5));
    throw std::runtime_error(
        "Timed out waiting for markPatrolAppServiceReady");
  }

  std::cout << "TestOrchestrator: app service ready\n";
  return tracked;
}

int RunOne(PatrolAppServiceClient& client, const std::string& name) {
  std::cout << "TestOrchestrator: running " << name << "\n";
  const auto result = client.RunDartTest(name);
  if (result.passed) {
    std::cout << "TestOrchestrator: passed " << name << "\n";
    return 0;
  }
  std::cerr << "TestOrchestrator: failed " << name << "\n"
            << result.details << "\n";
  return 1;
}

}  // namespace

TestOrchestrator::TestOrchestrator(
    std::string app_path,
    int test_port,
    int app_port,
    std::chrono::milliseconds ready_timeout,
    std::chrono::milliseconds app_exit_timeout)
    : app_path_(std::move(app_path)),
      test_port_(test_port),
      app_port_(app_port),
      ready_timeout_(ready_timeout),
      app_exit_timeout_(app_exit_timeout) {}

int TestOrchestrator::Run() {
  WindowsInput::EnsureDpiAware();

  AutomatorServer server(test_port_);
  server.Start();

  try {
    std::vector<std::string> tests;
    int failed = 0;

    {
      auto first_app = LaunchApp(server, app_path_, ready_timeout_);
      PatrolAppServiceClient client(app_port_);
      const auto tree = DartTestTree::Flatten(client.ListDartTests());
      for (const auto& [name, skip] : tree) {
        if (!skip) {
          tests.push_back(name);
        }
      }

      if (tests.empty()) {
        std::cerr << "TestOrchestrator: no runnable Dart tests found\n";
        StopApp(first_app, app_exit_timeout_);
        return 4;
      }

      std::cout << "TestOrchestrator: discovered " << tests.size()
                << " test(s)\n";
      failed += RunOne(client, tests[0]);
      StopApp(first_app, app_exit_timeout_);
    }

    for (size_t i = 1; i < tests.size(); ++i) {
      auto app = LaunchApp(server, app_path_, ready_timeout_);
      PatrolAppServiceClient client(app_port_);
      failed += RunOne(client, tests[i]);
      StopApp(app, app_exit_timeout_);
    }

    if (failed > 0) {
      std::cerr << "TestOrchestrator: " << failed << "/" << tests.size()
                << " test(s) failed\n";
      return 1;
    }

    std::cout << "TestOrchestrator: all " << tests.size() << " test(s) passed\n";
    return 0;
  } catch (...) {
    server.Stop();
    throw;
  }
}

}  // namespace patrol
