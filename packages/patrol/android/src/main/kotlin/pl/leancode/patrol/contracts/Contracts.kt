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

  data class DartGroupEntry (
    val name: String,
    val type: GroupEntryType,
    val entries: List<DartGroupEntry>
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

  class OpenQuickSettingsRequest (

  )

  data class Selector (
    val text: String? = null,
    val textStartsWith: String? = null,
    val textContains: String? = null,
    val className: String? = null,
    val contentDescription: String? = null,
    val contentDescriptionStartsWith: String? = null,
    val contentDescriptionContains: String? = null,
    val resourceId: String? = null,
    val instance: Long? = null,
    val enabled: Boolean? = null,
    val focused: Boolean? = null,
    val pkg: String? = null
  ){
    fun hasText(): Boolean {
      return text != null
    }
    fun hasTextStartsWith(): Boolean {
      return textStartsWith != null
    }
    fun hasTextContains(): Boolean {
      return textContains != null
    }
    fun hasClassName(): Boolean {
      return className != null
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
    fun hasResourceId(): Boolean {
      return resourceId != null
    }
    fun hasInstance(): Boolean {
      return instance != null
    }
    fun hasEnabled(): Boolean {
      return enabled != null
    }
    fun hasFocused(): Boolean {
      return focused != null
    }
    fun hasPkg(): Boolean {
      return pkg != null
    }
  }

  data class IOSSelector (
    val instance: Long? = null,
    val elementType: String? = null,
    val identifier: String? = null,
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
    fun hasInstance(): Boolean {
      return instance != null
    }
    fun hasElementType(): Boolean {
      return elementType != null
    }
    fun hasIdentifier(): Boolean {
      return identifier != null
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

  data class GetNativeViewsRequest (
    val selector: Selector,
    val iosSelector: IOSSelector,
    val appId: String
  )

  data class GetNativeUITreeRequest (
    val iosInstalledApps: List<String>? = null
  ){
    fun hasIosInstalledApps(): Boolean {
      return iosInstalledApps != null
    }
  }

  data class GetNativeUITreeRespone (
    val iOSroots: List<IOSNativeView>,
    val androidRoots: List<AndroidNativeView>
  )

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
    val elementType: String,
    val identifier: String,
    val label: String,
    val title: String,
    val hasFocus: Boolean,
    val isEnabled: Boolean,
    val isSelected: Boolean,
    val frame: Rectangle,
    val placeholderValue: String? = null
  ){
    fun hasPlaceholderValue(): Boolean {
      return placeholderValue != null
    }
  }

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

  data class GetNativeViewsResponse (
    val iosNativeViews: List<IOSNativeView>,
    val androidNativeViews: List<AndroidNativeView>
  )

  data class TapRequest (
    val selector: Selector,
    val iosSelector: IOSSelector,
    val appId: String,
    val timeoutMillis: Long? = null
  ){
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class TapAtRequest (
    val x: Double,
    val y: Double,
    val appId: String
  )

  data class EnterTextRequest (
    val data: String,
    val appId: String,
    val index: Long? = null,
    val selector: Selector? = null,
    val iosSelector: IOSSelector? = null,
    val keyboardBehavior: KeyboardBehavior,
    val timeoutMillis: Long? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasIosSelector(): Boolean {
      return iosSelector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class SwipeRequest (
    val appId: String,
    val startX: Double,
    val startY: Double,
    val endX: Double,
    val endY: Double,
    val steps: Long
  )

  data class WaitUntilVisibleRequest (
    val selector: Selector,
    val iosSelector: IOSSelector,
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

  data class TapOnNotificationRequest (
    val index: Long? = null,
    val selector: Selector? = null,
    val iosSelector: IOSSelector? = null,
    val timeoutMillis: Long? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasIosSelector(): Boolean {
      return iosSelector != null
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

}
