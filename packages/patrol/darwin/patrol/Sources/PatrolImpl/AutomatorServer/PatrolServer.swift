import Foundation

#if canImport(Darwin)
  import Darwin
#endif

@objc public class PatrolServer: NSObject {
  private static let envPortKey = "PATROL_TEST_PORT"

  private static let defaultPort = 8081

  private static let maxPortBindAttempts = 50

  #if PATROL_ENABLED
    private let automator: Automator
    private let server: Server
  #endif

  @objc
  public var appReady = false

  /// Port the native automation server bound to after [start].
  @objc public private(set) var boundTestPort: Int = defaultPort

  /// Port the app under test should use for [PatrolAppService].
  @objc public private(set) var boundAppPort: Int = defaultPort + 1

  private var preferredPort: Int = {
    guard let portStr = ProcessInfo.processInfo.environment[envPortKey] else {
      Logger.shared.i("\(envPortKey) is null, falling back to default (\(defaultPort))")
      return defaultPort
    }

    guard let portInt = Int(portStr) else {
      Logger.shared.i(
        "\(envPortKey) with value \(portStr) is not valid, falling back to default (\(defaultPort))"
      )
      return defaultPort
    }

    return portInt
  }()

  @objc public override init() {
    Logger.shared.i("PatrolServer constructor called")

    #if PATROL_ENABLED
      Logger.shared.i("PATROL_ENABLED flag is defined")
      self.server = Server()
      #if os(iOS)
        self.automator = IOSAutomator()
      #elseif os(macOS)
        self.automator = MacOSAutomator()
      #endif
    #else
      Logger.shared.i("Fatal error: PATROL_ENABLED flag is not defined")
    #endif
  }

  @objc public func start() throws {
    #if PATROL_ENABLED
      Logger.shared.i("Starting server...")

      let provider = AutomatorServer(automator: automator) { appReady in
        Logger.shared.i("App reported that it is ready")
        self.appReady = appReady
      }

      provider.setupRoutes(server: server)

      // Mount optional extension routes on the same server.
      let registrar = PatrolRouteRegistrar { [server = self.server] path, handler in
        server.route(.POST, path) { request in
          do {
            let responseBody = try handler(request.body)
            return HTTPResponse(.ok, body: responseBody)
          } catch let err {
            return HTTPResponse(.badRequest, headers: [:], error: err)
          }
        }
      }
      for ext in PatrolServerExtensions.discover() {
        Logger.shared.i("Loaded Patrol server extension: \(ext.name)")
        ext.register(on: registrar)
      }

      var portToTry = preferredPort
      var lastError: Error?

      for attempt in 0..<Self.maxPortBindAttempts {
        let appPortToTry = portToTry + 1
        if !Self.isPortAvailable(appPortToTry) {
          Logger.shared.i(
            "App service port \(appPortToTry) unavailable (attempt \(attempt + 1)), trying next pair"
          )
          portToTry += 2
          continue
        }

        do {
          try server.start(port: portToTry)
          boundTestPort = portToTry
          boundAppPort = appPortToTry
          Logger.shared.i("Server started on http://0.0.0.0:\(boundTestPort)")
          Logger.shared.i("App service port: \(boundAppPort)")
          return
        } catch {
          lastError = error
          Logger.shared.i(
            "Failed to bind PatrolServer on port \(portToTry) (attempt \(attempt + 1)): \(error)"
          )
          portToTry += 2
        }
      }

      throw lastError ?? NSError(
        domain: "PatrolServer",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Failed to bind PatrolServer after \(Self.maxPortBindAttempts) attempts"]
      )
    #endif
  }

  private static func isPortAvailable(_ port: Int) -> Bool {
    let socketFD = socket(AF_INET, SOCK_STREAM, 0)
    if socketFD < 0 {
      return false
    }
    defer { close(socketFD) }

    var reuse: Int32 = 1
    setsockopt(
      socketFD,
      SOL_SOCKET,
      SO_REUSEADDR,
      &reuse,
      socklen_t(MemoryLayout<Int32>.size)
    )

    guard let uint16Port = UInt16(exactly: port) else {
      return false
    }

    var addr = sockaddr_in()
    addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = in_port_t(uint16Port).bigEndian
    addr.sin_addr.s_addr = in_addr_t(INADDR_ANY.bigEndian)

    let bindResult = withUnsafePointer(to: &addr) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        bind(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    return bindResult == 0
  }
}
