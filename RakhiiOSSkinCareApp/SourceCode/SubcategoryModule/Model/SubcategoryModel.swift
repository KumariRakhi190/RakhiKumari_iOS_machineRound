//
//  SubcategoryModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation

struct CareSubcategory: Decodable {
    let id: String?
    let applicationId: String?
    let categoryId: String?
    let subcategoryName: String?
    let image: String?
    let languages: [LocalizedContent]?

    enum CodingKeys: String, CodingKey {
        case id
        case applicationId = "applicationid"
        case categoryId = "categoryid"
        case subcategoryName = "subcategory_name"
        case image
        case languages = "language"
    }

}
