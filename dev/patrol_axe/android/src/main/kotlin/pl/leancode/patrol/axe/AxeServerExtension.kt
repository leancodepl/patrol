package pl.leancode.patrol.axe

import com.google.gson.Gson
import org.http4k.core.Method.POST
import org.http4k.core.Response
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

    override fun routes(): RoutingHttpHandler = routes(
        "axeInitSession" bind POST to { req ->
            val body = json.fromJson(req.bodyString(), AxeInitSessionRequest::class.java)
            automator.initSession(body.dequeApiKey, body.dequeProjectId)
            Response(OK)
        },
        "axeScan" bind POST to { req ->
            val body = json.fromJson(req.bodyString(), AxeScanRequest::class.java)
            automator.scan(body.uploadToDashboard, body.tags, body.scanName)
            Response(OK)
        },
        "axeIgnoreRules" bind POST to { req ->
            val body = json.fromJson(req.bodyString(), AxeIgnoreRulesRequest::class.java)
            automator.ignoreRules(body.rulesToIgnore)
            Response(OK)
        },
        "axeIgnoreByViewIdResourceName" bind POST to { req ->
            val body = json.fromJson(req.bodyString(), AxeIgnoreByViewIdResourceNameRequest::class.java)
            automator.ignoreByViewIdResourceName(body.viewIdResourceName, body.ruleList)
            Response(OK)
        },
        "axeIgnoreExperimental" bind POST to {
            automator.ignoreExperimental()
            Response(OK)
        },
    )
}
