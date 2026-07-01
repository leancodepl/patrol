package pl.leancode.patrol.axe

import pl.leancode.patrol.Logger

/**
 * Native axe automator.
 *
 * POC build uses a stub (no Deque SDK). Replace with real AxeDevTools calls when
 * integrating the commercial SDK.
 */
class AxeAutomator {
    fun ping(): String {
        Logger.i("patrol_axe: native axePing handler executed")
        return """{"native":true,"extension":"patrol_axe","platform":"android"}"""
    }

    fun initSession(dequeApiKey: String, dequeProjectId: String) {
        Logger.i("patrol_axe: native axeInitSession (stub) keyLen=${dequeApiKey.length}")
    }

    fun scan(uploadToDashboard: Boolean, tags: Set<String>, scanName: String?) {
        Logger.i(
            "patrol_axe: native axeScan (stub) upload=$uploadToDashboard tags=$tags name=$scanName",
        )
    }
}
