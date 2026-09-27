//
//  ModelDecodingTests.swift
//  RakhiiOSSkinCareAppTests
//
//  Created by RakhiKumari on 25/09/26.
//

import XCTest
@testable import RakhiiOSSkinCareApp

class ModelDecodingTests: XCTestCase {

    func testCategoryResponseDecodesFromSampleJSON() throws {
        let response = try JSONDecoder().decode(APIResponse<CareCategory>.self, from: Data(SampleJSON.categories.utf8))

        XCTAssertTrue(response.status)
        XCTAssertEqual(response.data.count, 2)

        let category = try XCTUnwrap(response.data.first)
        XCTAssertEqual(category.id, "1")
        XCTAssertEqual(category.applicationId, "19")
        XCTAssertEqual(category.categoryName, "Face Wrinkles")
        XCTAssertEqual(category.audioFile, "")
        XCTAssertEqual(category.languages?.count, 4)
    }

    func testCategoryNameUsesSelectedLanguageThenEnglishThenCategoryName() throws {
        let response = try JSONDecoder().decode(APIResponse<CareCategory>.self, from: Data(SampleJSON.categories.utf8))
        let faceWrinkles = try XCTUnwrap(response.data.first)
        let acne = try XCTUnwrap(response.data.last)

        XCTAssertEqual(faceWrinkles.displayName(for: .hindi), "चेहरे की झुर्रियाँ")
        // No Telugu entry in the sample -> English.
        XCTAssertEqual(faceWrinkles.displayName(for: .telugu), "Face Wrinkles")
        // English name is empty too -> category_name.
        XCTAssertEqual(acne.displayName(for: .english), "Acne (Pimples)")
    }

    func testSubcategoryDecodesFromSampleJSON() throws {
        let response = try JSONDecoder().decode(APIResponse<CareSubcategory>.self, from: Data(SampleJSON.subcategories.utf8))
        let subcategory = try XCTUnwrap(response.data.first)

        XCTAssertEqual(subcategory.id, "1")
        XCTAssertEqual(subcategory.applicationId, "19")
        XCTAssertEqual(subcategory.categoryId, "1")
        XCTAssertEqual(subcategory.subcategoryName, "REMEDY")
        XCTAssertEqual(subcategory.displayName(for: .english), "Coconut oil")
        // Spanish is missing in the sample -> English.
        XCTAssertEqual(subcategory.displayName(for: .spanish), "Coconut oil")
    }

    func testDetailDescriptionIsReadableTextWithoutHTML() throws {
        let response = try JSONDecoder().decode(APIResponse<CareSubcategory>.self, from: Data(SampleJSON.subcategories.utf8))
        let favouriteManager = FavouriteManager(userDefaults: try XCTUnwrap(UserDefaults(suiteName: UUID().uuidString)))
        let viewModel = DetailViewModel(subcategory: try XCTUnwrap(response.data.first), language: .english, favouriteManager: favouriteManager)

        XCTAssertEqual(viewModel.title, "Coconut oil")
        XCTAssertEqual(viewModel.descriptionText, """
        Coconut oil fights free radicals & reduces wrinkles.

        • Cleanse your face.
        • Leave the oil on overnight.

        Note: Repeat every night.
        """)
        XCTAssertFalse(viewModel.descriptionText.contains("<"))
    }

    func testMissingDataIsDecodedAsEmptyList() throws {
        let json = #"{ "status": true, "message": "Successfully data", "data": null }"#
        let response = try JSONDecoder().decode(APIResponse<CareCategory>.self, from: Data(json.utf8))
        XCTAssertTrue(response.data.isEmpty)
    }

    func testEndpointsBuildHttpsURLsWithQueryItems() {
        XCTAssertEqual(APIEndpoint.getCategory(applicationId: "19").url?.absoluteString,
                       "https://mobilehubs.website/appmanagement123/api/getcategory?applicationid=19")
        XCTAssertEqual(APIEndpoint.getSubcategory(applicationId: "21", categoryId: "3").url?.absoluteString,
                       "https://mobilehubs.website/appmanagement123/api/getsubcategory?applicationid=21&categoryid=3")
    }
}
