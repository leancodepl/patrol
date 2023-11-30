#if PATROL_ENABLED

  import Foundation

  final class AutomatorServer: NativeAutomatorServer {
    private let automator: Automator

    private let onAppReady: (Bool) -> Void

    init(automator: Automator, onAppReady: @escaping (Bool) -> Void) {
      self.automator = automator
      self.onAppReady = onAppReady
    }

    func initialize() throws {}

    func configure(request: ConfigureRequest) throws {
      automator.configure(timeout: TimeInterval(request.findTimeoutMillis / 1000))
    }

    func openApp(request: OpenAppRequest) throws {
      return try runCatching {
        try automator.openApp(request.appId)
      }
    }

    private func runCatching<T>(_ block: () throws -> T) throws -> T {
      // TODO: Use an interceptor (like on Android)
      // See: https://github.com/grpc/grpc-swift/issues/1148
      do {
        return try block()
      } catch let err as PatrolError {
        Logger.shared.e(err.description)
        throw err
      } catch let err {
        throw PatrolError.unknown(err)
      }
    }

    func markPatrolAppServiceReady() throws {
      onAppReady(true)
    }
  }

#endif
