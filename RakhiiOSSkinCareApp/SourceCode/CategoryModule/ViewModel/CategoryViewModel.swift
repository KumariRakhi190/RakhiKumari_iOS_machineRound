//
//  CategoryViewModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation
import Combine

class CategoryViewModel {

    let applicationId: String
    let screenTitle: String

    @Published private(set) var categories: [CareCategory] = []
    @Published private(set) var state: ViewState = .idle
    @Published var infoMessage: String?

    var cancellable = Set<AnyCancellable>()

    private var allCategories: [CareCategory] = []
    private(set) var searchText = ""

    private let networkClient: NetworkClient
    private let offlineCache: OfflineCache

    private var cacheKey: String {
        return "categories-\(applicationId)"
    }

    init(applicationId: String, screenTitle: String, networkClient: NetworkClient = APIManager.shared, offlineCache: OfflineCache = .shared) {
        self.applicationId = applicationId
        self.screenTitle = screenTitle
        self.networkClient = networkClient
        self.offlineCache = offlineCache
    }

    func getCategories() {
        Task {
            await fetchCategories()
        }
    }

    func fetchCategories() async {
        state = .loading
        do {
            let response = try await networkClient.request(.getCategory(applicationId: applicationId), responseType: APIResponse<CareCategory>.self)
            guard response.status else {
                throw NetworkError.serverError(response.message ?? "")
            }
            allCategories = response.data
            offlineCache.save(allCategories, forKey: cacheKey)
            applySearch()
            state = allCategories.isEmpty ? .empty("No categories found.") : .loaded
        } catch {
            let networkError = NetworkError.map(error)
            if networkError == .noInternet, let savedCategories = offlineCache.load([CareCategory].self, forKey: cacheKey), !savedCategories.isEmpty {
                allCategories = savedCategories
                applySearch()
                infoMessage = "You are offline. Showing saved data."
                state = .loaded
                return
            }
            allCategories = []
            applySearch()
            state = .error(networkError.userMessage)
        }
    }

    //MARK: Search
    func search(text: String) {
        searchText = text
        applySearch()
    }

    private func applySearch() {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            categories = allCategories
        } else {
            categories = allCategories.filter {
                matches($0.displayName(), text) || matches($0.categoryName ?? "", text)
            }
        }
    }

    // Ignores upper/lower case and accents, so "perdida" also finds "Pérdida".
    private func matches(_ name: String, _ text: String) -> Bool {
        return name.range(of: text, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }

    func category(at index: Int) -> CareCategory? {
        guard categories.indices.contains(index) else { return nil }
        return categories[index]
    }
}
