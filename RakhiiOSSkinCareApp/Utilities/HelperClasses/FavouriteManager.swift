//
//  FavouriteManager.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import Foundation
import Combine

/// Keeps the favourite tips saved locally in UserDefaults.
class FavouriteManager {

    static let shared = FavouriteManager()

    @Published private(set) var favourites: [CareSubcategory] = []

    private let userDefaults: UserDefaults
    private let favouritesKey = "favouriteTips"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let data = userDefaults.data(forKey: favouritesKey),
           let savedFavourites = try? JSONDecoder().decode([CareSubcategory].self, from: data) {
            favourites = savedFavourites
        }
    }

    func isFavourite(_ tip: CareSubcategory) -> Bool {
        return favourites.contains { $0.favouriteId == tip.favouriteId }
    }

    // Adds the tip if it is not a favourite yet, otherwise removes it.
    func toggleFavourite(_ tip: CareSubcategory) {
        if isFavourite(tip) {
            favourites.removeAll { $0.favouriteId == tip.favouriteId }
        } else {
            favourites.insert(tip, at: 0)
        }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(favourites) else { return }
        userDefaults.set(data, forKey: favouritesKey)
    }
}
