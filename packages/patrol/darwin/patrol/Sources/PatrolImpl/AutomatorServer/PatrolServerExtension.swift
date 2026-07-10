import Foundation

/// Registers POST handlers on the Patrol automation server.
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

/// Extension point for optional Patrol server route packages.
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

  /// Registers an extension class for [discover].
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

/// C entry point for extension registration from ObjC `+load`.
@_cdecl("PatrolRegisterServerExtensionClass")
public func PatrolRegisterServerExtensionClass(_ cls: AnyClass) {
  PatrolServerExtensions.registerExtensionClass(cls)
}
