import Foundation

/// Reads a build-time test manifest (produced by `patrol build ios
/// --emit-test-manifest`) and flattens it into the same `[{name, skip}]` shape
/// that `ObjCPatrolAppServiceClient.listDartTests` returns at runtime.
///
/// The flattening reuses `DartGroupEntry.listTestsFlat`, so the produced
/// selectors are byte-identical to runtime discovery - including the
/// `maxTestLength` cropping baked into the manifest by `createDartTestGroup`.
@objc public class PatrolTestManifest: NSObject {
  /// Returns the flattened Dart tests from the manifest at [path], or nil when
  /// the file is missing or cannot be decoded (the caller then falls back to
  /// runtime discovery).
  @objc public static func flatTests(fromManifestAtPath path: String) -> [[String: Any]]? {
    guard let data = FileManager.default.contents(atPath: path) else {
      NSLog("PatrolTestManifest: no manifest file at \(path)")
      return nil
    }

    do {
      let response = try JSONDecoder().decode(ListDartTestsResponse.self, from: data)
      return response.group.listTestsFlat(parentGroupName: "").map {
        ["name": $0.name, "skip": $0.skip]
      }
    } catch {
      NSLog("PatrolTestManifest: failed to decode manifest at \(path): \(error)")
      return nil
    }
  }
}
