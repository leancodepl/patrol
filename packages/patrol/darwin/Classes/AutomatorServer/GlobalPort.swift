import Foundation

var globalPort: Int32 = 0

@_cdecl("getGlobalPort")
public func getGlobalPort() -> Int32 {
  return globalPort
}
