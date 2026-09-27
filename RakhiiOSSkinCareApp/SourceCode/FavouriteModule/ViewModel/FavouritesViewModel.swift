//
//  FavouritesViewModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import Foundation
import Combine

class FavouritesViewModel {

    @Published private(set) var favourites: [CareSubcategory] = []

    var cancellable = Set<AnyCancellable>()

    init(favouriteManager: FavouriteManager = .shared) {
        favouriteManager.$favourites.assign(to: &$favourites)
    }

    func favourite(at index: Int) -> CareSubcategory? {
        guard favourites.indices.contains(index) else { return nil }
        return favourites[index]
    }
}
