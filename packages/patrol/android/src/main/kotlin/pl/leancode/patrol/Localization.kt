package pl.leancode.patrol

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import java.util.Locale

object Localization {

    // Language of the default `values/` folder, i.e. the value of R.string.patrol_localization_locale there.
    private const val DEFAULT_LOCALE = "en"

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
     * region and parent locales (e.g. pt-BR -> values-pt-rBR, pt-PT -> values-pt-rPT, de-AT -> values-de).
     * Supported locales are the `values-*` folders in res/.
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

        if (resolvedLocale == DEFAULT_LOCALE && locale.language != DEFAULT_LOCALE) {
            throw UnsupportedOperationException(
                "Locale '${locale.toLanguageTag()}' is not supported for native OS interactions."
            )
        }
        return resources.getString(resourceId)
    }
}
