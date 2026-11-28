#pragma once

#include <string>
#include <utility>
#include <vector>

#include "patrol_app_service_client.h"

namespace patrol {

class DartTestTree {
 public:
  // Flattens like Android listTestsFlat: parent groups space-concatenated.
  static std::vector<std::pair<std::string, bool>> Flatten(
      const DartGroupEntry& root);
};

}  // namespace patrol
