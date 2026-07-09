package pl.leancode.patrol.axe

import com.google.gson.Gson
import org.http4k.core.Method.POST
import org.http4k.core.Request
import org.http4k.core.Response
import org.http4k.core.Status.Companion.BAD_REQUEST
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.RoutingHttpHandler
import org.http4k.routing.bind
import org.http4k.routing.routes
import pl.leancode.patrol.PatrolServerExtension

data class AxeInitSessionRequest(val dequeApiKey: String, val dequeProjectId: String)
data class AxeScanRequest(val uploadToDashboard: Boolean, val tags: Set<String>, val scanName: String?)
data class AxeIgnoreRulesRequest(val rulesToIgnore: List<String>)
data class AxeIgnoreByViewIdResourceNameRequest(
    val viewIdResourceName: String,
    val ruleList: List<String>,
)

class AxeServerExtension : PatrolServerExtension {
    override val name: String = "patrol_axe"

    private val json = Gson()
    private val automator = AxeAutomator()

    private fun badRequest(message: String): Response = Response(BAD_REQUEST).body(message)

    private fun <T> parseRequest(req: Request, clazz: Class<T>): T? = try {
        json.fromJson(req.bodyString(), clazz)
    } catch (_: Throwable) {
        null
    }

    override fun routes(): RoutingHttpHandler = routes(
        "axeInitSession" bind POST to { req ->
            val body = parseRequest(req, AxeInitSessionRequest::class.java)
                ?: return@to badRequest("Invalid axeInitSession payload")
            if (body.dequeApiKey.isBlank() || body.dequeProjectId.isBlank()) {
                return@to badRequest("dequeApiKey and dequeProjectId are required")
            }
            automator.initSession(body.dequeApiKey, body.dequeProjectId)
            Response(OK)
        },
        "axeScan" bind POST to { req ->
            val body = parseRequest(req, AxeScanRequest::class.java)
                ?: return@to badRequest("Invalid axeScan payload")
            automator.scan(body.uploadToDashboard, body.tags, body.scanName)
            Response(OK)
        },
        "axeIgnoreRules" bind POST to { req ->
            val body = parseRequest(req, AxeIgnoreRulesRequest::class.java)
                ?: return@to badRequest("Invalid axeIgnoreRules payload")
            automator.ignoreRules(body.rulesToIgnore)
            Response(OK)
        },
        "axeIgnoreByViewIdResourceName" bind POST to { req ->
            val body = parseRequest(req, AxeIgnoreByViewIdResourceNameRequest::class.java)
                ?: return@to badRequest("Invalid axeIgnoreByViewIdResourceName payload")
            automator.ignoreByViewIdResourceName(body.viewIdResourceName, body.ruleList)
            Response(OK)
        },
        "axeIgnoreExperimental" bind POST to {
            automator.ignoreExperimental()
            Response(OK)
        },
    )
}
