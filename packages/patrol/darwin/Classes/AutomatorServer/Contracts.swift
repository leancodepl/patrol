///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

public enum GroupEntryType: String, Codable {
  case group
  case test
}

public enum RunDartTestResponseResult: String, Codable {
  case success
  case skipped
  case failure
}

public enum KeyboardBehavior: String, Codable {
  case showAndDismiss
  case alternative
}

public enum HandlePermissionRequestCode: String, Codable {
  case whileUsing
  case onlyThisTime
  case denied
}

public enum SetLocationAccuracyRequestLocationAccuracy: String, Codable {
  case coarse
  case fine
}

public struct DartGroupEntry: Codable {
  public var name: String
  public var type: GroupEntryType
  public var entries: [DartGroupEntry]
}

public struct ListDartTestsResponse: Codable {
  public var group: DartGroupEntry
}

public struct RunDartTestRequest: Codable {
  public var name: String
}

public struct RunDartTestResponse: Codable {
  public var result: RunDartTestResponseResult
  public var details: String?
}

public struct ConfigureRequest: Codable {
  public var findTimeoutMillis: Int
}

public struct OpenAppRequest: Codable {
  public var appId: String
}

public struct OpenQuickSettingsRequest: Codable {

}

public struct Selector: Codable {
  public var text: String?
  public var textStartsWith: String?
  public var textContains: String?
  public var className: String?
  public var contentDescription: String?
  public var contentDescriptionStartsWith: String?
  public var contentDescriptionContains: String?
  public var resourceId: String?
  public var instance: Int?
  public var enabled: Bool?
  public var focused: Bool?
  public var pkg: String?
}

public struct GetNativeViewsRequest: Codable {
  public var selector: Selector
  public var appId: String
}

public struct GetNativeUITreeRequest: Codable {
  public var iosInstalledApps: [String]?
}

public struct GetNativeUITreeRespone: Codable {
  public var roots: [NativeView]
}

public struct NativeView: Codable {
  public var className: String?
  public var text: String?
  public var contentDescription: String?
  public var focused: Bool
  public var enabled: Bool
  public var childCount: Int?
  public var resourceName: String?
  public var applicationPackage: String?
  public var children: [NativeView]
}

public struct GetNativeViewsResponse: Codable {
  public var nativeViews: [NativeView]
}

public struct TapRequest: Codable {
  public var selector: Selector
  public var appId: String
  public var timeoutMillis: Int?
}

public struct TapAtRequest: Codable {
  public var x: Double
  public var y: Double
  public var appId: String
}

public struct EnterTextRequest: Codable {
  public var data: String
  public var appId: String
  public var index: Int?
  public var selector: Selector?
  public var keyboardBehavior: KeyboardBehavior
  public var timeoutMillis: Int?
}

public struct SwipeRequest: Codable {
  public var appId: String
  public var startX: Double
  public var startY: Double
  public var endX: Double
  public var endY: Double
  public var steps: Int
}

public struct WaitUntilVisibleRequest: Codable {
  public var selector: Selector
  public var appId: String
  public var timeoutMillis: Int?
}

public struct DarkModeRequest: Codable {
  public var appId: String
}

public struct Notification: Codable {
  public var appName: String?
  public var title: String
  public var content: String
  public var raw: String?
}

public struct GetNotificationsResponse: Codable {
  public var notifications: [Notification]
}

public struct GetNotificationsRequest: Codable {

}

public struct TapOnNotificationRequest: Codable {
  public var index: Int?
  public var selector: Selector?
  public var timeoutMillis: Int?
}

public struct PermissionDialogVisibleResponse: Codable {
  public var visible: Bool
}

public struct PermissionDialogVisibleRequest: Codable {
  public var timeoutMillis: Int
}

public struct HandlePermissionRequest: Codable {
  public var code: HandlePermissionRequestCode
}

public struct SetLocationAccuracyRequest: Codable {
  public var locationAccuracy: SetLocationAccuracyRequestLocationAccuracy
}

