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

  class OpenQuickSettingsRequest (

  )

  data class OpenUrlRequest (
    val url: String
  )

  data class Selector (
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

  data class GetNativeViewsRequest (
    val selector: Selector,
    val appId: String
  )

  data class GetNativeUITreeRequest (
    val useNativeViewHierarchy: Boolean
  )

  data class GetNativeUITreeRespone (
    val roots: List<NativeView>
  )

  data class NativeView (
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
    val children: List<NativeView>
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
    val nativeViews: List<NativeView>
  )

  data class TapRequest (
    val selector: Selector,
    val appId: String,
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

  data class TakeCameraPhotoRequest (
    val shutterButtonSelector: Selector? = null,
    val doneButtonSelector: Selector? = null,
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

  data class PickImageFromGalleryRequest (
    val imageSelector: Selector? = null,
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

  data class PickMultipleImagesFromGalleryRequest (
    val imageSelector: Selector? = null,
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
