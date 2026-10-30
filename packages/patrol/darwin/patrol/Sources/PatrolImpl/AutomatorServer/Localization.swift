import Foundation
import os

class Localization {

  /**
   * Finds the bundled localization that matches the device language, region-aware
   * (e.g. "es-MX" -> "es-419", "pt-BR" -> "pt-BR", "zh-Hant-TW" -> "zh-Hant", "en-GB" -> "en").
   *
   * Only the first preferred language is considered, because system UI is shown in it.
   */
  private static func resolveLocalization(in bundle: Bundle) throws -> String {
    guard let deviceLanguage = Locale.preferredLanguages.first else {
      Logger.shared.i("Device language not found, defaulting to English")
      return "en"
    }

    let available = bundle.localizations.filter {
      bundle.path(forResource: "Localizable", ofType: "strings", inDirectory: "\($0).lproj") != nil
    }

    // When nothing matches, Foundation falls back to the development localization (en),
    // which would silently return English labels on a non-English device.
    guard
      let localization = Bundle.preferredLocalizations(
        from: available, forPreferences: [deviceLanguage]
      ).first,
      Locale(identifier: localization).languageCode == Locale(identifier: deviceLanguage).languageCode
    else {
      Logger.shared.e("Language '\(deviceLanguage)' is not supported")
      throw LocalizationError.languageNotSupported(
        "Language '\(deviceLanguage)' is not supported. Supported languages are: \(available.sorted().joined(separator: ", "))"
      )
    }

    Logger.shared.i("Device language: \(deviceLanguage), using localization: \(localization)")
    return localization
  }

  /**
   * Gets localized string based on device language.
   * Supported languages are the .lproj folders in Resources, generated from
   * packages/patrol/tool/native_localization.
   */
  static func getLocalizedString(key: String) throws -> String {
    // Get the bundle containing the Localizable.strings files
    #if SWIFT_PACKAGE
      let bundle = Bundle.module
    #else
      let bundle = Bundle(for: Localization.self)
    #endif

    let targetLanguage = try resolveLocalization(in: bundle)

    return try getLocalizedStringForLanguage(key: key, language: targetLanguage, bundle: bundle)
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

@objc(ObjCLocalization) public class ObjCLocalization: NSObject {
  @objc public static func getLocalizedString(key: String) -> String {
    do {
      return try Localization.getLocalizedString(key: key)
    } catch {
      return key  // Return the key itself as fallback
    }
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
