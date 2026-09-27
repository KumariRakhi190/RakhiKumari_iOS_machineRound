//
//  LocalizedContentHelper.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import Foundation

extension Array where Element == LocalizedContent {

    func name(for language: AppLanguage) -> String? {
        return text(for: language) { $0.name }
    }

    func description(for language: AppLanguage) -> String? {
        return text(for: language) { $0.description }
    }

    private func text(for language: AppLanguage, value: (LocalizedContent) -> String?) -> String? {
        for languageToTry in [language, .english] {
            let content = first { $0.languageName?.lowercased() == languageToTry.apiName.lowercased() }
            let text = (content.flatMap(value) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                return text
            }
        }
        return nil
    }
}

extension CareCategory {

    func displayName(for language: AppLanguage = LanguageManager.shared.selectedLanguage) -> String {
        return languages?.name(for: language) ?? categoryName ?? ""
    }
}

extension CareSubcategory {

    func displayName(for language: AppLanguage = LanguageManager.shared.selectedLanguage) -> String {
        return languages?.name(for: language) ?? subcategoryName ?? ""
    }

    // Description as readable plain text (HTML tags removed).
    func displayDescription(for language: AppLanguage = LanguageManager.shared.selectedLanguage) -> String {
        return (languages?.description(for: language) ?? "").htmlToPlainText
    }

    // Unique id used to save the tip in favourites.
    var favouriteId: String {
        return "\(applicationId ?? "")-\(id ?? "")"
    }
}
