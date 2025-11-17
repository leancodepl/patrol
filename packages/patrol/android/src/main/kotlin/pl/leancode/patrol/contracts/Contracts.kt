///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

class Contracts {
  enum class GroupEntryType {
    group,
    test,
  }

  enum class RunDartTestResponseResult {
    success,
    skipped,
    failure,
  }

  enum class KeyboardBehavior {
    showAndDismiss,
    alternative,
  }

  enum class HandlePermissionRequestCode {
    whileUsing,
    onlyThisTime,
    denied,
  }

  enum class SetLocationAccuracyRequestLocationAccuracy {
    coarse,
    fine,
  }

  enum class IOSElementType {
    any,
    other,
    application,
    group,
    window,
    sheet,
    drawer,
    alert,
    dialog,
    button,
    radioButton,
    radioGroup,
    checkBox,
    disclosureTriangle,
    popUpButton,
    comboBox,
    menuButton,
    toolbarButton,
    popover,
    keyboard,
    key,
    navigationBar,
    tabBar,
    tabGroup,
    toolbar,
    statusBar,
    table,
    tableRow,
    tableColumn,
    outline,
    outlineRow,
    browser,
    collectionView,
    slider,
    pageIndicator,
    progressIndicator,
    activityIndicator,
    segmentedControl,
    picker,
    pickerWheel,
    switch_,
    toggle,
    link,
    image,
    icon,
    searchField,
    scrollView,
    scrollBar,
    staticText,
    textField,
    secureTextField,
    datePicker,
    textView,
    menu,
    menuItem,
    menuBar,
    menuBarItem,
    map,
    webView,
    incrementArrow,
    decrementArrow,
    timeline,
    ratingIndicator,
    valueIndicator,
    splitGroup,
    splitter,
    relevanceIndicator,
    colorWell,
    helpTag,
    matte,
    dockItem,
    ruler,
    rulerMarker,
    grid,
    levelIndicator,
    cell,
    layoutArea,
    layoutItem,
    handle,
    stepper,
    tab,
    touchBar,
    statusItem,
  }

  enum class GoogleApp {
    calculator,
    calendar,
    chrome,
    drive,
    gmail,
    maps,
    photos,
    playStore,
    settings,
    youtube,
  }

  enum class AppleApp {
    appStore,
    appleStore,
    barcodeScanner,
    books,
    calculator,
    calendar,
    camera,
    clips,
    clock,
    compass,
    contacts,
    developer,
    faceTime,
    files,
    findMy,
    fitness,
    freeform,
    garageBand,
    health,
    home,
    iCloudDrive,
    imagePlayground,
    iMovie,
    invites,
    iTunesStore,
    journal,
    keynote,
    magnifier,
    mail,
    maps,
    measure,
    messages,
    music,
    news,
    notes,
    numbers,
    pages,
    passwords,
    phone,
    photoBooth,
    photos,
    podcasts,
    reminders,
    safari,
    settings,
    shortcuts,
    stocks,
    swiftPlaygrounds,
    tips,
    translate,
    tv,
    voiceMemos,
    wallet,
    watch,
    weather,
  }

  data class DartGroupEntry (
    val name: String,
    val type: GroupEntryType,
    val entries: List<DartGroupEntry>,
    val skip: Boolean,
    val tags: List<String>
  )

  data class ListDartTestsResponse (
    val group: DartGroupEntry
  )

  data class RunDartTestRequest (
    val name: String
  )

  data class RunDartTestResponse (
    val result: RunDartTestResponseResult,
    val details: String? = null
  ){
    fun hasDetails(): Boolean {
      return details != null
    }
  }

  data class ConfigureRequest (
    val findTimeoutMillis: Long
  )

  data class OpenAppRequest (
    val appId: String
  )

  data class OpenPlatformAppRequest (
    val androidAppId: String? = null,
    val iosAppId: String? = null
  ){
    fun hasAndroidAppId(): Boolean {
      return androidAppId != null
    }
    fun hasIosAppId(): Boolean {
      return iosAppId != null
    }
  }

  class OpenQuickSettingsRequest (

  )

  data class OpenUrlRequest (
    val url: String
  )

