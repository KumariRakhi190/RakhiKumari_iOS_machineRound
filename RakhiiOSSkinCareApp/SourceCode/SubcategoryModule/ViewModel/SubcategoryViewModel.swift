//
//  SubcategoryViewModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation
import Combine

class SubcategoryViewModel {

    let applicationId: String
    let categoryId: String
    let screenTitle: String

    @Published private(set) var subcategories: [CareSubcategory] = []
    @Published private(set) var state: ViewState = .idle
    @Published var infoMessage: String?

    var cancellable = Set<AnyCancellable>()

    private let networkClient: NetworkClient
    private let offlineCache: OfflineCache

    private var cacheKey: String {
        return "subcategories-\(applicationId)-\(categoryId)"
    }

    init(applicationId: String, categoryId: String, screenTitle: String, networkClient: NetworkClient = APIManager.shared, offlineCache: OfflineCache = .shared) {
        self.applicationId = applicationId
        self.categoryId = categoryId
        self.screenTitle = screenTitle
        self.networkClient = networkClient
        self.offlineCache = offlineCache
    }

    //MARK: API Calling
    func getSubcategories() {
        Task {
            await fetchSubcategories()
        }
    }

    func fetchSubcategories() async {
        state = .loading
        do {
            let endpoint = APIEndpoint.getSubcategory(applicationId: applicationId, categoryId: categoryId)
            let response = try await networkClient.request(endpoint, responseType: APIResponse<CareSubcategory>.self)
            guard response.status else {
                throw NetworkError.serverError(response.message ?? "")
            }
            subcategories = response.data
            offlineCache.save(subcategories, forKey: cacheKey)
            state = subcategories.isEmpty ? .empty("No tips found.") : .loaded
        } catch {
            let networkError = NetworkError.map(error)
            if networkError == .noInternet, let savedTips = offlineCache.load([CareSubcategory].self, forKey: cacheKey), !savedTips.isEmpty {
                subcategories = savedTips
                infoMessage = "You are offline. Showing saved data."
                state = .loaded
                return
            }
            subcategories = []
            state = .error(networkError.userMessage)
        }
    }

    func subcategory(at index: Int) -> CareSubcategory? {
        guard subcategories.indices.contains(index) else { return nil }
        return subcategories[index]
    }
}
