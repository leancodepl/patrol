///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

public enum GroupEntryType: String, Codable {
  case group = "group"
  case test = "test"
}

public enum RunDartTestResponseResult: String, Codable {
  case success = "success"
  case skipped = "skipped"
  case failure = "failure"
}

public enum KeyboardBehavior: String, Codable {
  case showAndDismiss = "showAndDismiss"
  case alternative = "alternative"
}

public enum HandlePermissionRequestCode: String, Codable {
  case whileUsing = "whileUsing"
  case onlyThisTime = "onlyThisTime"
  case denied = "denied"
}

public enum SetLocationAccuracyRequestLocationAccuracy: String, Codable {
  case coarse = "coarse"
  case fine = "fine"
}

public enum IOSElementType: String, Codable {
  case any = "any"
  case other = "other"
  case application = "application"
  case group = "group"
  case window = "window"
  case sheet = "sheet"
  case drawer = "drawer"
  case alert = "alert"
  case dialog = "dialog"
  case button = "button"
  case radioButton = "radioButton"
  case radioGroup = "radioGroup"
  case checkBox = "checkBox"
  case disclosureTriangle = "disclosureTriangle"
  case popUpButton = "popUpButton"
  case comboBox = "comboBox"
  case menuButton = "menuButton"
  case toolbarButton = "toolbarButton"
  case popover = "popover"
  case keyboard = "keyboard"
  case key = "key"
  case navigationBar = "navigationBar"
  case tabBar = "tabBar"
  case tabGroup = "tabGroup"
  case toolbar = "toolbar"
  case statusBar = "statusBar"
  case table = "table"
  case tableRow = "tableRow"
  case tableColumn = "tableColumn"
  case outline = "outline"
  case outlineRow = "outlineRow"
  case browser = "browser"
  case collectionView = "collectionView"
  case slider = "slider"
  case pageIndicator = "pageIndicator"
  case progressIndicator = "progressIndicator"
  case activityIndicator = "activityIndicator"
  case segmentedControl = "segmentedControl"
  case picker = "picker"
  case pickerWheel = "pickerWheel"
  case switch_ = "switch_"
  case toggle = "toggle"
  case link = "link"
  case image = "image"
  case icon = "icon"
  case searchField = "searchField"
  case scrollView = "scrollView"
  case scrollBar = "scrollBar"
  case staticText = "staticText"
  case textField = "textField"
  case secureTextField = "secureTextField"
  case datePicker = "datePicker"
  case textView = "textView"
  case menu = "menu"
  case menuItem = "menuItem"
  case menuBar = "menuBar"
  case menuBarItem = "menuBarItem"
  case map = "map"
  case webView = "webView"
  case incrementArrow = "incrementArrow"
  case decrementArrow = "decrementArrow"
  case timeline = "timeline"
  case ratingIndicator = "ratingIndicator"
  case valueIndicator = "valueIndicator"
  case splitGroup = "splitGroup"
  case splitter = "splitter"
  case relevanceIndicator = "relevanceIndicator"
  case colorWell = "colorWell"
  case helpTag = "helpTag"
  case matte = "matte"
  case dockItem = "dockItem"
  case ruler = "ruler"
  case rulerMarker = "rulerMarker"
  case grid = "grid"
  case levelIndicator = "levelIndicator"
  case cell = "cell"
  case layoutArea = "layoutArea"
  case layoutItem = "layoutItem"
  case handle = "handle"
  case stepper = "stepper"
  case tab = "tab"
  case touchBar = "touchBar"
  case statusItem = "statusItem"
}

public enum GoogleApp: String, Codable {
  case calculator = "com.google.android.calculator"
  case calendar = "com.google.android.calendar"
  case chrome = "com.android.chrome"
  case drive = "com.google.android.apps.docs"
  case gmail = "com.google.android.gm"
  case maps = "com.google.android.apps.maps"
  case photos = "com.google.android.apps.photos"
  case playStore = "com.android.vending"
  case settings = "com.android.settings"
  case youtube = "com.google.android.youtube"
}