  data class AndroidSelector (
    val className: String? = null,
    val isCheckable: Boolean? = null,
    val isChecked: Boolean? = null,
    val isClickable: Boolean? = null,
    val isEnabled: Boolean? = null,
    val isFocusable: Boolean? = null,
    val isFocused: Boolean? = null,
    val isLongClickable: Boolean? = null,
    val isScrollable: Boolean? = null,
    val isSelected: Boolean? = null,
    val applicationPackage: String? = null,
    val contentDescription: String? = null,
    val contentDescriptionStartsWith: String? = null,
    val contentDescriptionContains: String? = null,
    val text: String? = null,
    val textStartsWith: String? = null,
    val textContains: String? = null,
    val resourceName: String? = null,
    val instance: Long? = null
  ){
    fun hasClassName(): Boolean {
      return className != null
    }
    fun hasIsCheckable(): Boolean {
      return isCheckable != null
    }
    fun hasIsChecked(): Boolean {
      return isChecked != null
    }
    fun hasIsClickable(): Boolean {
      return isClickable != null
    }
    fun hasIsEnabled(): Boolean {
      return isEnabled != null
    }
    fun hasIsFocusable(): Boolean {
      return isFocusable != null
    }
    fun hasIsFocused(): Boolean {
      return isFocused != null
    }
    fun hasIsLongClickable(): Boolean {
      return isLongClickable != null
    }
    fun hasIsScrollable(): Boolean {
      return isScrollable != null
    }
    fun hasIsSelected(): Boolean {
      return isSelected != null
    }
    fun hasApplicationPackage(): Boolean {
      return applicationPackage != null
    }
    fun hasContentDescription(): Boolean {
      return contentDescription != null
    }
    fun hasContentDescriptionStartsWith(): Boolean {
      return contentDescriptionStartsWith != null
    }
    fun hasContentDescriptionContains(): Boolean {
      return contentDescriptionContains != null
    }
    fun hasText(): Boolean {
      return text != null
    }
    fun hasTextStartsWith(): Boolean {
      return textStartsWith != null
    }
    fun hasTextContains(): Boolean {
      return textContains != null
    }
    fun hasResourceName(): Boolean {
      return resourceName != null
    }
    fun hasInstance(): Boolean {
      return instance != null
    }
  }

  data class IOSSelector (
    val value: String? = null,
    val instance: Long? = null,
    val elementType: IOSElementType? = null,
    val identifier: String? = null,
    val text: String? = null,
    val textStartsWith: String? = null,
    val textContains: String? = null,
    val label: String? = null,
    val labelStartsWith: String? = null,
    val labelContains: String? = null,
    val title: String? = null,
    val titleStartsWith: String? = null,
    val titleContains: String? = null,
    val hasFocus: Boolean? = null,
    val isEnabled: Boolean? = null,
    val isSelected: Boolean? = null,
    val placeholderValue: String? = null,
    val placeholderValueStartsWith: String? = null,
    val placeholderValueContains: String? = null
  ){
    fun hasValue(): Boolean {
      return value != null
    }
    fun hasInstance(): Boolean {
      return instance != null
    }
    fun hasElementType(): Boolean {
      return elementType != null
    }
    fun hasIdentifier(): Boolean {
      return identifier != null
    }
    fun hasText(): Boolean {
      return text != null
    }
    fun hasTextStartsWith(): Boolean {
      return textStartsWith != null
    }
    fun hasTextContains(): Boolean {
      return textContains != null
    }
    fun hasLabel(): Boolean {
      return label != null
    }
    fun hasLabelStartsWith(): Boolean {
      return labelStartsWith != null
    }
    fun hasLabelContains(): Boolean {
      return labelContains != null
    }
    fun hasTitle(): Boolean {
      return title != null
    }
    fun hasTitleStartsWith(): Boolean {
      return titleStartsWith != null
    }
    fun hasTitleContains(): Boolean {
      return titleContains != null
    }
    fun hasHasFocus(): Boolean {
      return hasFocus != null
    }
    fun hasIsEnabled(): Boolean {
      return isEnabled != null
    }
    fun hasIsSelected(): Boolean {
      return isSelected != null
    }
    fun hasPlaceholderValue(): Boolean {
      return placeholderValue != null
    }
    fun hasPlaceholderValueStartsWith(): Boolean {
      return placeholderValueStartsWith != null
    }
    fun hasPlaceholderValueContains(): Boolean {
      return placeholderValueContains != null
    }
  }

