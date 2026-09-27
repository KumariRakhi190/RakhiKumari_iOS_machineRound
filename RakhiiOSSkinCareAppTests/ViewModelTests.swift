//
//  ViewModelTests.swift
//  RakhiiOSSkinCareAppTests
//
//  Created by RakhiKumari on 25/09/26.
//

import XCTest
import Combine
@testable import RakhiiOSSkinCareApp

class ViewModelTests: XCTestCase {

    // Each test gets its own empty offline cache folder.
    private var offlineCache: OfflineCache!

    override func setUp() {
        super.setUp()
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        offlineCache = OfflineCache(directory: directory)
    }

    // MARK: - CategoryViewModel

    func testCategoryViewModelSuccessLoadsCategories() async {
        let client = MockNetworkClient(stub: .json(SampleJSON.categories))
        let viewModel = CategoryViewModel(applicationId: "19", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)
        var states: [ViewState] = []
        var cancellable = Set<AnyCancellable>()
        viewModel.$state.dropFirst().sink { states.append($0) }.store(in: &cancellable)

        await viewModel.fetchCategories()

        XCTAssertEqual(states, [.loading, .loaded])
        XCTAssertEqual(viewModel.categories.count, 2)
        XCTAssertEqual(viewModel.category(at: 0)?.categoryName, "Face Wrinkles")
        XCTAssertNil(viewModel.category(at: 5))
        XCTAssertEqual(client.requestedEndpoints, [.getCategory(applicationId: "19")])
    }

    func testCategoryViewModelFailureShowsErrorMessage() async {
        let client = MockNetworkClient(stub: .failure(URLError(.notConnectedToInternet)))
        let viewModel = CategoryViewModel(applicationId: "19", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)

        await viewModel.fetchCategories()

        XCTAssertEqual(viewModel.state, .error(NetworkError.noInternet.userMessage))
        XCTAssertTrue(viewModel.categories.isEmpty)
    }

    func testCategoryViewModelBadStatusCodeShowsErrorMessage() async {
        let client = MockNetworkClient(stub: .failure(NetworkError.badStatusCode(500)))
        let viewModel = CategoryViewModel(applicationId: "19", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)

        await viewModel.fetchCategories()

        XCTAssertEqual(viewModel.state, .error(NetworkError.badStatusCode(500).userMessage))
    }

    func testCategoryViewModelEmptyDataShowsEmptyState() async {
        let client = MockNetworkClient(stub: .json(SampleJSON.emptyCategories))
        let viewModel = CategoryViewModel(applicationId: "99", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)

        await viewModel.fetchCategories()

        XCTAssertEqual(viewModel.state, .empty("No categories found."))
    }

    func testCategoryViewModelRetryAfterFailureLoadsData() async {
        let client = MockNetworkClient(stub: .failure(URLError(.timedOut)))
        let viewModel = CategoryViewModel(applicationId: "19", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)

        await viewModel.fetchCategories()
        XCTAssertEqual(viewModel.state, .error(NetworkError.timeout.userMessage))

        client.stub = .json(SampleJSON.categories)
        await viewModel.fetchCategories()
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.categories.count, 2)
    }

    func testCategoryViewModelShowsSavedCategoriesWhenOffline() async {
        let client = MockNetworkClient(stub: .json(SampleJSON.categories))
        let viewModel = CategoryViewModel(applicationId: "19", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)
        await viewModel.fetchCategories()

        // Same screen opened again without internet.
        client.stub = .failure(URLError(.notConnectedToInternet))
        let offlineViewModel = CategoryViewModel(applicationId: "19", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)
        await offlineViewModel.fetchCategories()

        XCTAssertEqual(offlineViewModel.state, .loaded)
        XCTAssertEqual(offlineViewModel.categories.count, 2)
        XCTAssertEqual(offlineViewModel.infoMessage, "You are offline. Showing saved data.")
    }

    func testCategoryViewModelSearchFiltersByName() async {
        let client = MockNetworkClient(stub: .json(SampleJSON.categories))
        let viewModel = CategoryViewModel(applicationId: "19", screenTitle: "Face Care", networkClient: client, offlineCache: offlineCache)
        await viewModel.fetchCategories()

        viewModel.search(text: "acne")
        XCTAssertEqual(viewModel.categories.map { $0.categoryName }, ["Acne (Pimples)"])

        viewModel.search(text: "xyz")
        XCTAssertTrue(viewModel.categories.isEmpty)

        viewModel.search(text: "")
        XCTAssertEqual(viewModel.categories.count, 2)
    }

    // MARK: - SubcategoryViewModel

    func testSubcategoryViewModelSuccessPassesApplicationAndCategoryId() async {
        let client = MockNetworkClient(stub: .json(SampleJSON.subcategories))
        let viewModel = SubcategoryViewModel(applicationId: "19", categoryId: "1", screenTitle: "Face Wrinkles", networkClient: client, offlineCache: offlineCache)

        await viewModel.fetchSubcategories()

        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.subcategory(at: 0)?.subcategoryName, "REMEDY")
        XCTAssertEqual(client.requestedEndpoints, [.getSubcategory(applicationId: "19", categoryId: "1")])
    }

    func testSubcategoryViewModelDecodingFailureShowsErrorMessage() async {
        let client = MockNetworkClient(stub: .json("<html>not json</html>"))
        let viewModel = SubcategoryViewModel(applicationId: "19", categoryId: "1", screenTitle: "Face Wrinkles", networkClient: client, offlineCache: offlineCache)

        await viewModel.fetchSubcategories()

        XCTAssertEqual(viewModel.state, .error(NetworkError.decodingFailed.userMessage))
        XCTAssertTrue(viewModel.subcategories.isEmpty)
    }

    // MARK: - Favourites

    func testFavouriteManagerSavesAndRemovesTip() throws {
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: UUID().uuidString))
        let response = try JSONDecoder().decode(APIResponse<CareSubcategory>.self, from: Data(SampleJSON.subcategories.utf8))
        let tip = try XCTUnwrap(response.data.first)

        let favouriteManager = FavouriteManager(userDefaults: userDefaults)
        favouriteManager.toggleFavourite(tip)
        XCTAssertTrue(favouriteManager.isFavourite(tip))

        // Saved locally: a new manager reads it back.
        let reloadedManager = FavouriteManager(userDefaults: userDefaults)
        XCTAssertEqual(reloadedManager.favourites.first?.displayName(for: .english), "Coconut oil")

        reloadedManager.toggleFavourite(tip)
        XCTAssertFalse(reloadedManager.isFavourite(tip))
        XCTAssertTrue(FavouriteManager(userDefaults: userDefaults).favourites.isEmpty)
    }
}
