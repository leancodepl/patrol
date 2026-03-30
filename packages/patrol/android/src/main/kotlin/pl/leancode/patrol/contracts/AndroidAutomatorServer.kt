///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import com.google.gson.Gson
import org.http4k.core.Response
import org.http4k.core.Method.POST
import org.http4k.routing.bind
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.RoutingHttpHandler
import org.http4k.routing.routes

interface AndroidAutomatorServer {
    fun initialize()
    fun pressBack()
    fun doublePressRecentApps()
    fun openPlatformApp(request: Contracts.AndroidOpenPlatformAppRequest)
    fun getNativeViews(request: Contracts.AndroidGetNativeViewsRequest): Contracts.AndroidGetNativeViewsResponse
    fun tap(request: Contracts.AndroidTapRequest)
    fun doubleTap(request: Contracts.AndroidTapRequest)
    fun tapAt(request: Contracts.AndroidTapAtRequest)
    fun enterText(request: Contracts.AndroidEnterTextRequest)
    fun waitUntilVisible(request: Contracts.AndroidWaitUntilVisibleRequest)
    fun swipe(request: Contracts.AndroidSwipeRequest)
    fun enableLocation()
    fun disableLocation()
    fun tapOnNotification(request: Contracts.AndroidTapOnNotificationRequest)
    fun takeCameraPhoto(request: Contracts.AndroidTakeCameraPhotoRequest)
    fun pickImageFromGallery(request: Contracts.AndroidPickImageFromGalleryRequest)
    fun pickMultipleImagesFromGallery(request: Contracts.AndroidPickMultipleImagesFromGalleryRequest)
}

private val json = Gson()

fun getAndroidAutomatorRoutes(server: AndroidAutomatorServer): RoutingHttpHandler = routes(
    "initialize" bind POST to {
      server.initialize()
      Response(OK)
    },
    "pressBack" bind POST to {
      server.pressBack()
      Response(OK)
    },
    "doublePressRecentApps" bind POST to {
      server.doublePressRecentApps()
      Response(OK)
    },
    "openPlatformApp" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidOpenPlatformAppRequest::class.java)
      server.openPlatformApp(body)
      Response(OK)
    },
    "getNativeViews" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidGetNativeViewsRequest::class.java)
      val response = server.getNativeViews(body)
      Response(OK).body(json.toJson(response))
    },
    "tap" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidTapRequest::class.java)
      server.tap(body)
      Response(OK)
    },
    "doubleTap" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidTapRequest::class.java)
      server.doubleTap(body)
      Response(OK)
    },
    "tapAt" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidTapAtRequest::class.java)
      server.tapAt(body)
      Response(OK)
    },
    "enterText" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidEnterTextRequest::class.java)
      server.enterText(body)
      Response(OK)
    },
    "waitUntilVisible" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidWaitUntilVisibleRequest::class.java)
      server.waitUntilVisible(body)
      Response(OK)
    },
    "swipe" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidSwipeRequest::class.java)
      server.swipe(body)
      Response(OK)
    },
    "enableLocation" bind POST to {
      server.enableLocation()
      Response(OK)
    },
    "disableLocation" bind POST to {
      server.disableLocation()
      Response(OK)
    },
    "tapOnNotification" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidTapOnNotificationRequest::class.java)
      server.tapOnNotification(body)
      Response(OK)
    },
    "takeCameraPhoto" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidTakeCameraPhotoRequest::class.java)
      server.takeCameraPhoto(body)
      Response(OK)
    },
    "pickImageFromGallery" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidPickImageFromGalleryRequest::class.java)
      server.pickImageFromGallery(body)
      Response(OK)
    },
    "pickMultipleImagesFromGallery" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.AndroidPickMultipleImagesFromGalleryRequest::class.java)
      server.pickMultipleImagesFromGallery(body)
      Response(OK)
    }
)

