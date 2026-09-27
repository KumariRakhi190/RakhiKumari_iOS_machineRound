//
//  LanguageManager.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case english
    case hindi
    case telugu
    case spanish

    // Value of `language_name` in the API response, also shown in the language list.
    var apiName: String {
        switch self {
        case .english: return "English"
        case .hindi: return "Hindi"
        case .telugu: return "Telugu"
        case .spanish: return "Spanish"
        }
    }
}

/// Keeps the language chosen by the user, saved in UserDefaults.
/// Category and tip names/descriptions are shown in this language using the API's `language` array.
class LanguageManager {

    static let shared = LanguageManager()

    private let userDefaults: UserDefaults
    private let selectedLanguageKey = "selectedLanguage"

    private(set) var selectedLanguage: AppLanguage

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let savedValue = userDefaults.string(forKey: selectedLanguageKey) ?? ""
        selectedLanguage = AppLanguage(rawValue: savedValue) ?? .english
    }

    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        userDefaults.set(language.rawValue, forKey: selectedLanguageKey)
    }
}
