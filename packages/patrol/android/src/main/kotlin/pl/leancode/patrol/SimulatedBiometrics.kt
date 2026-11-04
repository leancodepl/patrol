package pl.leancode.patrol

import android.annotation.TargetApi
import android.app.KeyguardManager
import android.app.UiAutomation
import android.content.Context
import android.hardware.biometrics.BiometricManager
import android.hardware.biometrics.SensorProperties
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
@TargetApi(Build.VERSION_CODES.S)
class SimulatedBiometrics(
    private val context: Context,
    private val uiAutomation: () -> UiAutomation,
    private val executeShellCommand: (String) -> String
) {
    private var session: AutoCloseable? = null
    private var setPin = false

    private val userId: Int
        get() = Process.myUid() / PER_USER_RANGE

    fun enroll() {
        // Keeps the PIN, so a second enroll doesn't make the device insecure for a moment.
        closeSession()

        try {
            // Biometrics need a secure lock screen. A marker in settings remembers a PIN that a
            // previous instrumentation process set and didn't clear, for example after a crash.
            val keyguard = context.getSystemService(KeyguardManager::class.java)
            if (executeShellCommand("settings get global $PIN_MARKER").trim() == "1") {
                setPin = true
            } else if (!keyguard.isDeviceSecure) {
                Logger.d("enrollBiometrics(): setting PIN $PIN")
                executeShellCommand("settings put global $PIN_MARKER 1")
                setPin = true
                Logger.d(executeShellCommand("locksettings set-pin $PIN"))
            }

            withShellPermissions {
                val manager = context.getSystemService(BiometricManager::class.java)
                // One sensor is enough, and a single session keeps a reject at one failed
                // attempt, even when a prompt waits on several sensors.
                val sensorId = strongestSensorId(manager)
                    ?: throw PatrolException("enrollBiometrics(): this device has no biometric sensors")

                Logger.d("enrollBiometrics(): enrolling on sensor $sensorId for user $userId")
                val newSession = manager.javaClass
                    .getMethod("createTestSession", Int::class.javaPrimitiveType)
                    .invoke(manager, sensorId) as AutoCloseable
                session = newSession
                newSession.call("startEnroll", userId)
                newSession.call("finishEnroll", userId)

                waitUntilEnrolled(manager)
            }
        } catch (e: Exception) {
            // Don't leave a test HAL or a PIN behind on a half-done enrollment.
            runCatching { unenroll() }.onFailure { Logger.e("enrollBiometrics(): cleanup failed", it) }
            throw e
        }
    }

    fun unenroll() {
        try {
            closeSession()
        } finally {
            if (setPin) {
                setPin = false
                Logger.d(executeShellCommand("locksettings clear --old $PIN"))
                executeShellCommand("settings delete global $PIN_MARKER")
            }
        }
    }

    fun accept() = authenticate("acceptAuthentication")

    fun reject() = authenticate("rejectAuthentication")

    private fun authenticate(method: String) {
        val current = session ?: throw PatrolException("Call enrollBiometrics() first")

        withShellPermissions { current.call(method, userId) }
    }

    /** Closing the session removes its enrollment and gives the sensor back to the real HAL. */
    private fun closeSession() {
        val current = session ?: return
        // Forget it first, so a failed close isn't retried forever.
        session = null
        withShellPermissions { current.close() }
    }

    private fun strongestSensorId(manager: BiometricManager): Int? {
        // getSensorProperties() is a @TestApi, but SensorProperties is public.
        val properties = manager.javaClass.getMethod("getSensorProperties").invoke(manager) as List<*>

        return properties.filterIsInstance<SensorProperties>().maxByOrNull { it.sensorStrength }?.sensorId
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
        const val PIN_MARKER = "patrol_biometrics_pin"
        const val PER_USER_RANGE = 100_000
        const val ENROLL_TIMEOUT_MILLIS = 5_000L
        const val TEST_BIOMETRIC = "android.permission.TEST_BIOMETRIC"
        const val USE_BIOMETRIC = "android.permission.USE_BIOMETRIC"
    }
}