  data class AndroidGetNativeViewsRequest (
    val selector: AndroidSelector? = null
  ){
    fun hasSelector(): Boolean {
      return selector != null
    }
  }

  data class IOSGetNativeViewsRequest (
    val selector: IOSSelector? = null,
    val iosInstalledApps: List<String>? = null,
    val appId: String
  ){
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasIosInstalledApps(): Boolean {
      return iosInstalledApps != null
    }
  }

  data class AndroidNativeView (
    val resourceName: String? = null,
    val text: String? = null,
    val className: String? = null,
    val contentDescription: String? = null,
    val applicationPackage: String? = null,
    val childCount: Long,
    val isCheckable: Boolean,
    val isChecked: Boolean,
    val isClickable: Boolean,
    val isEnabled: Boolean,
    val isFocusable: Boolean,
    val isFocused: Boolean,
    val isLongClickable: Boolean,
    val isScrollable: Boolean,
    val isSelected: Boolean,
    val visibleBounds: Rectangle,
    val visibleCenter: Point2D,
    val children: List<AndroidNativeView>
  ){
    fun hasResourceName(): Boolean {
      return resourceName != null
    }
    fun hasText(): Boolean {
      return text != null
    }
    fun hasClassName(): Boolean {
      return className != null
    }
    fun hasContentDescription(): Boolean {
      return contentDescription != null
    }
    fun hasApplicationPackage(): Boolean {
      return applicationPackage != null
    }
  }

  data class IOSNativeView (
    val children: List<IOSNativeView>,
    val elementType: IOSElementType,
    val identifier: String,
    val label: String,
    val title: String,
    val hasFocus: Boolean,
    val isEnabled: Boolean,
    val isSelected: Boolean,
    val frame: Rectangle,
    val accessibilityLabel: String? = null,
    val placeholderValue: String? = null,
    val value: String? = null,
    val bundleId: String? = null
  ){
    fun hasAccessibilityLabel(): Boolean {
      return accessibilityLabel != null
    }
    fun hasPlaceholderValue(): Boolean {
      return placeholderValue != null
    }
    fun hasValue(): Boolean {
      return value != null
    }
    fun hasBundleId(): Boolean {
      return bundleId != null
    }
  }

  data class AndroidGetNativeViewsResponse (
    val roots: List<AndroidNativeView>
  )

  data class IOSGetNativeViewsResponse (
    val roots: List<IOSNativeView>
  )

  data class Rectangle (
    val minX: Double,
    val minY: Double,
    val maxX: Double,
    val maxY: Double
  )

  data class Point2D (
    val x: Double,
    val y: Double
  )

  data class AndroidTapRequest (
    val selector: AndroidSelector,
    val timeoutMillis: Long? = null,
    val delayBetweenTapsMillis: Long? = null
  ){
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
    fun hasDelayBetweenTapsMillis(): Boolean {
      return delayBetweenTapsMillis != null
    }
  }

