//
//  DetailViewModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation
import Combine

class DetailViewModel {

    let subcategory: CareSubcategory
    let title: String
    let imageURLString: String
    let descriptionText: String

    @Published private(set) var isFavourite = false

    var cancellable = Set<AnyCancellable>()

    private let favouriteManager: FavouriteManager

    init(subcategory: CareSubcategory,
         language: AppLanguage = LanguageManager.shared.selectedLanguage,
         favouriteManager: FavouriteManager = .shared) {
        self.subcategory = subcategory
        self.favouriteManager = favouriteManager
        title = subcategory.displayName(for: language)
        imageURLString = subcategory.image ?? ""
        let description = subcategory.displayDescription(for: language)
        descriptionText = description.isEmpty ? "No description available." : description
        isFavourite = favouriteManager.isFavourite(subcategory)
    }

    func toggleFavourite() {
        favouriteManager.toggleFavourite(subcategory)
        isFavourite = favouriteManager.isFavourite(subcategory)
    }

    // Text shared through the system share sheet.
    var shareText: String {
        return "\(title)\n\n\(descriptionText)"
    }
}
