package pl.leancode.patrol

import android.content.Context
import android.os.LocaleList

object Localization {

    /**
     * Gets the current device language (system language, not app locale)
     * This ensures we operate on the actual language used by the system UI
     */
    private fun getDeviceLanguage(context: Context): String {
        // Use LocaleList to get the actual system default language
        // This is more direct than using configuration.locales
        return LocaleList.getDefault().get(0).language
    }

    /**
     * Gets localized string based on device language
     * Supports English (en), German (de), French (fr), Polish (pl), Japanese (ja) and Korean (ko) languages
     */
    fun getLocalizedString(context: Context, resourceId: Int): String {
        val language = getDeviceLanguage(context)
        Logger.d("Device language: $language")

        // Check if the detected language is supported
        val supportedLanguages = setOf("en", "de", "fr", "pl", "ja", "ko")
        if (language !in supportedLanguages) {
            throw UnsupportedOperationException(
                "Language '$language' is not supported. Supported languages: ${supportedLanguages.joinToString(", ")}"
            )
        }
        return context.resources.getString(resourceId)
    }
}
