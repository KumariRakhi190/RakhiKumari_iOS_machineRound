//
//  CategoryModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation

struct CareCategory: Decodable {
    let id: String?
    let applicationId: String?
    let categoryName: String?
    let image: String?
    let audioFile: String?
    let languages: [LocalizedContent]?

    enum CodingKeys: String, CodingKey {
        case id
        case applicationId = "applicationid"
        case categoryName = "category_name"
        case image
        case audioFile = "audio_file"
        case languages = "language"
    }

}
