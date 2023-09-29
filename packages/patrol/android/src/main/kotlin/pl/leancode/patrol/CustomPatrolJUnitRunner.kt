package pl.leancode.patrol

import android.annotation.SuppressLint
import android.os.Build
import android.os.Bundle
import androidx.annotation.OptIn
import androidx.test.annotation.ExperimentalTestApi
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.services.storage.TestStorage
import org.junit.runner.Description
import org.junit.runner.notification.RunListener

@OptIn(ExperimentalTestApi::class)
class CustomPatrolJUnitRunner : PatrolJUnitRunner() {
    private var testStorage: TestStorage? = null

    override fun onCreate(arguments: Bundle) {

//        try {
//            val outputStream = testStorage!!.openOutputFile("patrol_state/teardowns.txt")
//        } catch (e: FileNotFoundException) {
//            throw RuntimeException(e)
//        }

        val listeners = listOfNotNull(
            arguments.getCharSequence("listener"),
            PatrolStoragePermissionListener::class.java.name,
        ).joinToString(separator = ",")

        arguments.putCharSequence("listener", listeners)
        super.onCreate(arguments)
    }

    override fun onStart() {
        super.onStart()

        testStorage = TestStorage()
    }
}

@SuppressLint("UnsafeOptInUsageError")
class PatrolStoragePermissionListener : RunListener() {

    val testStorage by lazy { TestStorage() }

    override fun testStarted(description: Description) {
        Logger.d("testStarted with description: $description")


        val os = testStorage.openOutputFile("patrol.txt", true)
        os.write("testStarted with description: $description\n".toByteArray())


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
