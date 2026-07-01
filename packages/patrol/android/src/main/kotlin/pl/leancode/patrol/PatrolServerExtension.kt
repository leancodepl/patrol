package pl.leancode.patrol

import org.http4k.routing.RoutingHttpHandler
import java.util.ServiceLoader

/**
 * Generic extension point for the Patrol automation server.
 *
 * Optional Patrol packages (for example `patrol_axe`) implement this interface
 * to mount their own HTTP routes onto the same server that powers
 * `$.platform.mobile.*` (port 8081). Core Patrol never references a specific
 * extension: implementations are discovered at runtime via [ServiceLoader],
 * so adding a new package requires NO change to core.
 *
 * To register an implementation, an extension package ships a file:
 *
 *   src/main/resources/META-INF/services/pl.leancode.patrol.PatrolServerExtension
 *
 * containing the fully-qualified name of its implementation class.
 */
interface PatrolServerExtension {
    /** Human-readable name, used for logging only. */
    val name: String

    /**
     * Routes to mount on the Patrol automation server.
     *
     * Endpoint names must not collide with core Patrol endpoints or with other
     * extensions. Prefixing them (e.g. "axeScan", "axeInitSession") is
     * recommended.
     */
    fun routes(): RoutingHttpHandler
}

/** Discovers [PatrolServerExtension]s available on the instrumentation classpath. */
object PatrolServerExtensions {
    fun discover(): List<PatrolServerExtension> = try {
        ServiceLoader.load(PatrolServerExtension::class.java).toList()
    } catch (e: Throwable) {
        Logger.i("Failed to load Patrol server extensions: ${e.message}")
        emptyList()
    }
}
