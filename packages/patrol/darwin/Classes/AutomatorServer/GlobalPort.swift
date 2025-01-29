import Foundation

var globalPort: Int32 = 0

#if !PATROL_ENABLED
@objc(IOSServerPortProvider123) public class IOSServerPortProvider : NSObject {
    @objc public static func getGlobalPort() -> Int32 {
        return globalPort
    }
}
#endif