  data class IOSTapRequest (
    val selector: IOSSelector,
    val appId: String,
    val timeoutMillis: Long? = null
  ){
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class AndroidTapAtRequest (
    val x: Double,
    val y: Double
  )

  data class IOSTapAtRequest (
    val x: Double,
    val y: Double,
    val appId: String
  )

  data class AndroidEnterTextRequest (
    val data: String,
    val index: Long? = null,
    val selector: AndroidSelector? = null,
    val keyboardBehavior: KeyboardBehavior,
    val timeoutMillis: Long? = null,
    val dx: Double? = null,
    val dy: Double? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
    fun hasDx(): Boolean {
      return dx != null
    }
    fun hasDy(): Boolean {
      return dy != null
    }
  }

  data class IOSEnterTextRequest (
    val data: String,
    val appId: String,
    val index: Long? = null,
    val selector: IOSSelector? = null,
    val keyboardBehavior: KeyboardBehavior,
    val timeoutMillis: Long? = null,
    val dx: Double? = null,
    val dy: Double? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
    fun hasDx(): Boolean {
      return dx != null
    }
    fun hasDy(): Boolean {
      return dy != null
    }
  }

  data class AndroidSwipeRequest (
    val startX: Double,
    val startY: Double,
    val endX: Double,
    val endY: Double,
    val steps: Long
  )

  data class IOSSwipeRequest (
    val appId: String,
    val startX: Double,
    val startY: Double,
    val endX: Double,
    val endY: Double
  )

  data class AndroidWaitUntilVisibleRequest (
    val selector: AndroidSelector,
    val timeoutMillis: Long? = null
  ){
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class IOSTwaitUntilVisibleRequest (
    val selector: IOSSelector,
    val appId: String,
    val timeoutMillis: Long? = null
  ){
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class DarkModeRequest (
    val appId: String
  )

  data class Notification (
    val appName: String? = null,
    val title: String,
    val content: String,
    val raw: String? = null
  ){
    fun hasAppName(): Boolean {
      return appName != null
    }
    fun hasRaw(): Boolean {
      return raw != null
    }
  }

  data class GetNotificationsResponse (
    val notifications: List<Notification>
  )

  class GetNotificationsRequest (

  )

  data class AndroidTapOnNotificationRequest (
    val index: Long? = null,
    val selector: AndroidSelector? = null,
    val timeoutMillis: Long? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class IOSTapOnNotificationRequest (
    val index: Long? = null,
    val selector: IOSSelector? = null,
    val timeoutMillis: Long? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class PermissionDialogVisibleResponse (
    val visible: Boolean
  )

  data class PermissionDialogVisibleRequest (
    val timeoutMillis: Long
  )

  data class HandlePermissionRequest (
    val code: HandlePermissionRequestCode
  )

  data class SetLocationAccuracyRequest (
    val locationAccuracy: SetLocationAccuracyRequestLocationAccuracy
  )

  data class SetMockLocationRequest (
    val latitude: Double,
    val longitude: Double,
    val packageName: String
  )

  data class IsVirtualDeviceResponse (
    val isVirtualDevice: Boolean
  )

  data class GetOsVersionResponse (
    val osVersion: Long
  )

  data class AndroidTakeCameraPhotoRequest (
    val shutterButtonSelector: AndroidSelector? = null,
    val doneButtonSelector: AndroidSelector? = null,
    val timeoutMillis: Long? = null
  ){
    fun hasShutterButtonSelector(): Boolean {
      return shutterButtonSelector != null
    }
    fun hasDoneButtonSelector(): Boolean {
      return doneButtonSelector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class IOSTakeCameraPhotoRequest (
    val shutterButtonSelector: IOSSelector? = null,
    val doneButtonSelector: IOSSelector? = null,
    val timeoutMillis: Long? = null,
    val appId: String
  ){
    fun hasShutterButtonSelector(): Boolean {
      return shutterButtonSelector != null
    }
    fun hasDoneButtonSelector(): Boolean {
      return doneButtonSelector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class AndroidPickImageFromGalleryRequest (
    val imageSelector: AndroidSelector? = null,
    val imageIndex: Long? = null,
    val timeoutMillis: Long? = null
  ){
    fun hasImageSelector(): Boolean {
      return imageSelector != null
    }
    fun hasImageIndex(): Boolean {
      return imageIndex != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class IOSPickImageFromGalleryRequest (
    val imageSelector: IOSSelector? = null,
    val imageIndex: Long? = null,
    val timeoutMillis: Long? = null,
    val appId: String
  ){
    fun hasImageSelector(): Boolean {
      return imageSelector != null
    }
    fun hasImageIndex(): Boolean {
      return imageIndex != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class AndroidPickMultipleImagesFromGalleryRequest (
    val imageSelector: AndroidSelector? = null,
    val imageIndexes: List<Long>,
    val timeoutMillis: Long? = null
  ){
    fun hasImageSelector(): Boolean {
      return imageSelector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class IOSPickMultipleImagesFromGalleryRequest (
    val imageSelector: IOSSelector? = null,
    val imageIndexes: List<Long>,
    val timeoutMillis: Long? = null,
    val appId: String
  ){
    fun hasImageSelector(): Boolean {
      return imageSelector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

}
