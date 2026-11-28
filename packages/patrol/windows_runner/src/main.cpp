#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include "test_orchestrator.h"
#include "util.h"

namespace {

void PrintUsage() {
  std::cout <<
      R"(patrol_windows_runner — Patrol Windows native test host (experimental)

Usage:
  patrol_windows_runner --app <path-to-flutter-exe> [--test-port 8081] [--app-port 8082]
)";
}

std::string RequireValue(int& i,
                         int argc,
                         const std::vector<std::string>& args,
                         const char* name) {
  if (i + 1 >= argc) {
    throw std::runtime_error(std::string("Missing value for ") + name);
  }
  return args[++i];
}

}  // namespace

// wmain keeps Unicode paths intact on non-UTF-8 system code pages.
int wmain(int argc, wchar_t** argv) {
  std::vector<std::string> args;
  args.reserve(static_cast<size_t>(argc));
  for (int i = 0; i < argc; ++i) {
    args.push_back(patrol::WideToUtf8(argv[i] != nullptr ? argv[i] : L""));
  }

  if (argc <= 1) {
    PrintUsage();
    return 0;
  }

  std::string app_path;
  int test_port = 8081;
  int app_port = 8082;

  try {
    for (int i = 1; i < argc; ++i) {
      const std::string& arg = args[static_cast<size_t>(i)];
      if (arg == "--help" || arg == "-h") {
        PrintUsage();
        return 0;
      }
      if (arg == "--app") {
        app_path = RequireValue(i, argc, args, "--app");
      } else if (arg == "--test-port") {
        test_port = std::stoi(RequireValue(i, argc, args, "--test-port"));
      } else if (arg == "--app-port") {
        app_port = std::stoi(RequireValue(i, argc, args, "--app-port"));
      } else {
        std::cerr << "Unknown argument: " << arg << "\n";
        PrintUsage();
        return 64;
      }
    }
  } catch (const std::exception& ex) {
    std::cerr << ex.what() << "\n";
    PrintUsage();
    return 64;
  }

  if (app_path.empty() ||
      GetFileAttributesW(patrol::Utf8ToWide(app_path).c_str()) ==
          INVALID_FILE_ATTRIBUTES) {
    std::cerr << "--app must point to an existing executable, got: " << app_path
              << "\n";
    return 64;
  }

  try {
    patrol::TestOrchestrator orchestrator(app_path, test_port, app_port);
    return orchestrator.Run();
  } catch (const std::runtime_error& ex) {
    const std::string message = ex.what();
    if (message.find("Timed out waiting for markPatrolAppServiceReady") !=
        std::string::npos) {
      std::cerr << message << "\n";
      return 3;
    }
    std::cerr << "Fatal: " << message << "\n";
    return 1;
  } catch (const std::exception& ex) {
    std::cerr << "Fatal: " << ex.what() << "\n";
    return 1;
  }
}
