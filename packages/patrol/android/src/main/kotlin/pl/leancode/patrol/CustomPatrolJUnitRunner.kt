package pl.leancode.patrol

import android.os.Build
import android.os.Bundle
import androidx.annotation.OptIn
import androidx.test.annotation.ExperimentalTestApi
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.services.storage.TestStorage
import org.junit.runner.*
import org.junit.runner.notification.*
import java.io.FileNotFoundException

@OptIn(ExperimentalTestApi::class)
class CustomPatrolJUnitRunner : PatrolJUnitRunner() {
    private var testStorage: TestStorage? = null
    override fun onCreate(arguments: Bundle) {
        super.onCreate(arguments)
        testStorage = TestStorage()
        try {
            testStorage!!.openOutputFile("patrol_state/teardowns.txt")
        } catch (e: FileNotFoundException) {
            throw RuntimeException(e)
        }

        val listeners = listOf(
            arguments.getCharSequence("listener"),
            PatrolStoragePermissionListener::class.java.name,
        ).joinToString(separator = ",")

        arguments.putCharSequence("listener", listeners)
        super.onCreate(arguments)
    }
}

class PatrolStoragePermissionListener : RunListener() {
    @Throws(Exception::class)
    override fun testRunStarted(description: Description) {
        InstrumentationRegistry.getInstrumentation().uiAutomation.apply {
            val testServicesPackage = "androidx.test.services"
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                    executeShellCommand("appops set $testServicesPackage MANAGE_EXTERNAL_STORAGE allow")
                }

                Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP -> {
                    executeShellCommand("pm grant $testServicesPackage android.permission.READ_EXTERNAL_STORAGE")
                    executeShellCommand("pm grant $testServicesPackage android.permission.WRITE_EXTERNAL_STORAGE")
                }
            }
        }
    }
}
