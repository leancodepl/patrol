#if PATROL_ENABLED

  import Foundation

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
  /// Implementations live in optional packages and are registered explicitly via
  /// `PatrolServerExtensions.registerExtensionClass(_:)` (see extension package docs).
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
    private static let registeredExtensionClassNames = NSMutableArray()

    /// Registers an extension implementation class for later discovery.
    ///
    /// Extension packages should call this once at module load time (see
    /// `patrol_axe` for an example). We intentionally avoid scanning the full
    /// Objective-C class table (`objc_copyClassList`), which can trap in large
    /// UITest binaries.
    @objc(registerExtensionClass:)
    public static func registerExtensionClass(_ cls: AnyClass) {
      let className = NSStringFromClass(cls)
      guard !registeredExtensionClassNames.contains(className) else {
        Logger.shared.i("Patrol extension class already registered: \(className)")
        return
      }
      registeredExtensionClassNames.add(className)
      Logger.shared.i("Registered Patrol extension class: \(className)")
    }

    /// Instantiates extensions registered via [registerExtensionClass].
    @objc public static func discover() -> [PatrolServerExtension] {
      Logger.shared.i(
        "Discovering Patrol extensions from registry (\(registeredExtensionClassNames.count) class name(s))"
      )

      var result: [PatrolServerExtension] = []
      for entry in registeredExtensionClassNames {
        guard let className = entry as? String else {
          Logger.shared.i("Skipping registry entry (not a String class name)")
          continue
        }

        guard let cls = NSClassFromString(className) else {
          Logger.shared.i("Skipping extension class (NSClassFromString failed): \(className)")
          continue
        }

        guard let objectType = cls as? NSObject.Type else {
          Logger.shared.i("Skipping extension class (not NSObject.Type): \(className)")
          continue
        }

        let instance = objectType.init()
        guard let ext = instance as? PatrolServerExtension else {
          Logger.shared.i("Skipping extension class (instance cast failed): \(className)")
          continue
        }

        Logger.shared.i("Discovered Patrol extension: \(ext.name) (\(className))")
        result.append(ext)
      }

      Logger.shared.i("Patrol extension discovery complete, found \(result.count) extension(s)")
      return result
    }
  }

  /// Stable C entry point for extension packages (callable from ObjC `+load`).
  @_cdecl("PatrolRegisterServerExtensionClass")
  public func PatrolRegisterServerExtensionClass(_ cls: AnyClass) {
    PatrolServerExtensions.registerExtensionClass(cls)
  }

#endif
