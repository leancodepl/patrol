#include "dart_test_tree.h"

#include <stdexcept>

namespace patrol {
namespace {

void Walk(const DartGroupEntry& node,
          const std::string& parent_group_name,
          std::vector<std::pair<std::string, bool>>& results) {
  for (const auto& entry : node.entries) {
    if (entry.type == "test") {
      if (parent_group_name.empty()) {
        throw std::runtime_error(
            "Invariant violated: test '" + entry.name +
            "' has no named parent group");
      }
      results.emplace_back(parent_group_name + " " + entry.name, entry.skip);
    } else if (entry.type == "group") {
      const std::string next_parent = parent_group_name.empty()
                                          ? entry.name
                                          : parent_group_name + " " + entry.name;
      Walk(entry, next_parent, results);
    }
  }
}

}  // namespace

std::vector<std::pair<std::string, bool>> DartTestTree::Flatten(
    const DartGroupEntry& root) {
  std::vector<std::pair<std::string, bool>> results;
  Walk(root, "", results);
  return results;
}

}  // namespace patrol
