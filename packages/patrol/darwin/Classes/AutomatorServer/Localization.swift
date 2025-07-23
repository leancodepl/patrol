import Foundation
import os

class Localization {

  /**
   * Gets the current device locale
   */
  private static func getDeviceLocale() -> String? {
    return Locale.current.languageCode
  }

  /**
   * Gets localized string based on device locale
   * Supports English (en), German (de), French (fr) and Polish (pl) locales
   */
  static func getLocalizedString(key: String) throws -> String {  // Mark as throws
    let locale = getDeviceLocale()
    if let unwrappedLocale = locale {
      Logger.shared.i("Device locale: \(unwrappedLocale)")
    } else {
      Logger.shared.i("Device locale not found, fallback to English")
    }
    let targetLanguage = locale ?? "en"

    // Get the bundle containing the Localizable.strings files
    let bundle = Bundle(for: Localization.self)

    // The do-catch block is now outside, so we directly throw from here
    // Try to load the localized strings file for the target language
    if let path = bundle.path(
      forResource: "Localizable", ofType: "strings", inDirectory: "\(targetLanguage).lproj")
    {
      return try getLocalizedStringForLanguage(
        key: key, language: targetLanguage, bundle: bundle, path: path)
    } else {
      // Fallback to English if target language specific file is not found
      if targetLanguage != "en" {
        Logger.shared.i(
          "Could not find Localizable.strings for \(targetLanguage), trying English strings as fallback"
        )
        return try getLocalizedStringForLanguage(key: key, language: "en", bundle: bundle)
      } else {
        // If even English is not found or this is already 'en', throw an error
        Logger.shared.e(
          "Localizable.strings file not found for language: \(targetLanguage) and no English fallback."
        )
        // Throwing the specific error when no fallback is possible
        throw LocalizationError.resourceNotFound(
          "No Localizable.strings file found for \(targetLanguage) and no English fallback.")
      }
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

    Logger.shared.d("Loaded localized string for key '\(key)' in language: \(language)")
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
