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

public enum IOSElementType: String, Codable {
  case any
  case other
  case application
  case group
  case window
  case sheet
  case drawer
  case alert
  case dialog
  case button
  case radioButton
  case radioGroup
  case checkBox
  case disclosureTriangle
  case popUpButton
  case comboBox
  case menuButton
  case toolbarButton
  case popover
  case keyboard
  case key
  case navigationBar
  case tabBar
  case tabGroup
  case toolbar
  case statusBar
  case table
  case tableRow
  case tableColumn
  case outline
  case outlineRow
  case browser
  case collectionView
  case slider
  case pageIndicator
  case progressIndicator
  case activityIndicator
  case segmentedControl
  case picker
  case pickerWheel
  case switch_
  case toggle
  case link
  case image
  case icon
  case searchField
  case scrollView
  case scrollBar
  case staticText
  case textField
  case secureTextField
  case datePicker
  case textView
  case menu
  case menuItem
  case menuBar
  case menuBarItem
  case map
  case webView
  case incrementArrow
  case decrementArrow
  case timeline
  case ratingIndicator
  case valueIndicator
  case splitGroup
  case splitter
  case relevanceIndicator
  case colorWell
  case helpTag
  case matte
  case dockItem
  case ruler
  case rulerMarker
  case grid
  case levelIndicator
  case cell
  case layoutArea
  case layoutItem
  case handle
  case stepper
  case tab
  case touchBar
  case statusItem
}

public struct DartGroupEntry: Codable {
  public var name: String
  public var type: GroupEntryType
  public var entries: [DartGroupEntry]
  public var skip: Bool
  public var tags: [String]
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

public struct OpenUrlRequest: Codable {
  public var url: String
}

public struct AndroidSelector: Codable {
  public var className: String?
  public var isCheckable: Bool?
  public var isChecked: Bool?
  public var isClickable: Bool?
  public var isEnabled: Bool?
  public var isFocusable: Bool?
  public var isFocused: Bool?
  public var isLongClickable: Bool?
  public var isScrollable: Bool?
  public var isSelected: Bool?
  public var applicationPackage: String?
  public var contentDescription: String?
  public var contentDescriptionStartsWith: String?
  public var contentDescriptionContains: String?
  public var text: String?
  public var textStartsWith: String?
  public var textContains: String?
  public var resourceName: String?
  public var instance: Int?
}

public struct IOSSelector: Codable {
  public var value: String?
  public var instance: Int?
  public var elementType: IOSElementType?
  public var identifier: String?
  public var label: String?
  public var labelStartsWith: String?
  public var labelContains: String?
  public var title: String?
  public var titleStartsWith: String?
  public var titleContains: String?
  public var hasFocus: Bool?
  public var isEnabled: Bool?
  public var isSelected: Bool?
  public var placeholderValue: String?
  public var placeholderValueStartsWith: String?
  public var placeholderValueContains: String?
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
  public var selector: Selector?
  public var androidSelector: AndroidSelector?
  public var iosSelector: IOSSelector?
  public var appId: String
}

public struct GetNativeUITreeRequest: Codable {
  public var iosInstalledApps: [String]?
  public var useNativeViewHierarchy: Bool
}

public struct GetNativeUITreeRespone: Codable {
  public var iOSroots: [IOSNativeView]
  public var androidRoots: [AndroidNativeView]
  public var roots: [NativeView]
}

public struct AndroidNativeView: Codable {
  public var resourceName: String?
  public var text: String?
  public var className: String?
  public var contentDescription: String?
  public var applicationPackage: String?
  public var childCount: Int
  public var isCheckable: Bool
  public var isChecked: Bool
  public var isClickable: Bool
  public var isEnabled: Bool
  public var isFocusable: Bool
  public var isFocused: Bool
  public var isLongClickable: Bool
  public var isScrollable: Bool
  public var isSelected: Bool
  public var visibleBounds: Rectangle
  public var visibleCenter: Point2D
  public var children: [AndroidNativeView]
}

public struct IOSNativeView: Codable {
  public var children: [IOSNativeView]
  public var elementType: IOSElementType
  public var identifier: String
  public var label: String
  public var title: String
  public var hasFocus: Bool
  public var isEnabled: Bool
  public var isSelected: Bool
  public var frame: Rectangle
  public var placeholderValue: String?
  public var value: String?
}

public struct Rectangle: Codable {
  public var minX: Double
  public var minY: Double
  public var maxX: Double
  public var maxY: Double
}

public struct Point2D: Codable {
  public var x: Double
  public var y: Double
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
  public var iosNativeViews: [IOSNativeView]
  public var androidNativeViews: [AndroidNativeView]
}

public struct TapRequest: Codable {
  public var selector: Selector?
  public var androidSelector: AndroidSelector?
  public var iosSelector: IOSSelector?
  public var appId: String
  public var timeoutMillis: Int?
  public var delayBetweenTapsMillis: Int?
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
  public var androidSelector: AndroidSelector?
  public var iosSelector: IOSSelector?
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
  public var selector: Selector?
  public var androidSelector: AndroidSelector?
  public var iosSelector: IOSSelector?
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
  public var androidSelector: AndroidSelector?
  public var iosSelector: IOSSelector?
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

