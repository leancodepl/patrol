#if PATROL_ENABLED

  import Foundation
  import ObjectiveC.runtime

  /// Facade over Patrol's internal HTTP server.
  ///
  /// Extension packages (for example `patrol_axe`) receive this object and use
  /// it to add their own POST routes, without depending on Telegraph internals
  /// or on core Patrol's generated code. Handlers work with the raw request /
  /// response body as `Data` (typically JSON), mirroring the Android hook.
  @objc(PatrolRouteRegistrar)
  public class PatrolRouteRegistrar: NSObject {
    private let _post: (String, @escaping (Data) throws -> Data) -> Void

    init(post: @escaping (String, @escaping (Data) throws -> Data) -> Void) {
      self._post = post
    }

    /// Registers a POST handler at `path` on the Patrol automation server.
    public func post(_ path: String, handler: @escaping (Data) throws -> Data) {
      _post(path, handler)
    }
  }

  /// Generic extension point for the Patrol automation server on iOS.
  ///
  /// Implementations live in optional packages and are discovered at runtime via
  /// the Objective-C runtime, so core Patrol never references a specific
  /// extension. This is the iOS analogue of the Android `ServiceLoader` hook.
  @objc(PatrolServerExtension)
  public protocol PatrolServerExtension: NSObjectProtocol {
    @objc init()

    /// Human-readable name, used for logging only.
    @objc var name: String { get }

    /// Called once at server start so the extension can add its routes.
    @objc func register(on registrar: PatrolRouteRegistrar)
  }

  @objc(PatrolServerExtensions)
  public class PatrolServerExtensions: NSObject {
    /// Discovers all classes conforming to `PatrolServerExtension`.
    @objc public static func discover() -> [PatrolServerExtension] {
      guard let proto = objc_getProtocol("PatrolServerExtension") else { return [] }

      var count: UInt32 = 0
      guard let classList = objc_copyClassList(&count) else { return [] }
      defer { free(UnsafeMutableRawPointer(classList)) }

      var result: [PatrolServerExtension] = []
      for i in 0..<Int(count) {
        let cls: AnyClass = classList[i]
        guard class_conformsToProtocol(cls, proto) else { continue }
        guard let type = cls as? PatrolServerExtension.Type else { continue }
        result.append(type.init())
      }
      return result
    }
  }

#endif
