package pl.leancode.patrol

import androidx.test.uiautomator.UiObjectNotFoundException
import org.http4k.core.Filter
import org.http4k.core.Response
import org.http4k.core.Status.Companion.INTERNAL_SERVER_ERROR
import org.http4k.core.Status.Companion.NOT_FOUND
import org.http4k.core.Status.Companion.NOT_IMPLEMENTED

val printer =
    Filter { next ->
        { request ->
            val requestName = "${request.method} ${request.uri}"
            Logger.i("$requestName started")
            val startTime = System.currentTimeMillis()
            val response = next(request)
            val latency = System.currentTimeMillis() - startTime
            Logger.i("$requestName took $latency ms")
            response
        }
    }

val catcher =
    Filter { next ->
        { request ->
            try {
                next(request)
            } catch (err: UiObjectNotFoundException) {
                Logger.e("caught UiObjectNotFoundException", err)
                val msg = "selector ${err.message} found nothing"
                Response(NOT_FOUND).body(msg)
            } catch (err: NotImplementedError) {
                Response(NOT_IMPLEMENTED).body("method ${err.message}() is not implemented on Android")
            } catch (err: Exception) {
                Logger.e("caught Exception", err)
                Response(INTERNAL_SERVER_ERROR).body(err.stackTraceToString())
            }
        }
    }
