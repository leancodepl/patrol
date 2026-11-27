#include "automator_server.h"

#include <iostream>
#include <optional>
#include <stdexcept>
#include <string>

#include "httplib.h"
#include "json.hpp"

#include "native/windows_app_control.h"
#include "native/windows_input.h"
#include "native/windows_ui_automation.h"
#include "util.h"

namespace patrol {
namespace {

using json = nlohmann::json;

httplib::Response ErrorResponse(int status, const std::string& message) {
  httplib::Response res;
  res.status = status;
  res.set_content(json{{"error", message}}.dump(), "application/json");
  return res;
}

httplib::Response OkEmpty() {
  httplib::Response res;
  res.status = 200;
  res.set_content("{}", "application/json");
  return res;
}

httplib::Response OkJson(const json& body) {
  httplib::Response res;
  res.status = 200;
  res.set_content(body.dump(), "application/json");
  return res;
}

bool RejectBrowserOrBadContentType(const httplib::Request& req,
                                   httplib::Response& res) {
  if (req.has_header("Origin")) {
    res = ErrorResponse(400, "Browser Origin header is not allowed");
    return true;
  }
  const auto content_type = req.get_header_value("Content-Type");
  // Allow "application/json" and "application/json; charset=utf-8".
  if (content_type.size() < 16 ||
      content_type.compare(0, 16, "application/json") != 0 ||
      (content_type.size() > 16 && content_type[16] != ';')) {
    res = ErrorResponse(400, "Content-Type must be application/json");
    return true;
  }
  return false;
}

json ParseBody(const httplib::Request& req) {
  if (req.body.empty()) {
    return json::object();
  }
  try {
    return json::parse(req.body);
  } catch (const json::parse_error& ex) {
    throw BadRequestError(std::string("Invalid JSON: ") + ex.what());
  }
}

std::optional<std::wstring> OptionalWide(const json& obj, const char* key) {
  if (!obj.contains(key) || !obj.at(key).is_string()) {
    return std::nullopt;
  }
  const auto value = obj.at(key).get<std::string>();
  if (value.empty()) {
    return std::nullopt;
  }
  return Utf8ToWide(value);
}

std::optional<UiScope> ParseScope(const json& root) {
  if (!root.contains("within")) {
    return std::nullopt;
  }
  if (!root.at("within").is_object()) {
    throw BadRequestError("\"within\" must be an object");
  }
  const auto& within = root.at("within");
  UiScope scope;
  if (within.contains("processId") && within.at("processId").is_number_integer()) {
    const int pid = within.at("processId").get<int>();
    if (pid > 0) {
      scope.process_id = pid;
    }
  }
  scope.process_name = OptionalWide(within, "processName");
  scope.window_name = OptionalWide(within, "windowName");
  if (scope.empty()) {
    throw BadRequestError(
        "\"within\" requires at least one of \"processId\", \"processName\", "
        "or \"windowName\"");
  }
  return scope;
}

UiSelector ParseSelector(const json& root) {
  UiSelector selector;
  selector.name = OptionalWide(root, "name");
  selector.automation_id = OptionalWide(root, "automationId");
  selector.class_name = OptionalWide(root, "className");
  if (!selector.name && !selector.automation_id && !selector.class_name) {
    throw BadRequestError(
        "Provide at least one of \"name\", \"automationId\", or \"className\"");
  }
  if (root.contains("index")) {
    if (!root.at("index").is_number_integer()) {
      throw BadRequestError("\"index\" must be an integer");
    }
    selector.index = root.at("index").get<int>();
    if (selector.index < 0) {
      throw BadRequestError("\"index\" must be >= 0");
    }
  }
  selector.within = ParseScope(root);
  return selector;
}

std::optional<std::chrono::milliseconds> ParseTimeout(const json& root) {
  if (!root.contains("timeoutMillis")) {
    return std::nullopt;
  }
  if (!root.at("timeoutMillis").is_number_integer()) {
    throw BadRequestError("\"timeoutMillis\" must be an integer");
  }
  const int millis = root.at("timeoutMillis").get<int>();
  if (millis <= 0) {
    throw BadRequestError("\"timeoutMillis\" must be > 0");
  }
  return std::chrono::milliseconds(millis);
}

json ElementToJson(const UiElementInfo& info) {
  json out = json::object();
  if (info.name) {
    out["name"] = *info.name;
  }
  if (info.class_name) {
    out["className"] = *info.class_name;
  }
  if (info.automation_id) {
    out["automationId"] = *info.automation_id;
  }
  out["x"] = info.x;
  out["y"] = info.y;
  out["width"] = info.width;
  out["height"] = info.height;
  return out;
}

template <typename Fn>
httplib::Response Guarded(Fn&& fn) {
  try {
    return fn();
  } catch (const BadRequestError& ex) {
    return ErrorResponse(400, ex.what());
  } catch (const NotFoundError& ex) {
    return ErrorResponse(404, ex.what());
  } catch (const std::exception& ex) {
    std::cerr << "AutomatorServer: unhandled error: " << ex.what() << "\n";
    return ErrorResponse(500, ex.what());
  }
}

}  // namespace

AutomatorServer::AutomatorServer(int port) : port_(port) {}

AutomatorServer::~AutomatorServer() { Stop(); }

void AutomatorServer::ResetReadyGate() {
  std::lock_guard lock(ready_mutex_);
  ready_ = false;
}

bool AutomatorServer::WaitUntilReady(std::chrono::milliseconds timeout) {
  std::unique_lock lock(ready_mutex_);
  return ready_cv_.wait_for(lock, timeout, [&] { return ready_; });
}

void AutomatorServer::Start() {
  server_ = std::make_unique<httplib::Server>();
  // One worker: physical input / UIA must not interleave across requests.
  server_->new_task_queue = [] { return new httplib::ThreadPool(1); };
  // Default also sets SO_REUSEADDR, which Winsock rejects before EXCLUSIVEADDRUSE.
  server_->set_socket_options([](httplib::socket_t sock) {
    int opt = 1;
    setsockopt(sock, SOL_SOCKET, SO_EXCLUSIVEADDRUSE,
               reinterpret_cast<const char*>(&opt), sizeof(opt));
  });
  RegisterRoutes();

  // Bind first so startup failure is synchronous; then accept in a thread.
  if (!server_->bind_to_port("127.0.0.1", port_)) {
    throw std::runtime_error(
        "AutomatorServer failed to bind port " + std::to_string(port_));
  }

  server_thread_ = std::thread([this] {
    if (!server_->listen_after_bind()) {
      std::cerr << "AutomatorServer: listen_after_bind failed on port " << port_
                << "\n";
    }
  });

  for (int i = 0; i < 100 && !server_->is_running(); ++i) {
    Sleep(20);
  }
  if (!server_->is_running()) {
    server_->stop();
    if (server_thread_.joinable()) {
      server_thread_.join();
    }
    throw std::runtime_error(
        "AutomatorServer failed to listen on port " + std::to_string(port_));
  }
  std::cout << "AutomatorServer listening on http://127.0.0.1:" << port_
            << "\n";
}

void AutomatorServer::Stop() {
  if (server_) {
    server_->stop();
  }
  if (server_thread_.joinable()) {
    server_thread_.join();
  }
  server_.reset();
}

void AutomatorServer::RegisterRoutes() {
  auto& svr = *server_;

  svr.Post("/markPatrolAppServiceReady", [this](const httplib::Request& req,
                                                httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    std::cout << "AutomatorServer: markPatrolAppServiceReady\n";
    {
      std::lock_guard lock(ready_mutex_);
      ready_ = true;
    }
    ready_cv_.notify_all();
    res = OkEmpty();
  });

  svr.Post("/tapAt", [](const httplib::Request& req, httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    res = Guarded([&] {
      const auto body = ParseBody(req);
      if (!body.contains("x") || !body.contains("y") ||
          !body.at("x").is_number() || !body.at("y").is_number()) {
        throw BadRequestError("tapAt requires numeric \"x\" and \"y\"");
      }
      const double x = body.at("x").get<double>();
      const double y = body.at("y").get<double>();
      std::cout << "AutomatorServer: tapAt(" << x << ", " << y << ")\n";
      WindowsInput::TapAtNormalized(x, y);
      return OkEmpty();
    });
  });

  auto selector_action =
      [](const char* name, auto action) {
        return [name, action](const httplib::Request& req,
                              httplib::Response& res) {
          if (RejectBrowserOrBadContentType(req, res)) {
            return;
          }
          res = Guarded([&] {
            const auto body = ParseBody(req);
            const auto selector = ParseSelector(body);
            const auto timeout = ParseTimeout(body);
            std::cout << "AutomatorServer: " << name << "("
                      << selector.to_string() << ")\n";
            action(selector, timeout);
            return OkEmpty();
          });
        };
      };

  svr.Post("/tap",
           selector_action("tap", [](const UiSelector& s, auto t) {
             WindowsUiAutomation::Tap(s, t);
           }));
  svr.Post("/waitUntilVisible",
           selector_action("waitUntilVisible", [](const UiSelector& s, auto t) {
             WindowsUiAutomation::WaitUntilVisible(s, t);
           }));

  svr.Post("/isElementVisible", [](const httplib::Request& req,
                                   httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    res = Guarded([&] {
      const auto body = ParseBody(req);
      const auto selector = ParseSelector(body);
      const auto timeout = ParseTimeout(body);
      std::cout << "AutomatorServer: isElementVisible(" << selector.to_string()
                << ")\n";
      const bool visible =
          WindowsUiAutomation::IsElementVisible(selector, timeout);
      return OkJson(json{{"visible", visible}});
    });
  });

  svr.Post("/findElement", [](const httplib::Request& req,
                              httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    res = Guarded([&] {
      const auto body = ParseBody(req);
      const auto selector = ParseSelector(body);
      const auto timeout = ParseTimeout(body);
      std::cout << "AutomatorServer: findElement(" << selector.to_string()
                << ")\n";
      const auto info =
          WindowsUiAutomation::FindElementInfo(selector, timeout);
      if (!info.has_value()) {
        return OkJson(json{{"element", nullptr}});
      }
      return OkJson(json{{"element", ElementToJson(*info)}});
    });
  });

  svr.Post("/enterText", [](const httplib::Request& req,
                            httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    res = Guarded([&] {
      const auto body = ParseBody(req);
      if (!body.contains("text") || !body.at("text").is_string()) {
        throw BadRequestError("enterText requires \"text\"");
      }
      const auto text = body.at("text").get<std::string>();
      const auto selector = ParseSelector(body);
      const auto timeout = ParseTimeout(body);
      std::cout << "AutomatorServer: enterText(" << selector.to_string()
                << ")\n";
      WindowsUiAutomation::EnterText(selector, text, timeout);
      return OkEmpty();
    });
  });

  svr.Post("/pressKey", [](const httplib::Request& req,
                           httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    res = Guarded([&] {
      const auto body = ParseBody(req);
      if (!body.contains("keyCode") || !body.at("keyCode").is_number_integer()) {
        throw BadRequestError("pressKey requires \"keyCode\"");
      }
      const int key_code = body.at("keyCode").get<int>();
      const bool shift =
          body.contains("shift") && body.at("shift").is_boolean() &&
          body.at("shift").get<bool>();
      const bool ctrl =
          body.contains("ctrl") && body.at("ctrl").is_boolean() &&
          body.at("ctrl").get<bool>();
      const bool alt =
          body.contains("alt") && body.at("alt").is_boolean() &&
          body.at("alt").get<bool>();
      std::cout << "AutomatorServer: pressKey(" << key_code << ")\n";
      WindowsUiAutomation::PressKey(key_code, shift, ctrl, alt);
      return OkEmpty();
    });
  });

  svr.Post("/launchApp", [](const httplib::Request& req,
                            httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    res = Guarded([&] {
      const auto body = ParseBody(req);
      if (!body.contains("appPath") || !body.at("appPath").is_string() ||
          body.at("appPath").get<std::string>().empty()) {
        throw BadRequestError("launchApp requires \"appPath\"");
      }
      const auto app_path = body.at("appPath").get<std::string>();
      std::optional<std::string> arguments;
      if (body.contains("arguments") && body.at("arguments").is_string()) {
        arguments = body.at("arguments").get<std::string>();
      }
      bool activate = true;
      if (body.contains("activate") && body.at("activate").is_boolean()) {
        activate = body.at("activate").get<bool>();
      }
      std::cout << "AutomatorServer: launchApp(\"" << app_path << "\")\n";
      const int pid =
          WindowsAppControl::LaunchApp(app_path, arguments, activate);
      return OkJson(json{{"processId", pid}});
    });
  });

  svr.Post("/activateApp", [](const httplib::Request& req,
                              httplib::Response& res) {
    if (RejectBrowserOrBadContentType(req, res)) {
      return;
    }
    res = Guarded([&] {
      const auto body = ParseBody(req);
      std::optional<std::string> process_name;
      std::optional<std::string> window_name;
      std::optional<int> process_id;
      if (body.contains("processName") && body.at("processName").is_string()) {
        process_name = body.at("processName").get<std::string>();
      }
      if (body.contains("windowName") && body.at("windowName").is_string()) {
        window_name = body.at("windowName").get<std::string>();
      }
      if (body.contains("processId") &&
          body.at("processId").is_number_integer()) {
        process_id = body.at("processId").get<int>();
      }
      std::cout << "AutomatorServer: activateApp\n";
      WindowsAppControl::ActivateApp(process_name, window_name, process_id);
      return OkEmpty();
    });
  });
}

}  // namespace patrol
