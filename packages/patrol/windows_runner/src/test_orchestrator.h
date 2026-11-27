#pragma once

#include <chrono>
#include <string>

namespace patrol {

class TestOrchestrator {
 public:
  TestOrchestrator(std::string app_path,
                   int test_port,
                   int app_port,
                   std::chrono::milliseconds ready_timeout =
                       std::chrono::minutes(2),
                   std::chrono::milliseconds app_exit_timeout =
                       std::chrono::seconds(15));

  // Returns process exit code (0 = all passed).
  int Run();

 private:
  std::string app_path_;
  int test_port_;
  int app_port_;
  std::chrono::milliseconds ready_timeout_;
  std::chrono::milliseconds app_exit_timeout_;
};

}  // namespace patrol
