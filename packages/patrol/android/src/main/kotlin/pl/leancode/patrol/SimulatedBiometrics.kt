package pl.leancode.patrol

import android.annotation.TargetApi
import android.app.KeyguardManager
import android.app.UiAutomation
import android.content.Context
import android.hardware.biometrics.BiometricManager
import android.os.Build
import android.os.Process
import android.os.SystemClock

/**
 * Simulates biometrics with the framework's BiometricTestSession, the way CTS does.
 *
 * A test session switches its sensors to a test HAL, so it works on emulators and on devices with
 * a real sensor. The test HAL doesn't issue a valid hardware auth token, so keys bound to
 * biometrics (a CryptoObject) don't unlock.
 *
 * BiometricManager.createTestSession() is a @TestApi guarded by TEST_BIOMETRIC, so it's called
 * with reflection under the shell's permission identity.
 */
@TargetApi(Build.VERSION_CODES.R)
class SimulatedBiometrics(
    private val context: Context,
    private val uiAutomation: () -> UiAutomation,
    private val executeShellCommand: (String) -> String
) {
    private var sessions: List<AutoCloseable> = emptyList()
    private var setPin = false

    private val userId: Int
        get() = Process.myUid() / PER_USER_RANGE

    fun enroll() {
        unenroll()

        // Biometrics need a secure lock screen.
        val keyguard = context.getSystemService(KeyguardManager::class.java)
        if (!keyguard.isDeviceSecure) {
            Logger.d("enrollBiometrics(): setting PIN $PIN")
            Logger.d(executeShellCommand("locksettings set-pin $PIN"))
            setPin = true
        }

        withShellPermissions {
            val manager = context.getSystemService(BiometricManager::class.java)
            val sensorIds = sensorIds(manager)
            if (sensorIds.isEmpty()) {
                throw PatrolException("enrollBiometrics(): this device has no biometric sensors")
            }

            sessions = sensorIds.map { sensorId ->
                Logger.d("enrollBiometrics(): enrolling on sensor $sensorId for user $userId")
                val session = manager.javaClass
                    .getMethod("createTestSession", Int::class.javaPrimitiveType)
                    .invoke(manager, sensorId) as AutoCloseable
                session.call("startEnroll", userId)
                session.call("finishEnroll", userId)
                session
            }

            waitUntilEnrolled(manager)
        }
    }

    fun unenroll() {
        if (sessions.isNotEmpty()) {
            withShellPermissions {
                // Closing a session removes its enrollments and gives the sensor back to the real HAL.
                sessions.asReversed().forEach { it.close() }
            }
            sessions = emptyList()
        }

        if (setPin) {
            Logger.d(executeShellCommand("locksettings clear --old $PIN"))
            setPin = false
        }
    }

    fun accept() = authenticate("acceptAuthentication")

    fun reject() = authenticate("rejectAuthentication")

    private fun authenticate(method: String) {
        if (sessions.isEmpty()) {
            throw PatrolException("Call enrollBiometrics() first")
        }

        withShellPermissions {
            // Only the sensor that the prompt waits on reacts.
            sessions.forEach { it.call(method, userId) }
        }
    }

    private fun sensorIds(manager: BiometricManager): List<Int> {
        val properties = manager.javaClass.getMethod("getSensorProperties").invoke(manager) as List<*>

        return properties.filterNotNull().map { it.javaClass.getMethod("getSensorId").invoke(it) as Int }
    }

    private fun waitUntilEnrolled(manager: BiometricManager) {
        val deadline = SystemClock.uptimeMillis() + ENROLL_TIMEOUT_MILLIS
        while (SystemClock.uptimeMillis() < deadline) {
            if (manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK) ==
                BiometricManager.BIOMETRIC_SUCCESS
            ) {
                return
            }
            SystemClock.sleep(100)
        }

        throw PatrolException("enrollBiometrics(): biometrics weren't enrolled in ${ENROLL_TIMEOUT_MILLIS}ms")
    }

    private fun <T> withShellPermissions(block: () -> T): T {
        val automation = uiAutomation()
        automation.adoptShellPermissionIdentity(TEST_BIOMETRIC, USE_BIOMETRIC)
        try {
            return block()
        } finally {
            automation.dropShellPermissionIdentity()
        }
    }

    private fun Any.call(method: String, userId: Int) {
        javaClass.getMethod(method, Int::class.javaPrimitiveType).invoke(this, userId)
    }

    private companion object {
        const val PIN = "1111"
        const val PER_USER_RANGE = 100_000
        const val ENROLL_TIMEOUT_MILLIS = 5_000L
        const val TEST_BIOMETRIC = "android.permission.TEST_BIOMETRIC"
        const val USE_BIOMETRIC = "android.permission.USE_BIOMETRIC"
    }
}
