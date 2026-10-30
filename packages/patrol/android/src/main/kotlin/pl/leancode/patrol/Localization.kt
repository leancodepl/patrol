package pl.leancode.patrol

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import java.util.Locale

object Localization {

    // Value of R.string.patrol_localization_locale in the default (English) `values/` folder.
    private const val DEFAULT_LOCALE_MARKER = "en"

    /**
     * Gets the primary system locale (not the app locale, which can differ with
     * per-app language preferences). System UI is shown in this locale.
     */
    private fun getSystemLocale(): Locale {
        val configuration = Resources.getSystem().configuration
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            configuration.locales.get(0)
        } else {
            @Suppress("DEPRECATION")
            configuration.locale
        }
    }

    /**
     * Gets localized string based on the system locale.
     *
     * Android resource resolution picks the best matching `values-*` folder, including
     * region and parent locales (e.g. en-GB -> values-en-rGB, es-MX -> values-es-rUS).
     * Supported locales are the folders generated from packages/patrol/tool/native_localization.
     */
    // The locale is the system one, so its resources are always installed (no Play Core needed).
    @SuppressLint("AppBundleLocaleChanges")
    fun getLocalizedString(context: Context, resourceId: Int): String {
        val locale = getSystemLocale()
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(locale)
        val resources = context.createConfigurationContext(configuration).resources

        // Detect a fallback to the default resources, which would silently return
        // English labels on a non-English device.
        val resolvedLocale = resources.getString(R.string.patrol_localization_locale)
        Logger.d("System locale: ${locale.toLanguageTag()}, using strings for: $resolvedLocale")

        if (resolvedLocale == DEFAULT_LOCALE_MARKER && locale.language != "en") {
            throw UnsupportedOperationException(
                "Locale '${locale.toLanguageTag()}' is not supported for native OS interactions."
            )
        }
        return resources.getString(resourceId)
    }
}
