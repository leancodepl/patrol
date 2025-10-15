import Foundation
import os

class Localization {

  /**
   * Gets the current device language
   */
  private static func getDeviceLanguage() -> String? {
    // Get the user's preferred language instead of system locale
    if let preferredLanguage = Locale.preferredLanguages.first {
      // Extract language code using proper locale parsing (e.g., "en-US" -> "en")
      return Locale(identifier: preferredLanguage).languageCode
    }
    return nil
  }

  /**
   * Gets localized string based on device language
   * Supports English (en), German (de), French (fr) and Polish (pl) languages
   */
  static func getLocalizedString(key: String) throws -> String {  // Mark as throws
    let language = getDeviceLanguage()
    let targetLanguage = language ?? "en"

    // Define supported languages
    let supportedLanguages = ["en", "de", "fr", "pl"]

    if let unwrappedLanguage = language {
      Logger.shared.i("Device language: \(unwrappedLanguage)")
    } else {
      Logger.shared.i("Device language not found, defaulting to English")
    }

    // Check if the target language is supported
    guard supportedLanguages.contains(targetLanguage) else {
      Logger.shared.e("Language '\(targetLanguage)' is not supported")
      throw LocalizationError.languageNotSupported(
        "Language '\(targetLanguage)' is not supported. Supported languages are: \(supportedLanguages.joined(separator: ", "))"
      )
    }

    // Get the bundle containing the Localizable.strings files
    let bundle = Bundle(for: Localization.self)

    // Try to load the localized strings file for the target language
    guard
      let path = bundle.path(
        forResource: "Localizable", ofType: "strings", inDirectory: "\(targetLanguage).lproj")
    else {
      Logger.shared.e("Localizable.strings file not found for language: \(targetLanguage)")
      throw LocalizationError.resourceNotFound(
        "Localizable.strings file not found for language: \(targetLanguage)")
    }

    return try getLocalizedStringForLanguage(
      key: key, language: targetLanguage, bundle: bundle, path: path)
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
  case languageNotSupported(String)

  var errorDescription: String? {
    switch self {
    case .resourceNotFound(let message):
      return "Resource Not Found: \(message)"
    case .parsingFailed(let message):
      return "Parsing Failed: \(message)"
    case .keyNotFound(let message):
      return "Key Not Found: \(message)"
    case .languageNotSupported(let message):
      return "Language Not Supported: \(message)"
    }
  }
}
