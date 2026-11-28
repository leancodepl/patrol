#pragma once

#include <string>
#include <vector>

namespace patrol {

struct DartGroupEntry {
  std::string name;
  std::string type;
  bool skip = false;
  std::vector<DartGroupEntry> entries;
};

struct RunDartTestResult {
  bool passed = false;
  std::string details;
};

class PatrolAppServiceClient {
 public:
  explicit PatrolAppServiceClient(int app_port);

  DartGroupEntry ListDartTests();
  RunDartTestResult RunDartTest(const std::string& name);

 private:
  int app_port_;
};

}  // namespace patrol
