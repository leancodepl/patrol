package pl.leancode.patrol

import android.content.Context
import android.content.res.Resources
import android.os.Build
import android.os.LocaleList

object Localization {

    /**
     * Gets the current device language (system language, not app locale)
     * This ensures we operate on the actual language used by the system UI
     */
    private fun getDeviceLanguage(context: Context): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            // Use LocaleList to get the actual system default language
            // This is more direct than using configuration.locales
            LocaleList.getDefault().get(0).language
        } else {
            @Suppress("DEPRECATION")
            Resources.getSystem().configuration.locale.language
        }
    }

    /**
     * Gets localized string based on device language
     * Supports English (en), German (de), French (fr), Polish (pl) and Japanese (ja) languages
     */
    fun getLocalizedString(context: Context, resourceId: Int): String {
        val language = getDeviceLanguage(context)
        Logger.d("Device language: $language")

        // Check if the detected language is supported
        val supportedLanguages = setOf("en", "de", "fr", "pl", "ja")
        if (language !in supportedLanguages) {
            throw UnsupportedOperationException(
                "Language '$language' is not supported. Supported languages: ${supportedLanguages.joinToString(", ")}"
            )
        }
        return context.resources.getString(resourceId)
    }
}
