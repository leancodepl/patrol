///
//  Generated code. Do not modify.
//  source: schema.dart
//

enum RunDartTestResponseResult: String, Codable {
  case success
  case skipped
  case failure
}

enum HandlePermissionRequestCode: String, Codable {
  case whileUsing
  case onlyThisTime
  case denied
}

enum SetLocationAccuracyRequestLocationAccuracy: String, Codable {
  case coarse
  case fine
}

struct DartTestCase: Codable {
 var name: String
}

struct DartTestGroup: Codable {
 var name: String
 var tests: [DartTestCase]
 var groups: [DartTestGroup]
}

struct ListDartTestsResponse: Codable {
 var group: DartTestGroup
}

struct RunDartTestRequest: Codable {
 var name: String
}

struct RunDartTestResponse: Codable {
 var result: RunDartTestResponseResult
 var details: String?
}

struct ConfigureRequest: Codable {
 var findTimeoutMillis: Int
}

struct OpenAppRequest: Codable {
 var appId: String
}

struct OpenQuickSettingsRequest: Codable {

}

struct Selector: Codable {
 var text: String?
 var textStartsWith: String?
 var textContains: String?
 var className: String?
 var contentDescription: String?
 var contentDescriptionStartsWith: String?
 var contentDescriptionContains: String?
 var resourceId: String?
 var instance: Int?
 var enabled: Bool?
 var focused: Bool?
 var pkg: String?
}

struct GetNativeViewsRequest: Codable {
 var selector: Selector
 var appId: String
}

struct NativeView: Codable {
 var className: String?
 var text: String?
 var contentDescription: String?
 var focused: Bool
 var enabled: Bool
 var childCount: Int?
 var resourceName: String?
 var applicationPackage: String?
 var children: [NativeView]
}

struct GetNativeViewsResponse: Codable {
 var nativeViews: [NativeView]
}

struct TapRequest: Codable {
 var selector: Selector
 var appId: String
}

struct EnterTextRequest: Codable {
 var data: String
 var appId: String
 var index: Int?
 var selector: Selector?
 var showKeyboard: Bool
}

struct SwipeRequest: Codable {
 var startX: Double
 var startY: Double
 var endX: Double
 var endY: Double
 var steps: Int
}

struct WaitUntilVisibleRequest: Codable {
 var selector: Selector
 var appId: String
}

struct DarkModeRequest: Codable {
 var appId: String
}

struct Notification: Codable {
 var appName: String?
 var title: String
 var content: String
 var raw: String
}

struct GetNotificationsResponse: Codable {
 var notifications: [Notification]
}

struct GetNotificationsRequest: Codable {

}

struct TapOnNotificationRequest: Codable {
 var index: Int?
 var selector: Selector?
}

struct PermissionDialogVisibleResponse: Codable {
 var visible: Bool
}

struct PermissionDialogVisibleRequest: Codable {
 var timeoutMillis: Int
}

struct HandlePermissionRequest: Codable {
 var code: HandlePermissionRequestCode
}

struct SetLocationAccuracyRequest: Codable {
 var locationAccuracy: SetLocationAccuracyRequestLocationAccuracy
}

