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
import org.http4k.routing.routes

abstract class AndroidAutomatorServer {
    abstract fun initialize()
    abstract fun pressBack()
    abstract fun doublePressRecentApps()
    abstract fun getNativeViews(request: Contracts.AndroidGetNativeViewsRequest): Contracts.AndroidGetNativeViewsResponse
    abstract fun tap(request: Contracts.AndroidTapRequest)
    abstract fun doubleTap(request: Contracts.AndroidTapRequest)
    abstract fun tapAt(request: Contracts.AndroidTapAtRequest)
    abstract fun enterText(request: Contracts.AndroidEnterTextRequest)
    abstract fun waitUntilVisible(request: Contracts.AndroidWaitUntilVisibleRequest)
    abstract fun swipe(request: Contracts.AndroidSwipeRequest)
    abstract fun enableLocation()
    abstract fun disableLocation()
    abstract fun tapOnNotification(request: Contracts.AndroidTapOnNotificationRequest)
    abstract fun takeCameraPhoto(request: Contracts.AndroidTakeCameraPhotoRequest)
    abstract fun pickImageFromGallery(request: Contracts.AndroidPickImageFromGalleryRequest)
    abstract fun pickMultipleImagesFromGallery(request: Contracts.AndroidPickMultipleImagesFromGalleryRequest)

    val router = routes(
      "initialize" bind POST to {
        initialize()
        Response(OK)
      },
      "pressBack" bind POST to {
        pressBack()
        Response(OK)
      },
      "doublePressRecentApps" bind POST to {
        doublePressRecentApps()
        Response(OK)
      },
      "getNativeViews" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidGetNativeViewsRequest::class.java)
        val response = getNativeViews(body)
        Response(OK).body(json.toJson(response))
      },
      "tap" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidTapRequest::class.java)
        tap(body)
        Response(OK)
      },
      "doubleTap" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidTapRequest::class.java)
        doubleTap(body)
        Response(OK)
      },
      "tapAt" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidTapAtRequest::class.java)
        tapAt(body)
        Response(OK)
      },
      "enterText" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidEnterTextRequest::class.java)
        enterText(body)
        Response(OK)
      },
      "waitUntilVisible" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidWaitUntilVisibleRequest::class.java)
        waitUntilVisible(body)
        Response(OK)
      },
      "swipe" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidSwipeRequest::class.java)
        swipe(body)
        Response(OK)
      },
      "enableLocation" bind POST to {
        enableLocation()
        Response(OK)
      },
      "disableLocation" bind POST to {
        disableLocation()
        Response(OK)
      },
      "tapOnNotification" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidTapOnNotificationRequest::class.java)
        tapOnNotification(body)
        Response(OK)
      },
      "takeCameraPhoto" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidTakeCameraPhotoRequest::class.java)
        takeCameraPhoto(body)
        Response(OK)
      },
      "pickImageFromGallery" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidPickImageFromGalleryRequest::class.java)
        pickImageFromGallery(body)
        Response(OK)
      },
      "pickMultipleImagesFromGallery" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.AndroidPickMultipleImagesFromGalleryRequest::class.java)
        pickMultipleImagesFromGallery(body)
        Response(OK)
      }
    )

    private val json = Gson()
}