public enum AppleApp: String, Codable {
  case appStore = "com.apple.AppStore"
  case appleStore = "com.apple.store.Jolly"
  case barcodeScanner = "com.apple.BarcodeScanner"
  case books = "com.apple.iBooks"
  case calculator = "com.apple.calculator"
  case calendar = "com.apple.mobilecal"
  case camera = "com.apple.camera"
  case clips = "com.apple.clips"
  case clock = "com.apple.mobiletimer"
  case compass = "com.apple.compass"
  case contacts = "com.apple.MobileAddressBook"
  case developer = "developer.apple.wwdc-Release"
  case faceTime = "com.apple.facetime"
  case files = "com.apple.DocumentsApp"
  case findMy = "com.apple.findmy"
  case fitness = "com.apple.Fitness"
  case freeform = "com.apple.freeform"
  case garageBand = "com.apple.mobilegarageband"
  case health = "com.apple.Health"
  case home = "com.apple.Home"
  case iCloudDrive = "com.apple.iCloudDriveApp"
  case imagePlayground = "com.apple.GenerativePlaygroundApp"
  case iMovie = "com.apple.iMovie"
  case invites = "com.apple.rsvp"
  case iTunesStore = "com.apple.MobileStore"
  case journal = "com.apple.journal"
  case keynote = "com.apple.Keynote"
  case magnifier = "com.apple.Magnifier"
  case mail = "com.apple.mobilemail"
  case maps = "com.apple.Maps"
  case measure = "com.apple.measure"
  case messages = "com.apple.MobileSMS"
  case music = "com.apple.Music"
  case news = "com.apple.news"
  case notes = "com.apple.mobilenotes"
  case numbers = "com.apple.Numbers"
  case pages = "com.apple.Pages"
  case passwords = "com.apple.Passwords"
  case phone = "com.apple.mobilephone"
  case photoBooth = "com.apple.Photo-Booth"
  case photos = "com.apple.mobileslideshow"
  case podcasts = "com.apple.podcasts"
  case reminders = "com.apple.reminders"
  case safari = "com.apple.mobilesafari"
  case settings = "com.apple.Preferences"
  case shortcuts = "com.apple.shortcuts"
  case stocks = "com.apple.stocks"
  case swiftPlaygrounds = "com.apple.Playgrounds"
  case tips = "com.apple.tips"
  case translate = "com.apple.Translate"
  case tv = "com.apple.tv"
  case voiceMemos = "com.apple.VoiceMemos"
  case wallet = "com.apple.Passbook"
  case watch = "com.apple.Bridge"
  case weather = "com.apple.weather"
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

public struct OpenPlatformAppRequest: Codable {
  public var androidAppId: String?
  public var iosAppId: String?
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
  public var text: String?
  public var textStartsWith: String?
  public var textContains: String?
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

public struct AndroidGetNativeViewsRequest: Codable {
  public var selector: AndroidSelector?
}

public struct IOSGetNativeViewsRequest: Codable {
  public var selector: IOSSelector?
  public var iosInstalledApps: [String]?
  public var appId: String
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
  public var accessibilityLabel: String?
  public var placeholderValue: String?
  public var value: String?
  public var bundleId: String?
}

public struct AndroidGetNativeViewsResponse: Codable {
  public var roots: [AndroidNativeView]
}

public struct IOSGetNativeViewsResponse: Codable {
  public var roots: [IOSNativeView]
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

public struct AndroidTapRequest: Codable {
  public var selector: AndroidSelector
  public var timeoutMillis: Int?
  public var delayBetweenTapsMillis: Int?
}

public struct IOSTapRequest: Codable {
  public var selector: IOSSelector
  public var appId: String
  public var timeoutMillis: Int?
}

public struct AndroidTapAtRequest: Codable {
  public var x: Double
  public var y: Double
}

public struct IOSTapAtRequest: Codable {
  public var x: Double
  public var y: Double
  public var appId: String
}

public struct AndroidEnterTextRequest: Codable {
  public var data: String
  public var index: Int?
  public var selector: AndroidSelector?
  public var keyboardBehavior: KeyboardBehavior
  public var timeoutMillis: Int?
  public var dx: Double?
  public var dy: Double?
}

public struct IOSEnterTextRequest: Codable {
  public var data: String
  public var appId: String
  public var index: Int?
  public var selector: IOSSelector?
  public var keyboardBehavior: KeyboardBehavior
  public var timeoutMillis: Int?
  public var dx: Double?
  public var dy: Double?
}

public struct AndroidSwipeRequest: Codable {
  public var startX: Double
  public var startY: Double
  public var endX: Double
  public var endY: Double
  public var steps: Int
}

public struct IOSSwipeRequest: Codable {
  public var appId: String
  public var startX: Double
  public var startY: Double
  public var endX: Double
  public var endY: Double
}

public struct AndroidWaitUntilVisibleRequest: Codable {
  public var selector: AndroidSelector
  public var timeoutMillis: Int?
}

public struct IOSWaitUntilVisibleRequest: Codable {
  public var selector: IOSSelector
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

public struct AndroidTapOnNotificationRequest: Codable {
  public var index: Int?
  public var selector: AndroidSelector?
  public var timeoutMillis: Int?
}

public struct IOSTapOnNotificationRequest: Codable {
  public var index: Int?
  public var selector: IOSSelector?
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

public struct SetMockLocationRequest: Codable {
  public var latitude: Double
  public var longitude: Double
  public var packageName: String
}

public struct IsVirtualDeviceResponse: Codable {
  public var isVirtualDevice: Bool
}

public struct GetOsVersionResponse: Codable {
  public var osVersion: Int
}

public struct AndroidTakeCameraPhotoRequest: Codable {
  public var shutterButtonSelector: AndroidSelector?
  public var doneButtonSelector: AndroidSelector?
  public var timeoutMillis: Int?
}

public struct IOSTakeCameraPhotoRequest: Codable {
  public var shutterButtonSelector: IOSSelector?
  public var doneButtonSelector: IOSSelector?
  public var timeoutMillis: Int?
  public var appId: String
}

public struct AndroidPickImageFromGalleryRequest: Codable {
  public var imageSelector: AndroidSelector?
  public var imageIndex: Int?
  public var timeoutMillis: Int?
}

public struct IOSPickImageFromGalleryRequest: Codable {
  public var imageSelector: IOSSelector?
  public var imageIndex: Int?
  public var timeoutMillis: Int?
  public var appId: String
}

public struct AndroidPickMultipleImagesFromGalleryRequest: Codable {
  public var imageSelector: AndroidSelector?
  public var imageIndexes: [Int]
  public var timeoutMillis: Int?
}

public struct IOSPickMultipleImagesFromGalleryRequest: Codable {
  public var imageSelector: IOSSelector?
  public var imageIndexes: [Int]
  public var timeoutMillis: Int?
  public var appId: String
}

