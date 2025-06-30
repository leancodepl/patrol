package pl.leancode.patrol

import android.content.Context
import android.os.Build

object Localization {

    /**
     * Gets the current device locale
     */
    private fun getDeviceLocale(context: Context): String {
        val locale = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.resources.configuration.locales[0]
        } else {
            @Suppress("DEPRECATION")
            context.resources.configuration.locale
        }

        return locale.language
    }

    /**
     * Gets localized string based on device locale
     * Supports English (en) and Polish (pl) locales
     */
    fun getLocalizedString(context: Context, resourceName: String): String {
        val locale = getDeviceLocale(context)
        Logger.d("Device locale: $locale")
        // Try to get the string from the appropriate resource file
        val resourceId = context.resources.getIdentifier(
            resourceName,
            "string",
            context.packageName
        )

        return if (resourceId != 0) {
            context.resources.getString(resourceId)
        } else {
            throw IllegalStateException("Resource not found: $resourceName for locale: $locale")
        }
    }
}
