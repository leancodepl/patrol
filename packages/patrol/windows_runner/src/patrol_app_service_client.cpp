#include "patrol_app_service_client.h"

#include <stdexcept>

#include "httplib.h"
#include "json.hpp"

namespace patrol {
namespace {

using json = nlohmann::json;

DartGroupEntry ParseGroup(const json& node) {
  DartGroupEntry entry;
  if (node.contains("name") && node.at("name").is_string()) {
    entry.name = node.at("name").get<std::string>();
  }
  if (node.contains("type") && node.at("type").is_string()) {
    entry.type = node.at("type").get<std::string>();
  }
  if (node.contains("skip") && node.at("skip").is_boolean()) {
    entry.skip = node.at("skip").get<bool>();
  }
  if (node.contains("entries") && node.at("entries").is_array()) {
    for (const auto& child : node.at("entries")) {
      entry.entries.push_back(ParseGroup(child));
    }
  }
  return entry;
}

}  // namespace

PatrolAppServiceClient::PatrolAppServiceClient(int app_port)
    : app_port_(app_port) {}

DartGroupEntry PatrolAppServiceClient::ListDartTests() {
  httplib::Client client("127.0.0.1", app_port_);
  client.set_connection_timeout(10, 0);
  // Match Android's two-hour request timeout.
  client.set_read_timeout(7200, 0);
  client.set_write_timeout(30, 0);

  const auto res = client.Post(
      "/listDartTests", "{}", "application/json");
  if (!res) {
    throw std::runtime_error("listDartTests request failed");
  }
  if (res->status != 200) {
    throw std::runtime_error(
        "listDartTests failed with status " + std::to_string(res->status));
  }

  const auto body = json::parse(res->body);
  if (!body.contains("group")) {
    throw std::runtime_error("Empty listDartTests response");
  }
  return ParseGroup(body.at("group"));
}

RunDartTestResult PatrolAppServiceClient::RunDartTest(const std::string& name) {
  httplib::Client client("127.0.0.1", app_port_);
  client.set_connection_timeout(10, 0);
  client.set_read_timeout(7200, 0);
  client.set_write_timeout(30, 0);

  const json payload = {{"name", name}};
  const auto res =
      client.Post("/runDartTest", payload.dump(), "application/json");
  if (!res) {
    throw std::runtime_error("runDartTest request failed");
  }
  if (res->status != 200) {
    throw std::runtime_error(
        "runDartTest failed with status " + std::to_string(res->status));
  }

  const auto body = json::parse(res->body);
  RunDartTestResult result;
  const auto status =
      body.value("result", std::string{});
  result.passed =
      status == "success" || status == "Success";
  result.details = body.value("details", std::string{});
  return result;
}

}  // namespace patrol
