import Foundation
import os

class Localization {

  /**
   * Gets the current device locale
   */
  private static func getDeviceLocale() -> String {
    return Locale.current.languageCode ?? "en"
  }

  /**
   * Gets localized string based on device locale
   * Supports English (en), German (de), French (fr) and Polish (pl) locales
   */
  static func getLocalizedString(key: String) -> String {
    let locale = getDeviceLocale()
    Logger.shared.i("Device locale: \(locale)")

    // Default to English if the language is not supported
    let supportedLanguages = ["en", "de", "fr", "pl"]
    let targetLanguage = supportedLanguages.contains(locale) ? locale : "en"

    // Get the bundle containing the Localizable.strings files
    let bundle = Bundle(for: Localization.self)

    do {
      // Try to load the localized strings file for the target language
      if let path = bundle.path(
        forResource: "Localizable", ofType: "strings", inDirectory: "\(targetLanguage).lproj")
      {
        return try getLocalizedStringForLanguage(
          key: key, language: targetLanguage, bundle: bundle, path: path)
      } else {
        Logger.shared.i(
          "Could not find Localizable.strings for \(targetLanguage), trying English strings as fallback"
        )
        // Fallback to English if target language specific file is not found
        if targetLanguage != "en" {
          return try getLocalizedStringForLanguage(key: key, language: "en", bundle: bundle)
        } else {
          // If even English is not found or this is already 'en', we return the key itself
          Logger.shared.e(
            "Localizable.strings file not found for language: \(targetLanguage) and no English fallback."
          )
          return key  // Fallback: return the key itself
        }
      }
    } catch let error as LocalizationError {
      Logger.shared.e(
        "Localization error for key '\(key)' in language '\(targetLanguage)': \(error.localizedDescription)"
      )
      return key  // Fallback: return the key itself on error
    } catch {
      Logger.shared.e(
        "An unexpected error occurred during localization for key '\(key)': \(error.localizedDescription)"
      )
      return key  // Fallback: return the key itself on unexpected error
    }
  }

  // This function remains 'throws' because it's a lower-level utility
  private static func getLocalizedStringForLanguage(
    key: String, language: String, bundle: Bundle, path: String? = nil
  ) throws -> String {
    let finalPath =
      path
      ?? bundle.path(
        forResource: "Localizable", ofType: "strings", inDirectory: "\(language).lproj")

    guard let filePath = finalPath else {
      throw LocalizationError.resourceNotFound(
        "Localizable.strings file not found for language: \(language)")
    }

    guard let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: String] else {
      Logger.shared.e("Could not parse Localizable.strings for \(language)")
      throw LocalizationError.parsingFailed(
        "Could not parse Localizable.strings for language: \(language)")
    }

    guard let localizedString = dictionary[key] else {
      throw LocalizationError.keyNotFound(
        "Key '\(key)' not found in Localizable.strings for language: \(language)")
    }

    Logger.shared.i("Loaded localized string for key '\(key)' in language: \(language)")
    return localizedString
  }
}

enum LocalizationError: LocalizedError {
  case resourceNotFound(String)
  case parsingFailed(String)
  case keyNotFound(String)

  var errorDescription: String? {
    switch self {
    case .resourceNotFound(let message):
      return "Resource Not Found: \(message)"
    case .parsingFailed(let message):
      return "Parsing Failed: \(message)"
    case .keyNotFound(let message):
      return "Key Not Found: \(message)"
    }
  }
}
