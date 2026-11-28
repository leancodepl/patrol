#pragma once

#include <chrono>
#include <condition_variable>
#include <memory>
#include <mutex>
#include <thread>

namespace httplib {
class Server;
}

namespace patrol {

class AutomatorServer {
 public:
  explicit AutomatorServer(int port);
  ~AutomatorServer();

  AutomatorServer(const AutomatorServer&) = delete;
  AutomatorServer& operator=(const AutomatorServer&) = delete;

  void Start();
  void Stop();

  void ResetReadyGate();
  // Returns false on timeout.
  bool WaitUntilReady(std::chrono::milliseconds timeout);

 private:
  void RegisterRoutes();

  int port_;
  std::unique_ptr<httplib::Server> server_;
  std::thread server_thread_;

  std::mutex ready_mutex_;
  std::condition_variable ready_cv_;
  bool ready_ = false;
};

}  // namespace patrol
