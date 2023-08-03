package pl.leancode.patrol.example

import android.os.Bundle
import io.qameta.allure.android.AllureAndroidLifecycle
import io.qameta.allure.android.listeners.ExternalStoragePermissionsListener
import io.qameta.allure.android.writer.TestStorageResultsWriter
import io.qameta.allure.kotlin.Allure
import io.qameta.allure.kotlin.junit4.AllureJunit4
import io.qameta.allure.kotlin.util.PropertiesUtils
import pl.leancode.patrol.PatrolJUnitRunner

class PatrolAllureJUnitRunner : PatrolJUnitRunner() {
    override fun onCreate(arguments: Bundle) {
        Allure.lifecycle = createAllureAndroidLifecycle()
        val listenerArg = listOfNotNull(
            arguments.getCharSequence("listener"),
            AllureJunit4::class.java.name,
            ExternalStoragePermissionsListener::class.java.name.takeIf { useTestStorage }
        ).joinToString(separator = ",")
        arguments.putCharSequence("listener", listenerArg)
        super.onCreate(arguments)
    }

    protected open fun createAllureAndroidLifecycle() : AllureAndroidLifecycle =
        createDefaultAllureAndroidLifecycle()

    private fun createDefaultAllureAndroidLifecycle() : AllureAndroidLifecycle {
        if (useTestStorage) {
            return AllureAndroidLifecycle(TestStorageResultsWriter())
        }

        return AllureAndroidLifecycle()
    }

    private val useTestStorage: Boolean
        get() = PropertiesUtils.loadAllureProperties()
            .getProperty("allure.results.useTestStorage", "true")
            .toBoolean()
}